/*
a little investigation seems to indicate that the recheck condition is always printed in the EXPLAIN, 
but is actually only performed when  work_mem is small enough that the bitmap becomes lossy.
*/

/*

A bitmapped index scan works in two stages. First the index or indexes 
are scanned to create a bitmap representing matching tuples. That shows 
up as Bitmap Index Scan in explain. Then all the matching tuples are 
fetched from the heap, that's the Bitmap Heap Scan.

If the bitmap is larger than work_mem (because there's a lot of matching 
tuples), it's stored in memory as lossy. In lossy mode, we don't store 
every tuple in the bitmap, but each page with any matching tuples on it 
is represented as a single bit. When performing the Bitmap Heap Scan 
phase with a lossy bitmap, the pages need to be scanned, using the 
Recheck condition, to see which tuples match.

The Recheck condition is always shown, even if the bitmap is not stored 
as lossy and no rechecking is done.


*/


/* 



The Bitmap Index+Heap Scan operations are an optimization of the regular Index Scan: 
Instead of accessing the Heap right after fetching a row from the index, the Bitmap Index Scan completes the 
index lookup first, keeping track of all rows that might be interesting (in a, you guess it, bitmap). 

The Bitmap Heap Scan than accesses all the interesting heap pages sequentially. For that, it first sorts the bitmap. 
he aim is to reduce the random IO by using a little memory and CPU for the bitmap. 
The Bitmap Index+Heap Scan's make only sense if you access many rows. 
Further the Bitmap itself makes only sense if you intend to fetch data from the heap. 
Consequently, the Bitmap operations are not the right tool to implement index-only scans. 
Only the Index Only Scan operation actually implements index-only scans.



Postgres is reading Table C using a Bitmap Heap Scan. 

When the number of keys to check stays small, it can efficiently use the index to build the bitmap in memory. 
If the bitmap gets too large, the query optimizer changes the way it looks up data. 

In our case it has a large number of keys to check so it uses the more approximative way to retrieve the candidate rows and checks each row individually for a match on x_key and tags. 

All this “loading in memory” and “checking individual row” takes time (the Recheck Cond in the plan).

Luckily for us the table is 30% loaded in RAM so it is not as bad as retrieving the rows from disk. 
It still has a very noticeable impact on performance. Remember that the query is quite simple. 
It’s a primary key lookup so there aren’t many obvious ways to fix it without dramatically re-architecting the database or the application. 

*/




-- Let us set up an example and see how it works. We shall create a very narrow table, with only 12 bytes per row.

create table narrow_table as
	with numbers as(select generate_series as n from generate_series(0,1048575))
	select n as seq_number, 
	trunc(random()*1048575) as rand_number
	from numbers; 

alter table narrow_table add constraint pk_narrow_table primary key(seq_number);
create index narrow_table_rand on narrow_table(rand_number);

cluster narrow_table using pk_narrow_table;
-- vacuum full must be run as a separate command

vacuum full analyze narrow_table;


-- This table is physically ordered by seq_number column, as a result of cluster command. 

/* If CLUSTER is that slow, it really seems to be an IO problem, and the data does not seem to match the index at all.
	the cluster operation is a one off process that rearranged the data on disk. 
	The intent is to get your 2000 results rows from fewer disk blocks.

	I'd recommend reloading it, in a pattern closer to how it will be loaded as it is generated. 
	I imagine that the data is generated one day at a time, which will effectively result in strong correlation 
	between DateID and the location on disk. If that is the case, then I'd either cluster by DateID, or split your 
	test data into 365 separate loads, and reload it.
*/

-- However, there is very little correlation between rand_number values and physical order of rows:


SELECT attname, correlation FROM pg_stats WHERE tablename LIKE '%narrow%'; 
┌─────────────┬─────────────┐
│   attname   │ correlation │
├─────────────┼─────────────┤
│ rand_number │  0.00321339 │
│ seq_number  │           1 │
└─────────────┴─────────────┘



-- The following query uses Bitmap Index Scan, Recheck Cond, and Bitmap Heap Scan:

explain analyze select seq_number, rand_number from narrow_table where rand_number between 1 and 1000;

┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                           QUERY PLAN                                                            │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Bitmap Heap Scan on narrow_table  (cost=28.10..2860.43 rows=1139 width=12) (actual time=0.230..3.440 rows=1054 loops=1)         │
│   Recheck Cond: ((rand_number >= 1::double precision) AND (rand_number <= 1000::double precision))                              │
│   Heap Blocks: exact=980                                                                                                        │
│   ->  Bitmap Index Scan on narrow_table_rand  (cost=0.00..27.82 rows=1139 width=0) (actual time=0.129..0.129 rows=1054 loops=1) │
│         Index Cond: ((rand_number >= 1::double precision) AND (rand_number <= 1000::double precision))                          │
│ Planning time: 0.180 ms                                                                                                         │
│ Execution time: 3.507 ms                                                                                                        │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

/*
First, during Bitmap Index Scan step, the index was scanned, and 1054 rows matched the range condition. 
These rows were on 980 pages, which were read during the Bitmap Heap Scan step. 

All the rows on those pages were matched against the range condition, which was mentioned as Recheck Cond 
in the execution plan.
*/

/*
	Heap Blocks: exact=693 lossy=3732

	From a total of 4425 data pages (blocks), 693 stored tuples exactly (including tuple pointers), 
	while the other 3732 pages were lossy (just the data page) in the bitmap. 

	That happens when work_mem is not big enough to store the whole bitmap built from the index scan exactly 
	(lossless) - because the result is too huge or the setting for work_mem is too small (you decide).

	The index condition has to be rechecked for pages from the lossy share, since the bitmap only remembers which 
	pages to fetch and not the exact tuples on the page. Not all tuples on the page will necessarily pass the index 
	conditions, it's necessary to actually recheck the condition.

*/

/*
BUFFERS
=======
In addition, when running with BUFFERS option: EXPLAIN (ANALYZE, BUFFERS) ... another line is added like:

Buffers: shared hit=279 read=79

	This indicates how much of the heap (underlying table) was read from the cache (shared hit) 
	and how much had to be fetched from disk (read=79). 
	If you repeat the query, the "read" part typically disappears for not-too-huge queries, 
	because everything is cached now after the first call. The first call tells you how much was cached already. 

	Subsequent calls will tell you how much of it your cache can hold.
*/



-- The relative complexity of this plan allows Postgres to satisfy the query by reading only 980 pages. 
-- This makes sense if random page reads are expensive.



-- Let us have the query planner think that random page reads are no more expensive than sequential ones:
SET random_page_cost = 1;


explain analyze select seq_number, rand_number  from narrow_table where rand_number between 1 and 1000;

┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                QUERY PLAN                                                                │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Index Scan using narrow_table_rand on narrow_table  (cost=0.42..1063.19 rows=1139 width=12) (actual time=0.017..0.625 rows=1054 loops=1) │
│   Index Cond: ((rand_number >= 1::double precision) AND (rand_number <= 1000::double precision))                                         │
│ Planning time: 0.108 ms                                                                                                                  │
│ Execution time: 0.682 ms                                                                                                                 │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘

/*
This time the plan is much simpler -  as Postgres scans the index and finds a matching key, 
the corresponding row is read right away, via a random page read. 

Since random page reads are cheap, going for a more complex plan to save less than 10% of reads does not make sense 
any more.
*/




-- Also note that the query planner takes into account the correlation between columns values and physical location of rows. 
-- In all previous queries the correlation was very low, so every time a matching index key was found, 
-- most likely it was on a different page.


-- Let us see what happens when the correlation is high. 
/* 
Our table has been explicitly clustered on its first column, so the correlation between seq_number and physical location 
of rows is 1, which is the highest possible value. 
This means that as we scan the index and find matching key, every next matching row is very likely to be on the 
same page.


As a result, even if we set the price of random page reads to be very high, such as 10 instead of the default 4, 
there are not going to be many page reads - the next row is very likely to be found right on the page we have just 
read for the previous match. So the execution plan is going to be a simple index scan:
*/

SET random_page_cost = 10;

explain analyze select seq_number, rand_number  from narrow_table where rand_number between 1 and 1000;

-- Supposed To Be
┌──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                QUERY PLAN                                                                │
├──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Index Scan using narrow_table_rand on narrow_table  (cost=0.42..1146.19 rows=1239 width=12) (actual time=0.017..0.959 rows=1141 loops=1) │
│   Index Cond: ((rand_number >= 1::double precision) AND (rand_number <= 1100::double precision))                                         │
│ Planning time: 0.097 ms                                                                                                                  │
│ Execution time: 1.025 ms                                                                                                                 │
└──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘


-- In Reality
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                           QUERY PLAN                                                            │
├─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┤
│ Bitmap Heap Scan on narrow_table  (cost=52.10..6442.91 rows=1139 width=12) (actual time=0.226..0.883 rows=1054 loops=1)         │
│   Recheck Cond: ((rand_number >= 1::double precision) AND (rand_number <= 1000::double precision))                              │
│   Heap Blocks: exact=980                                                                                                        │
│   ->  Bitmap Index Scan on narrow_table_rand  (cost=0.00..51.81 rows=1139 width=0) (actual time=0.127..0.127 rows=1054 loops=1) │
│         Index Cond: ((rand_number >= 1::double precision) AND (rand_number <= 1000::double precision))                          │
│ Planning time: 0.101 ms                                                                                                         │
│ Execution time: 0.946 ms                                                                                                        │
└─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┘


-- As we have seen, if random page reads are expensive, and if the correlation between 
-- column values and physical location of rows is not very high, 
-- the query planner may use Bitmap Index Scan, Recheck Cond, and Bitmap Heap Scan in order to minimize 
-- the number of random page reads.
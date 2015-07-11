DROP TABLE IF EXISTS users;

CREATE TABLE users (
    first_name text,
    last_name text
);

-- Next, let's fill that table up with random data:

SELECT md5(random()::text), md5(random()::text) FROM (SELECT * FROM generate_series(1,1000000) AS id) AS x;

-- This will give us a million rows of random data to search through.


INSERT INTO users (SELECT md5(random()::text), md5(random()::text) FROM (SELECT * FROM generate_series(1,1000000) AS id) AS x);


-- Let's try searching through this data without index, and see what kind of results we get back. 
-- Make sure to type in \timing in order to get time data back from these queries.

SELECT count(*) FROM users where first_name ilike '%aeb%';

-- Running this query takes about 679.618 ms on my system.


-- Let's see what happens when we search using both first_name and last_name.

SELECT count(*) FROM users where first_name ilike '%aeb%' or last_name ilike'%aeb%';

-- This query takes 1332.164 ms to run on my system.



-- Introducing our Gin index
-- ===========================

-- Let's create our Gin index, using the gin_trgm_ops option
-- If you're on Ubuntu you must ensure you have the contrib packages installed. 
-- On 14.04 simply run sudo apt-get install postgresql-contrib-9.3 before running the following queries.


/* 
	The pg_trgm module provides functions and operators for determining the similarity of 
	ASCII alphanumeric text based on trigram matching, as well as index operator classes that support 
	fast searching for similar strings.
*/

CREATE EXTENSION IF NOT EXISTS pg_trgm;
CREATE INDEX users_search_idx ON users USING gin (first_name gin_trgm_ops, last_name gin_trgm_ops);

-- Creating this index may take a decent amount of time. 
-- Once it finishes, let's try running those same queries again and see what we get.


-- First query: 837.559 ms
-- Second query: 440.382 ms


-- What is gin_trgm_ops?
-- =========================
-- This option tells Postgres to index using trigrams over our selected columns. 
-- A trigram is a data structure that hold 3 letters of a word. 
-- Essentially, Postgres will break down each text column down into trigrams and use that 
-- in the index when we search against it.


 -- What is a Trigram and how use them?
 -- ====================================
	CREATE EXTENSION pg_trgm;
 /*
	A trigram is a group of three consecutive characters in a string that can be used to detect the 
	similarity of two words (for example) or the ‘distance’ between them.

	When we talk about ‘distance’, 0 means in the same place and 1 is very far.
	When we talk about similarity, 1 is equal and 0 is totally different. 

	In other words,distance is 1 minus the similarity value. 
	These concepts about distance and similarity, are necessary to start without confusion.


	What’s is a trigram? 
	A trigram is a group of three consecutive characters from a string, 
	used to know the similarity between two strings by counting the trigrams they share.


	A trigram looks like this:
*/
	SELECT show_trgm('PalominoDB CO');
┌───────────────────────────────────────────────────────────────────────┐
│                               show_trgm                               │
├───────────────────────────────────────────────────────────────────────┤
│ {"  c","  p"," co"," pa",alo,"co ","db ",ino,lom,min,nod,odb,omi,pal} │
└───────────────────────────────────────────────────────────────────────┘


/*
	In the pg_trgm extension we have functions and operators.

	show_limit and set_limit are functions 
	used to set up and show the similarity threshold for the % operator.

	This operator takes the form "string1 % string2" and returns a boolean type (
	“t” if the similarity is greater than the similarity threshold, otherwise it returns “f”).

*/	

select show_limit();
┌────────────┐
│ show_limit │
├────────────┤
│        0.3 │
└────────────┘

select set_limit(0.2), show_limit();
┌───────────┬────────────┐
│ set_limit │ show_limit │
├───────────┼────────────┤
│       0.2 │        0.2 │
└───────────┴────────────┘

/*
In the following example we’ll see the use of each one. 

 Operator % will return true if the similarity of the strings is greater than similarity threshold 
 returned by show_limit function. 

 In this example, both string are equal, in consequence, the operation will return true:

*/

select similarity('Palomino','Palomino') AS Similarity,'Palomino'<->'Palomino' AS distance,
'Palomino' % 'Palomino' AS SimilarOrNot;
┌────────────┬──────────┬──────────────┐
│ similarity │ distance │ similarornot │
├────────────┼──────────┼──────────────┤
│          1 │        0 │ t            │
└────────────┴──────────┴──────────────┘





-- Index Support and usage
-- ========================

/*
	Now let’s discuss combining GIST or GIN and pg_trgm.
	pg_trgm includes an operator class to support searches using similarity, like, or ilike operators. 

	GIN and GIST have several differences. 
	If you don’t know which to choose, just remember a few rules: 
	GIN searches quicker than GIST but is slower to update; 
	if you have a write-intensive table use GIST. 
	GIN is better for static data.

	
	Please be aware, however, that they don’t support exact matching with the equals operator!  
	You can do an exact match using like/ilike with no wildcards.  
	If you want to use the equals operator(=), you must create a standard BTREE index on the 
	pertinent column.

	
	 we’ll show a table only with a GIST index. 
	 As you can see, if you want to match the exact value with equal operator, 
	 it will scan the whole table:
		
*/

EXPLAIN ANALYZE  SELECT id, texto FROM texto_busqueda WHERE texto = 'Palomino';

QUERY PLAN
————————————————————————————————————-
Seq Scan on texto_busqueda  (cost=0.00..90.15 rows=1 width=136) (actual time=16.835..16.846 rows=1 loops=1)
Filter: (texto = 'Palomino'::text)
Total runtime: 17.094 ms
(3 rows)


-- But, if we use LIKE operator, index scan will be activated:
EXPLAIN ANALYZE  SELECT id, texto FROM texto_busqueda WHERE texto like 'Palomino';

QUERY PLAN
—————————————————————————————————————————-
Index Scan using texto_busqueda_texto_idx on texto_busqueda  (cost=0.00..8.27 rows=1 width=136) (actual time=0.374..1.780 rows=1 loops=1)
Index Cond: (texto ~~ 'Palomino'::text)
Total runtime: 1.979 ms
(3 rows)



EXPLAIN ANALYZE  SELECT id, texto FROM texto_busqueda WHERE texto like '%Palomino%';

QUERY PLAN
—————————————————————————————————————————
Index Scan using texto_busqueda_texto_idx on texto_busqueda  (cost=0.00..8.27 rows=1 width=136) (actual time=0.171..1.732 rows=1 loops=1)
Index Cond: (texto ~~ '%Palomino%'::text)
Total runtime: 1.882 ms
(3 rows)


-- To use an index for  match equal strings, we need to create a BTREE index. 
-- But in case of BTREE there is a limitation of 8191 bytes per index row. 
-- So, if you have very large text columns you will not allowed to create a BTREE index 
-- without using functional indexes.



-- The creation of indexes with the pg_trgm operator class is simple:
CREATE INDEX ON texto_busqueda USING GIST(texto gist_trgm_ops);
-- or
CREATE INDEX ON texto_busqueda USING GIN(texto gin_trgm_ops);


-- Another useful technique
-- Combining % operator to get the strings 
-- that have a similarity greater than the established threshold 
-- and similarity function -that returns the similarity-, 
-- we can get ordered from the most similar to the less one discarding all the strings that 
-- aren’t similar enough:

SELECT ctid, similarity(texto, ‘Palominodb’) AS simil 
FROM texto_busqueda 
WHERE texto % 'Palominodb'
ORDER BY simil DESC;
	






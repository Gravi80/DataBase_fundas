-- Get number of rows of all tables in a database

SELECT schemaname,relname,n_live_tup number_of_rows
FROM pg_stat_user_tables
ORDER BY number_of_rows DESC;


-- Cache and its Hit Rate
/*

The typical rule for most applications is that only a fraction of its 
data is regularly accessed. 
As with many other things data can tend to follow the 80/20 rule with 
20% of your data accounting for 80% of the reads and 
often times its higher than this. 
Postgres itself actually tracks access patterns of your data and 
will on its own keep frequently accessed data in cache. 
Generally you want your database to have a cache hit rate of about 99%.

*/

SELECT 
  sum(heap_blks_read) as heap_read,
  sum(heap_blks_hit)  as heap_hit,
  sum(heap_blks_hit) / (sum(heap_blks_hit) + sum(heap_blks_read)) as ratio
FROM 
  pg_statio_user_tables;


/*

heap_read | heap_hit |         ratio
-----------+----------+------------------------
    236163 |  6800983 | 0.96644051437898261596


If you find yourself with a ratio significantly lower than 99% 
then you likely want to consider increasing the cache available to your 
database.

*/  


/*

VACUUM FULL ANALYZE is recommended for tables that have just went through a bulk delete or update. 
Do note that when you run VACUUM FULL, the affected tables will be locked until the process is done and 
extra storage space is required as a temp store. 

Normal VACUUM do not lock the tables, but does has its overheads while running along side a live database.

*/

-- The easiest way is to monitor , how many aautovacuum workers are running:
-- Postgres 9.2 +
SELECT * FROM pg_stat_activity WHERE query LIKE 'autovacuum:%'; 
-- Older versions
SELECT * FROM pg_stat_activity WHERE current_query LIKE 'autovacuum:%';


-- Make sure your largest database tables are vacuumed and analyzed frequently by setting stricter table-level 
-- auto-vacuum settings. 

-- Below is an example which will VACUUM and ANALYZE after 5,000 inserts, updates, or deletes.

ALTER TABLE table_name SET (autovacuum_vacuum_scale_factor = 0.0);
ALTER TABLE table_name SET (autovacuum_vacuum_threshold = 5000);
ALTER TABLE table_name SET (autovacuum_analyze_scale_factor = 0.0);
ALTER TABLE table_name SET (autovacuum_analyze_threshold = 5000);


-- A query that fetched all rows inserted over a month ago would return in ~1 second, 
-- while the same query run on rows from the current month was taking 20+ seconds.


-- When Postgres receives a query, the first thing it does is try to optimize how the query will be executed 
-- based on its knowledge of the table structure, size, and indices. 
-- Prefixing any query with EXPLAIN will print out this execution plan without actually running it.


-- However, its knowledge of the database is not always up-to-date. 
-- Without accurate insight about the database tables, suboptimal query executions can be planned. 
-- In our case, slower query plans were being created for the newest rows for which the query optimizer did 
-- not have a clear picture. 


-- The solution was to VACUUM and ANALYZE the table. 

-- Vacuuming cleans up stale or temporary data, and analyzing refreshes its knowledge of all the tables for the 
-- query planner. We saw an immediate decrease in execution time for our complex queries, and as a result, 
-- a much more user-friendly internal website.


VACUUM ANALYZE table_name;
VACUUM VERBOSE ANALYZE table_name;

-- You can check the last time your tables were vacuumed and analyzed with the query below. 
select relname,last_vacuum, last_autovacuum, last_analyze, last_autoanalyze from pg_stat_user_tables;

/*
 Grep Postgres Log
 =================
 grep autovacuum /var/postgresql/log

*/

-- In our case, we had tables that hadn’t been cleaned up in weeks.


-- To prevent our tables from continually getting messy in the future and having to manually VACUUM ANALYZE, 
-- we made the default auto-vacuum settings stricter. 
-- Postgres runs a daemon to regularly vacuum and analyze itself. 
-- Tables are auto-vacuumed when 20% of the rows plus 50 rows are inserted, updated or deleted, 
-- and auto-analyzed similarly at 10%, and 50 row thresholds.
-- These settings work fine for smaller tables, but as a table grows to have millions of rows, there can be tens of 
-- thousands of inserts or updates before the table is vacuumed and analyzed.


-- In our case, we set much more aggressive thresholds for our largest tables, using the commands below. 
-- With these settings, a table is vacuumed and analyzed after 5,000 inserts, updates, or deletes.

ALTER TABLE table_name  
SET (autovacuum_vacuum_scale_factor = 0.0);

ALTER TABLE table_name  
SET (autovacuum_vacuum_threshold = 5000);

ALTER TABLE table_name  
SET (autovacuum_analyze_scale_factor = 0.0);

ALTER TABLE table_name  
SET (autovacuum_vacuum_threshold = 5000);  


-- The threshold to auto-vacuum is calculated by:
-- vacuum threshold = autovacuum_vacuum_threshold + autovacuum_vacuum_scale_factor * number of rows in table

-- Similarly, the threshold to auto-analyze is calculated by:
-- analyze threshold = autovacuum_vacuum_threshold + autovacuum_vacuum_scale_factor * number of rows in table

-- Just to see which tables qualify for autovacuum at all, the following query may be used
SELECT psut.relname,
     to_char(psut.last_vacuum, 'YYYY-MM-DD HH24:MI') as last_vacuum,
     to_char(psut.last_autovacuum, 'YYYY-MM-DD HH24:MI') as last_autovacuum,
     to_char(pg_class.reltuples, '9G999G999G999') AS live_tup,
     to_char(psut.n_dead_tup, '9G999G999G999') AS dead_tup,
     to_char(CAST(current_setting('autovacuum_vacuum_threshold') AS bigint)
         + (CAST(current_setting('autovacuum_vacuum_scale_factor') AS numeric)
            * pg_class.reltuples), '9G999G999G999') AS av_threshold,
     CASE
         WHEN CAST(current_setting('autovacuum_vacuum_threshold') AS bigint)
             + (CAST(current_setting('autovacuum_vacuum_scale_factor') AS numeric)
                * pg_class.reltuples) < psut.n_dead_tup
         THEN '*'
         ELSE ''
     END AS expect_av
 FROM pg_stat_user_tables psut
     JOIN pg_class on psut.relid = pg_class.oid
 ORDER BY 1;




 --  Identifying the critical tables for manually vacuum
 -- When you run the query once a day

select datname, age(datfrozenxid) from pg_database;

-- If you find the datfrozenxid is increasing then it means the auto vacuuming process is lagging behind. 
-- This will cause a transaction xid wrap around soon and will result in force shut down of the postgres.



/*
If you have a lot of random UPDATES, you may want to set the FILLFACTOR to something lower than 100, 
so that HOT updates have a chance to partially remove the need to vacuum altogether. 
*/


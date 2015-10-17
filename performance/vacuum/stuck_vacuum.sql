/*

There are basically two ways that VACUUM can get stuck.
It can block while attempting to acquire a heavyweight lock on the table, or it can block while attempting to obtain a cleanup lock on some block within the table.  

If it blocks attempting to obtain a heavyweight lock on the table,it will show up in pg_locks as waiting for a ShareUpdateExclusiveLock on on the table, and pg_locks can also tell you who else has a lock on the table.

When an autovacuum worker gets stuck, it means not only that the table the autovacuum worker was trying to process doesn't get vacuumed, but also that that autovacuum worker isn't available to vacuum anything else, either.

*/


--  Unfinished transactions
-- =======================
-- It turned out that the application had one component which connected to the database and opened a transaction right after startup, but never finished that transaction:

SELECT procpid, current_timestamp - xact_start AS xact_runtime, current_query
FROM pg_stat_activity ORDER BY xact_start;

procpid |  xact_runtime   |                                 current_query
---------+-----------------+-------------------------------------------------------------------------------
    1408 | 00:00:44.772041 | <IDLE> in transaction




--  Exclusive table locks
-- ======================    

/*
 A little bit of research revealed that autovacuum will abort if it is not able to obtain a table lock 
 within one second – and guess what: the application made quite heavy use of table locks.

 We found a hint that something suspicious is going on in the PostgreSQL log:
 postgres[13251]: [40-1] user=,db= ERROR:  canceling autovacuum task
*/


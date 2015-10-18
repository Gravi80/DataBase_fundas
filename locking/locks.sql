http://www.postgresql.org/docs/current/interactive/explicit-locking.html


/* 

Have you ever had one of those annoying problems where a query, or some kind of 
maintenance task such as vacuum, seems to hang, without making any discernable foreign progress, 
basically forever? 

It's probably the case that whatever you're trying to do is blocked waiting for some kind of lock.  
PostgreSQL supports several different kinds of locks.
*/


--  heavyweight locks (8 different modes)
-- ==================
INSERT INTO sample(id) VALUES ( generate_series(1,1000000));
select sum(1) from sample;

-- Then, in another window:
truncate sample;

/*
 The truncate will hang until the transaction that selected from that table commits.
 This is because the SELECT statement has obtained a lock on table sample. 
 It's a very lightweight sort of of lock - 
 it doesn't block any other process from reading data from sample, updating sample, creating indexes on sample, 
 vacuuming sample, or most other things that they might want to do.

 But it will block operations like TRUNCATE or DROP TABLE that would disrupt read-only queries against sample.
*/

-- Fortunately, this kind of problem is relatively easy to diagnose.  
-- Fire up psql, and check whether there are any rows in pg_locks where granted = false.  
-- If so, those processes are waiting on locks.
select * from pg_locks where granted=false;

-- You need to find out who has the conflicting lock and take appropriate steps to get that lock released
-- For most lock types, you can get this information from pg_locks, too:
-- look for locks on the same object that have granted = true.
select * from pg_locks where relation=(select relation from pg_locks where granted=false) and granted=true;





-- Below types of locks do not show up in pg_locks, and they also do not participate in deadlock detection. 
-- acquiring light weight and spinlocks much faster than acquiring a heavyweight lock


 --  lightweight locks (have only 2 modes) [shared lock and exclusive lock]
 -- ===================

/*
 If you see a process that's definitely stopped (it's not consuming any CPU or I/O resources) and not waiting for 
 a heavyweight lock, chances are good it's waiting for a lightweight lock.  

 Unfortunately, PostgreSQL does not have great tools for diagnosing such problems; 
 we probably need to work a little harder in this area.  

 The most typical problem with lightweight locks, however, is not that a process acquires one and sits on it, 
 blocking everyone else, but that the lock is heavily contended and there are a series of lockers who 
 slow each other down.Forward progress continues, but throughput is reduced.  

 Troubleshooting these situations is also difficult.  
 One common case that is often easily fixed is contention on WALWriteLock, which can occur if the value of 
 wal_buffers is too small, and can be remedied just by boosting the value.

*/




--  spin locks (have only 1 mode) [you either locked it, or you didn't]
-- ============

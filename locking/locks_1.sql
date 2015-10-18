-- Creating an index will block inserts and updates to the table.

-- Terminal 1
\set PROMPT1 '%`date +%Y%m%d-%H:%M:%S` (SESSION 1) %# '
BEGIN;
create index on sample(id);	


-- Terminal 2
\set PROMPT1 '%`date +%Y%m%d-%H:%M:%S` (SESSION 2) %# '
insert into sample values(11);


-- Terminal 3
select pid,locktype,relation,mode,granted from pg_locks where (relation = (select relid from pg_stat_user_tables where relname = 'sample') or relation is null);



-- Types of Locks:
-- ===============

--  1). Table-Level Locks
-- ----------------------
/*
 Remember that all these lock modes are table-level locks, even if the name contains the word "row";
 The names of the lock modes are historical.

 
 a). AcessShareLock : 
 			The table is locked for shared reading – many transactions can lock for reading concurrently.
 			It acquired automatically by a SELECT statement on the table or tables it retrieves from. 
     		This mode blocks ALTER TABLE, DROP TABLE, and  VACUUM (AccessExclusiveLock) on the same table.

 b). RowShareLock : 
 			A row is locked for shared reading.
 			It acquired automatically by a SELECT...FOR  UPDATE clause. 
 			It blocks concurrent ExclusiveLock and AccessExclusiveLock on the same table.    

 c). RowExclusiveLock: 
 			A row is locked for writing (INSERT, UPDATE, DELETE)
 			It acquired automatically by an UPDATE, INSERT, or DELETE command. 
 			It blocks ALTER TABLE, DROP TABLE, VACUUM, and CREATE INDEX commands 
 			(ShareLock, ShareRowExclusiveLock, ExclusiveLock, and AccessExclusiveLock) on the same table.

 d). ShareLock: 
 			It acquired automatically by a CREATE INDEX command. 
 			It blocks INSERT, UPDATE, DELETE, ALTER TABLE, DROP TABLE, and VACUUM commands. 
 			(RowExclusiveLock, ShareRowExclusiveLock, ExclusiveLock, and AccessExclusiveLock) on the same table.

 e). ShareRowExclusiveLock: 
 			This lock mode nearly identical to the ExclusiveLock, but which allows concurrent RowShareLock to 
 			be acquired.
 
 f). ExclusiveLock: 
			The table is locked for writing.

 			"Every transaction holds an exclusive lock on its transaction ID for its entire duration. 
 			If one transaction finds it necessary to wait specifically for another transaction, it does so by 
 			attempting to acquire share lock on the other transaction ID. That will succeed only when the 
 			other transaction terminates and releases its locks." (regards, tom lane). 
 			
 			ExclusiveLock blocks INSERT, UPDATE, DELETE, CREATE INDEX, ALTER TABLE, DROP TABLE, 
 			SELECT...FOR UPDATE and VACUUM commands on the table.
 			(RowShareLock,RowExclusiveLock, ShareLock, ShareRowExclusiveLock, ExclusiveLock, and AccessExclusiveLock)

 g). AccessExclusiveLock: 
 			It acquired automatically by a ALTER TABLE, DROP TABLE, or VACUUM command on the table it modifies.
 			This blocks any concurrent command or other lock mode from being acquired on the locked table. 			

*/

--  1). Row-Level Locks
-- ----------------------
/*

	Two types of row-level locking share and exclusive locks. Don't fall into confusion of LOCK naming, 
	you can differentiate row-lock and table-lock by the column 'lock_type' in pg_locks.

	a). Exclusive lock: 
				It is aquired automatically when a row hit by an update or delete. 
				Lock is held until a transaction commits or rollbacks. To manually acquiring exclusive-lock use 
				SELECT FOR UPDATE. 

	b). Share-Lock: 
				It is acquired when a row hit by an SELECT...FOR SHARE.


	Note: In either cases of row-level locks, data retreival is not at all effectied. 
	Row-level lock block Writers (ie., Writer will block the Writer).
	
*/




-- Exclusive locks prevent others from accessing the data until the lock has been released, 
-- and shared locks prevents exclusive locking until they are released.


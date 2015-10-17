-- Detecting table bloat
CREATE EXTENSION pgstattuple;

-- For a test we create a table and add some 10.000 rows to it on the fly:
CREATE TABLE t_test AS SELECT * FROM generate_series(1, 10000);

SELECT * FROM pgstattuple('t_test');

-[ RECORD 1 ]------+-------
table_len          | 368640
tuple_count        | 10000
tuple_len          | 280000
tuple_percent      | 75.95
dead_tuple_count   | 0
dead_tuple_len     | 0
dead_tuple_percent | 0
free_space         | 7380
free_percent       | 2

/*

As you can see the size of the table is somewhat over 368k. 
Our table has a fill grade of around 76%. Note that those numbers don’t add up to 100% completely. 
This is due to some overhead. In reality the fill grade of a freshly loaded table will be a lot higher than 
in our trivial single column case.

*/


-- To demonstrate table bloat we can delete some data. In this example we delete one third of those rows:

DELETE FROM t_test WHERE generate_series % 3 = 0;
-- DELETE 3333

SELECT * FROM pgstattuple('t_test');
-[ RECORD 1 ]------+-------
table_len          | 368640
tuple_count        | 10000
tuple_len          | 280000
tuple_percent      | 75.95
dead_tuple_count   | 0
dead_tuple_len     | 0
dead_tuple_percent | 0
free_space         | 7380
free_percent       | 2


/*

The first lesson here is that DELETE does not shrink a table on disk. It merely marks rows as dead. 
This is highly important – many people are misled by this behavior.
To reclaim the space occupied by those dead rows we can call VACUUM:
*/

VACUUM t_test;

SELECT * FROM pgstattuple('t_test');

-[ RECORD 1 ]------+-------
table_len          | 368640
tuple_count        | 6667
tuple_len          | 186676
tuple_percent      | 50.64
dead_tuple_count   | 0
dead_tuple_len     | 0
dead_tuple_percent | 0
free_space         | 114036
free_percent       | 30.93

-- This free space can now be used to store new rows inside your table.




-- The ctid is one of several hidden columns found in each PostgreSQL table.
-- and tells you two values: a page number, and a tuple number.

/*
 
 Pages are numbered sequentially from zero, starting with the first page in the relation's first file, 
 and ending with the last page in its last file.

 Tuple numbers refer to entries within each page, and are numbered sequentially starting from one.

*/

select ctid,* from t_test;

 ctid  | generate_series
--------+-----------------
 (0,1)  |               1
 (0,2)  |               2
 (0,4)  |               4
 (0,5)  |               5
 (0,7)  |               7
 (0,8)  |               8
 (0,10) |              10
 (0,11) |              11
 (0,13) |              13
 (0,14) |              14
(10 rows)


-- When I update a row, the row's ctid changes, because the update creates a new version of the row and leaves 
-- the old version behind

update t_test set generate_series=6 where generate_series=5;

 select ctid,* from t_test;	
   ctid  | generate_series
--------+-----------------
 (0,1)  |               1
 (0,2)  |               2
 (0,4)  |               4
 (0,6)  |               6
 (0,7)  |               7
 (0,8)  |               8
 (0,10) |              10
 (0,11) |              11
 (0,13) |              13
 (0,14) |              14

-- Note the changed ctid for the fourth row. 
-- If I vacuum this table now, I'll see it remove one dead row version, 
-- from both the table and its associated index:




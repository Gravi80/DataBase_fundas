 -- 	\timing   => will display timing after each query at client side


-- Explain => gives u information about how the query is been executed, 
-- 			  what is the plan/path the optimizer has taken to execute that query.

drop table if exists Student;

create table Student(sID int, sName text, GPA real, sizeHS int);

delete from Student;

  insert into Student values (123, 'Amy', 3.9, 1000);
  insert into Student values (234, 'Bob', 3.6, 1500);
  insert into Student values (345, 'Craig', 3.5, 500);
  insert into Student values (456, 'Doris', 3.9, 1000);
  insert into Student values (567, 'Edward', 2.9, 2000);
  insert into Student values (678, 'Fay', 3.8, 200);
  insert into Student values (789, 'Gary', 3.4, 800);
  insert into Student values (987, 'Helen', 3.7, 800);
  insert into Student values (876, 'Irene', 3.9, 400);
  insert into Student values (765, 'Jay', 2.9, 1500);
  insert into Student values (654, 'Amy', 3.9, 1000);
  insert into Student values (543, 'Craig', 3.4, 2000);

insert into Student select * from Student; -- do up to 6291456


EXPLAIN SELECT sName FROm Student;

/*

                            QUERY PLAN
------------------------------------------------------------------
 Seq Scan on student  (cost=0.00..102049.29 rows=6291129 width=5)


cost 0.00 => startup time, how long it takes to start that process 

102049.29 => max time , how much time it thinks it is going to take

6291129 => rows return, how many rows it thinks its going to return

width   => the size of the rows in bytes

*/





EXPLAIN SELECT sName FROm Student where sName='Gary';

-- only gives the query plan
/*
	
                           QUERY PLAN
-----------------------------------------------------------------
 Seq Scan on student  (cost=0.00..117777.11 rows=522793 width=5)
   Filter: (sname = 'Gary'::text)


*/





EXPLAIN(ANALYZE TRUE, TIMING FALSE) SELECT sName FROm Student where sName='Gary';

/*

                                         QUERY PLAN
----------------------------------------------------------------------------------------------
 Seq Scan on student  (cost=0.00..117777.11 rows=522793 width=5) (actual rows=524288 loops=1)
   Filter: (sname = 'Gary'::text)
   Rows Removed by Filter: 5767168
 Total runtime: 670.702 ms

*/




EXPLAIN ANALYZE SELECT sName FROm Student where sName='Gary';

-- actualy executes the query
/*

                            QUERY PLAN
------------------------------------------------------------------------------------------------------------------
 Seq Scan on student  (cost=0.00..117777.11 rows=522793 width=5) (actual time=0.064..658.674 rows=524288 loops=1)
   Filter: (sname = 'Gary'::text)
   Rows Removed by Filter: 5767168
 Total runtime: 683.569 ms


actual time=0.064 			=> startup time

658.674 					=> max time it thinks it will take 

rows=524288					=> rows return

Total runtime: 683.569 ms   => actual time it has taken

*/



-- Get Index Use Details

SELECT relname, 100 * idx_scan / (seq_scan + idx_scan) percent_of_times_index_used, n_live_tup rows_in_table  
FROM pg_stat_user_tables 
ORDER BY n_live_tup DESC;



-- Rough Guidlines

/*
  Cache hit ratio >= 99%
  Index hit ration >= 95%
  Where on > 10,000 rows
*/

/* total run time
   -----------------
  Page response times < 100ms
  Common queries < 10ms
  Rare queries < 100ms
*/



-- Show Slow Queries

SELECT 
  (total_time/1000/60) as total_minutes,
  (total_time/calls) as average_time,query
FROM  pg_stat_statements
ORDER BY 1 DESC
LIMIT 100;  

-- other postgres tools/links
/*
	auto_explain,pg_stat_statements

	http://feeding.cloud.geek.nz/posts/troubleshooting-postgres-performance/
	http://onewebsql.com/blog/monitoring-postgresql	
	http://www.westnet.com/~gsmith/content/postgresql/index.htm
  https://github.com/heroku/heroku-pg-extras
*/



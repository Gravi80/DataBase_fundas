-- http://www.postgresql.org/docs/devel/static/pgbench.html
-- part of the postgres contrib module and runs a benchmark test on PostgreSQL

/* pgbench is a simple program for running benchmark tests on PostgreSQL. 
It runs the same sequence of SQL commands over and over, possibly in multiple concurrent database sessions, 
and then calculates the average transaction rate (transactions per second). 

By default, pgbench tests a scenario that is loosely based on TPC-B, involving 
five SELECT, UPDATE, and INSERT commands per transaction. 
However, it is easy to test other cases by writing your own transaction script files.
*/


-- Typical output from pgbench looks like:
/*
transaction type: TPC-B (sort of)
scaling factor: 10
query mode: simple
number of clients: 10
number of threads: 1
number of transactions per client: 1000
number of transactions actually processed: 10000/10000
tps = 85.184871 (including connections establishing)
tps = 85.296346 (excluding connections establishing)

The first six lines report some of the most important parameter settings. 

The next line reports the number of transactions completed and intended 
(the latter being just the product of number of clients and number of transactions per client); 
these will be equal unless the run failed before completion. 
(In -T mode, only the actual number of transactions is printed.) 

The last two lines report the number of transactions per second, figured with and without counting 
the time to start database sessions.
*/


/*

The default TPC-B-like transaction test requires specific tables to be set up beforehand. 
pgbench should be invoked with the -i (initialize) option to create and populate these tables. 
*/

$ pgbench -i [ other-options ] dbname

/*
At the default "scale factor" of 1, the tables initially contain this many rows:

table                   # of rows
---------------------------------
pgbench_branches        1
pgbench_tellers         10
pgbench_accounts        100000
pgbench_history         0

*/

/*
You can increase the number of rows by using the -s (scale factor) option. 
The -F (fillfactor) option might also be used at this point.
*/
$ pgbench -i -s 2000 pgbench


-- You can run your benchmark with
pgbench [ options ] dbname
/*
In nearly all cases, you'll need some options to make a useful test. 
The most important options are 
-c (number of clients), 
-t (number of transactions), 
-T (time limit), and 
-f (specify a custom script file)

There are many more options like how long the test should last. 
If vacuum should run before the benchmark test or not, scale factor, select only tests etc. 
You can use any of those options to get the desired test results.
*/



-- Apart from the standard test using pgbench you can also use it to test some of your current queries:
---------------------------------------------------------------------------------------------------------
postgres@debian:~$pgbench -f testscript.sh test
/*
test script can have any production sql in there and pgbench will execute them and provide the 
time taken to run the statements.
*/




VACUUM needs SHARE UPDATE EXCLUSIVE access which is blocked by the lock level you are using.


INSERT INTO sample(id) VALUES ( generate_series(1,10));
create index on sample(id);
explain analyze select * from sample where id=2;

INSERT INTO sample(id) VALUES ( generate_series(11,100000000));


high load constantly locks the table and never lets VACUUM do its work.



Then let's make more autovac workers and have them check tables more often:

autovacuum_max_workers = 6
autovacuum_naptime = 15s


Let's lower the thresholds for auto-vacuum and auto-analyze to trigger sooner:

autovacuum_vacuum_threshold = 25
autovacuum_vacuum_scale_factor = 0.1

autovacuum_analyze_threshold = 10
autovacuum_analyze_scale_factor = 0.05 



Then let's make autovacuum less interruptable, so it completes faster, but at the cost of having a greater impact on concurrent user activity:

autovacuum_vacuum_cost_delay = 10ms
autovacuum_vacuum_cost_limit = 1000


 lowering the cost_delay to make vacuuming more aggressive.


that autovacuum parameters can be adjusted per table, which is almost always a better answer for needing to adjust autovacuum's behavior.



I can also test autovacuuming by using pgbench.

http://wiki.postgresql.org/wiki/Pgbenchtesting

High contention example :

Create bench_replication database

pgbench -i -p 5433 bench_replication
Run pgbench

pgbench -U postgres -p 5432 -c 64 -j 4 -T 600 bench_replication
Check autovacuuming status



vacuum not running run on indexes 

REINDEX INDEX indexname # recreate index explicitly
REINDEX TABLE tablename # recreate all indexes for this table


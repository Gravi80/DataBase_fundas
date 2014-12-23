-- Get Postgres Version
select version();

-- Get Postgres Config Location
SHOW config_file;

-- Get postgres location
select name, setting from pg_settings where name = 'data_directory';

--Restart Postgres In Mac

$pg_ctl restart -D /usr/local/var/postgres --Location which you got from above query


--Start Postgres
$pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start



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
*/


-- *************************** OR *************************************

SELECT 'index hit rate' as name,
        (sum(idx_blks_hit)-sum(idx_blks_read))/sum(idx_blks_hit+idx_blks_read) as ratio
FROM pg_statio_user_indexes
UNION ALL
SELECT 'cache hit rate' as name,
case  sum(idx_blks_hit)
  when 0 then 'NaN'::numeric
  else to_char((sum(idx_blks_hit)-sum(idx_blks_read))/sum(idx_blks_hit+idx_blks_read),'99.99')::numeric
end as ratio
FROM pg_statio_user_indexes;
 

/*

If you find yourself with a ratio significantly lower than 99% 
then you likely want to consider increasing the cache available to your 
database.

*/  


-- Find relation sizes in PostgreSQL

select
  n.nspname as "Schema",
  c.relname as "Name",
  case c.relkind
     when 'r' then 'table'
     when 'v' then 'view'
     when 'i' then 'index'
     when 'S' then 'sequence'
     when 's' then 'special'
  end as "Type",
  pg_catalog.pg_get_userbyid(c.relowner) as "Owner",
  pg_catalog.pg_size_pretty(pg_catalog.pg_relation_size(c.oid)) as "Size"
from pg_catalog.pg_class c
 left join pg_catalog.pg_namespace n on n.oid = c.relnamespace
where c.relkind IN ('r', 'v', 'i')
order by pg_catalog.pg_relation_size(c.oid) desc;


create encrypted password for user
------------------------------------

create user foo unencrypted password 'foopassword';
create user bar encrypted password 'foopassword';
select usename,passwd from pg_shadow where usename in ('postgres','foo','bar');


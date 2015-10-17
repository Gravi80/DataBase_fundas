-- cd pg_log

-- Get Postgres Version
select version();

-- Get Postgres Config Location
SHOW config_file;

select name,min_val, max_val, boot_val from pg_settings;


-- Get postgres location
select name, setting from pg_settings where name = 'data_directory';
-- cd $PGDATA

--Restart Postgres In Mac

$pg_ctl restart -D /usr/local/var/postgres --Location which you got from above query


--Start Postgres
$pg_ctl -D /usr/local/var/postgres -l /usr/local/var/postgres/server.log start


-- Reload config without restarting database
SELECT pg_reload_conf();


-- generate a series of numbers and insert it into a table
INSERT INTO numbers (num) VALUES ( generate_series(1,1000));
-- This inserts 1,2,3 to 1000 as thousand rows in the table numbers.



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





# find the largest table in the postgreSQL database?
SELECT relname, relpages FROM pg_class ORDER BY relpages DESC;
-- relname = name of the relation/table.
-- relpages = relation pages ( number of pages, by default a page is 8kb )




-- Find relation sizes in PostgreSQL

/*

\l+         => shows database size
\d+         => Show table sizes
\dti+       => shows both tables and indexes size

*/


SELECT
    table_name,
    pg_size_pretty(table_size) AS table_size,
    pg_size_pretty(indexes_size) AS indexes_size,
    pg_size_pretty(total_size) AS total_size
FROM (
    SELECT
        table_name,
        pg_table_size(table_name) AS table_size,
        pg_indexes_size(table_name) AS indexes_size,
        pg_total_relation_size(table_name) AS total_size
    FROM (
        SELECT ('"' || table_schema || '"."' || table_name || '"') AS table_name
        FROM information_schema.tables where table_schema = 'public'
    ) AS all_tables
    ORDER BY total_size DESC
) AS pretty_sizes;



SELECT relname as "Table",
pg_size_pretty(pg_total_relation_size(relid)) As "Size",
pg_size_pretty(pg_total_relation_size(relid) - pg_relation_size(relid)) as "External Size"
FROM pg_catalog.pg_statio_user_tables 
ORDER BY pg_total_relation_size(relid) DESC;



SELECT pg_size_pretty(pg_relation_size('public.wagers')) relation_size, pg_size_pretty(pg_table_size('public.wagers')) table_size;

/*

pg_table_size = 
pg_relation_size = measures the size of the actual table 
pg_total_relation_size = includes both the table and all its toasted tables and indexes.

*/


-- How to determine the size of a database on disk
SELECT pg_size_pretty(pg_database_size('somedatabase')) As fulldbsize;




-- Index size/usage statistics
SELECT
    t.tablename,
    indexname,
    c.reltuples AS num_rows,
    pg_size_pretty(pg_relation_size(quote_ident(t.tablename)::text)) AS table_size,
    pg_size_pretty(pg_relation_size(quote_ident(indexrelname)::text)) AS index_size,
    CASE WHEN indisunique THEN 'Y'
       ELSE 'N'
    END AS UNIQUE,
    idx_scan AS number_of_index_scans,
    idx_tup_read AS tuples_read,
    idx_tup_fetch AS tuples_fetched
FROM pg_tables t
LEFT OUTER JOIN pg_class c ON t.tablename=c.relname
LEFT OUTER JOIN
    ( SELECT c.relname AS ctablename, ipg.relname AS indexname, x.indnatts AS number_of_columns, idx_scan, idx_tup_read, idx_tup_fetch, indexrelname, indisunique FROM pg_index x
           JOIN pg_class c ON c.oid = x.indrelid
           JOIN pg_class ipg ON ipg.oid = x.indexrelid
           JOIN pg_stat_all_indexes psai ON x.indexrelid = psai.indexrelid )
    AS foo
    ON t.tablename = foo.ctablename
WHERE t.schemaname='public'
ORDER BY 1,2;



create encrypted password for user
------------------------------------

create user foo unencrypted password 'foopassword';
create user bar encrypted password 'foopassword';
select usename,passwd from pg_shadow where usename in ('postgres','foo','bar');


-- Storing the password after encryption.
SELECT crypt ( 'sathiya', gen_salt('md5') );

/*

PostgreSQL crypt function Issue:

The postgreSQL crypt command may not work on your environment and display the following error message.

ERROR:  function gen_salt("unknown") does not exist
HINT:  No function matches the given name and argument types.
         You may need to add explicit type casts.
PostgreSQL crypt function Solution:

To solve this problem, install the postgresql-contrib-your-version package and execute the following command in the postgreSQL prompt.

# \i /usr/share/postgresql/8.1/contrib/pgcrypto.sql

*/


-- Bulk update
update online_attributes set user_id = c.user_id from (values(3946, 1),(3947, 2)) as c(player_id, user_id) where c.player_id = online_attributes.person_id;



select relname, last_vacuum, last_analyze from pg_stat_all_tables where schemaname = 'public';

\d pg_stats

SELECT * FROM pg_stats WHERE tablename = 'products' AND attname = 'selection_type';


EXPLAIN (FORMAT JSON) SELECT * FROM users;

Here is the same plan with costs suppressed:
EXPLAIN (COSTS FALSE) SELECT * FROM foo WHERE i = 4;



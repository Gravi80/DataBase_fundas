-- Get Index Use Details

SELECT relname, 100 * idx_scan / (seq_scan + idx_scan) percent_of_times_index_used, n_live_tup rows_in_table  
FROM pg_stat_user_tables 
ORDER BY n_live_tup DESC;

-- To generate a list of your tables in your database with the largest 
-- ones first and the percentage of time which they use an index you can run:

SELECT 
  relname, 
  100 * idx_scan / (seq_scan + idx_scan) percent_of_times_index_used, 
  n_live_tup rows_in_table
FROM 
  pg_stat_user_tables
WHERE 
    seq_scan + idx_scan > 0 
ORDER BY 
  n_live_tup DESC;



-- We can add our index concurrently to prevent locking on that table 
/*

If you’re adding an index on a production database use 
CREATE INDEX CONCURRENTLY 
to have it build your index in the background and 
not hold a lock on your table. 

The limitation to creating indexes concurrently is they can typically 
take 2-3 times longer to create and can’t be run within a transaction. 

*/

CREATE INDEX CONCURRENTLY index_name ON table_name(column_name);


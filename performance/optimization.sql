show work_mem;

set work_mem = '10MB';


set seq_page_cost = 0.1;

set random_page_cost = 0.1;

updates statistics
====================
vacuum full analyze narrow_table;
vacuum analyze wagers;
ALTER TABLE articles ALTER article_text SET STATISTICS 500;


cluster "wagers" using "index_wagers_on_competition_id"; => rearranges data on disk
-- If CLUSTER is that slow, it really seems to be an io problem, and the data does not seem to match the index at all.
-- the cluster operation is a one off process that rearranged the data on disk. 
-- The intent is to get your 2000 results rows from fewer disk blocks.

 -- I'd recommend reloading it, in a pattern closer to how it will be loaded as it is generated. 
 -- I imagine that the data is generated one day at a time, which will effectively result in strong correlation 
 -- between DateID and the location on disk. If that is the case, then I'd either cluster by DateID, or split your 
 -- test data into 365 separate loads, and reload it.



In Query Plan
"Sort Method: external merge  Disk: 12288kB"
indicates, that your work_mem is low.




planner prefers BitmapIndexScans in cases when index is there but it lacks stats.


You have to find a combination of work_mem, cpu_tuple_cost, random_page_cost, seq_page_cost that works well for your system.


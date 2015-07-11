-- Found this on StackOverflow

-- I'm testing out the PostgreSQL Text-Search features, using the September 2009 
-- data dump from StackOverflow as sample data.


-- The naive approach of using LIKE predicates or POSIX regular expression matching to search 
-- 1.2 million rows takes about 90-105 seconds (on my Macbook) to do a full table-scan searching for a keyword.

SELECT * FROM Posts WHERE body LIKE '%postgresql%';
SELECT * FROM Posts WHERE body ~ 'postgresql';


-- An unindexed, ad hoc text-search query takes about 8 minutes:

SELECT * FROM Posts WHERE to_tsvector(body) @@ to_tsquery('postgresql');



-- Creating a GIN index takes about 40 minutes:

ALTER TABLE Posts ADD COLUMN PostText TSVECTOR;
UPDATE Posts SET PostText = to_tsvector(body);
CREATE INDEX PostText_GIN ON Posts USING GIN(PostText);


-- Afterwards, a query assisted by a GIN index runs a lot faster -- this takes about 40 milliseconds:

SELECT * FROM Posts WHERE PostText @@ 'postgresql';





-- However, when I create a GiST index, the results are quite different. It takes less than 2 minutes to create the index:

CREATE INDEX PostText_GIN ON Posts USING GIST(PostText);


/*
Afterwards, a query using the @@ text-search operator takes 90-100 seconds. 
So GiST indexes do improve an unindexed TS query from 8 minutes to 1.5 minutes. 
But that's no improvement over doing a full table-scan with LIKE. 
*/



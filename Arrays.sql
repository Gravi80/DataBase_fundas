CREATE TABLE article(
	id integer primary key,
	name text,
	tags text[]
);

INSERT into article VALUES(1,'Ruby Programming language','{"ruby","programming"}');
INSERT into article VALUES(2,'Learn Java the hard way','{"Java","programming"}');
INSERT into article VALUES(3,'Vedic Maths','{"vedic","maths"}');

-- You can use the set of operators to query array
/*

	A @> B 		 =>  A contains all of B, and order doesn't matter
	A && B		 =>	 A overlaps any of B i.e if any of the element in A or B are shared we will get back true

*/


-- find all article which are of ruby or programming
SELECT name,tags FROM article
WHERE tags && ARRAY['ruby','programming'];

┌───────────────────────────┬────────────────────┐
│           name            │        tags        │
├───────────────────────────┼────────────────────┤
│ Ruby Programming language │ {ruby,programming} │
│ Learn Java the hard way   │ {Java,programming} │
└───────────────────────────┴────────────────────┘



-- find all article which are both of ruby and programming
SELECT name,tags FROM article
WHERE tags @> ARRAY['ruby','programming'];

┌───────────────────────────┬────────────────────┐
│           name            │        tags        │
├───────────────────────────┼────────────────────┤
│ Ruby Programming language │ {ruby,programming} │
└───────────────────────────┴────────────────────┘





-- Materialized Paths (Heirarchy)
-- ==============================

-- Encode the own id and parent ids of each record in its path i.e path will contain
-- ids of its parent

CREATE TABLE clubs(
	id integer primary key,
	name text,
	path integer[]
);

INSERT into clubs values(1,'North America League','{1}');
INSERT into clubs values(2,'Eastern Division','{1,2}');
INSERT into clubs values(3,'Western Division','{1,3}');
INSERT into clubs values(4,'New York Quillers','{1,2,4}');
INSERT into clubs values(5,'Boston Spine Fancy','{1,2,5}');
INSERT into clubs values(6,'Cascadia Hog Friends','{1,3,6}');
INSERT into clubs values(7,'California High Society','{1,3,7}');


/*

The depth of each club is simply the length of its path.

array_length(array,dim) returns the length of array.
dim will always be 1 unless u r using multidimensional array.

*/

-- Display the top two tiers clubs

SELECT name,path,array_length(path,1) as depth
FROM clubs
WHERE array_length(path,1)<=2
ORDER BY path;

┌──────────────────────┬───────┬───────┐
│         name         │ path  │ depth │
├──────────────────────┼───────┼───────┤
│ North America League │ {1}   │     1 │
│ Eastern Division     │ {1,2} │     2 │
│ Western Division     │ {1,3} │     2 │
└──────────────────────┴───────┴───────┘

-- Find All the clubs that are children of the Eastern Division

/*
	we need to look for all records who have Eastern Division id
	in there path array.
*/
SELECT id,name,path from clubs
WHERE path && ARRAY[2]
ORDER BY path;

┌────┬────────────────────┬─────────┐
│ id │        name        │  path   │
├────┼────────────────────┼─────────┤
│  2 │ Eastern Division   │ {1,2}   │
│  4 │ New York Quillers  │ {1,2,4} │
│  5 │ Boston Spine Fancy │ {1,2,5} │
└────┴────────────────────┴─────────┘

-- Find PArent of the California High Society
SELECT name,path from clubs
WHERE ARRAY[id] && ARRAY[1,3,7]  --We are wrapping id as an array so that we can use the overlaps operator
ORDER BY path;

-- which records overlaps with California High Society path
┌─────────────────────────┬─────────┐
│          name           │  path   │
├─────────────────────────┼─────────┤
│ North America League    │ {1}     │
│ Western Division        │ {1,3}   │
│ California High Society │ {1,3,7} │
└─────────────────────────┴─────────┘



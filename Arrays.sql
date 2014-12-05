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


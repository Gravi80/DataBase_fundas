/*

Two Important Data Type
==========================
tsvector => Text Search Vector, represent the text that has been pre-processed for postgres to search.
tsquery  => represents search query

*/


/*
There are two main function that converts string into these types:
=================================================================

to_tsvector(configuration,text) => creates a normalized tsvector.It parses 
									a textual document into tokens, 
									reduces the tokens to lexemes, 
									and returns a tsvector which lists 
									the lexemes together with their 
									positions in the document.

to_tsquery(configuration,text) and plainto_tsquery(configuration,text) =>
									for converting a query to the normalized 
									tsquery data type.


configuration = search configuration , like english 

text => you want to convert into the vector to be searched or the query to 
		be doing search on a vector.

*/


/*
Operators
==========

	Vectors:
		V @@ Q 			=> search V for Q

	Queries:
		V @@ (A && B)	=> Searches V for A and B
		V @@ (A || B)	=> Searches V for A or B


*/


create database demo;

/* Full Text Search */

/*
	Stemming
	Ranking / Boost
	Support Multiple languages
	Fuzzy search for mispelling
	Accent support
*/
create table blog(id serial,comments varchar,author varchar,comment_tsvector tsvector);
DROP TEXT SEARCH DICTIONARY if exists english_stem_nostop cascade;

CREATE TEXT SEARCH DICTIONARY english_stem_nostop (
    Template = snowball,
    Language = english
);

CREATE TEXT SEARCH CONFIGURATION public.english_nostop ( COPY = pg_catalog.english );

ALTER TEXT SEARCH CONFIGURATION public.english_nostop ALTER MAPPING FOR asciiword, asciihword, hword_asciipart, hword, hword_part, word WITH english_stem_nostop;

DROP TRIGGER tsvectorupdate ON blog;

CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE ON blog FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('comment_tsvector', 'public.english_nostop', 'comments');

-- CREATE TRIGGER tsvectorupdate BEFORE INSERT OR UPDATE ON blog FOR EACH ROW EXECUTE PROCEDURE tsvector_update_trigger('comment_tsvector', 'pg_catalog.english', 'comments');


insert into blog values(1,'Managing test data and/or mocks','Hugo Firth');
insert into blog values(2,'Is ruby still cool these days?','Sarah Taraporewalla');
insert into blog values(3,'Why Ruby?','CODING HORROR');
insert into blog values(4,'Be a Ruby on Rails programmer','Ravi Sharma');
insert into blog values(5,'Managing test data and/or mocks','Robin Sharma');
insert into blog values(6,'A programmer life','http://aprogrammerslife.info/');
insert into blog values(7,'Nobody Wants to Learn How to Program',' Al Sweigart');
insert into blog values(8,'The Shortest Crashing C Program','Jesper');
insert into blog values(9,'Cool notification messages with CSS3 & jQuery','Red Team Design');
insert into blog values(10,'What are the lesser known but useful data structures?','Robert Harvey');
insert into blog values(11,'Introduction to datastructure in C','Robin Kumar');	
insert into blog values(12,'Introduction to C','Sam Firth');
insert into blog values(13,'Microservices - 72 resources','PAWEL PACANA');
insert into blog values(14,'Rails Unfit for Microservices?','Billy Yarosh');
insert into blog values(15,'Getting Started with jQuery Mobile & Rails 3','fuel your coding');
insert into blog values(16,'Ruby on Rails Programming language','fuel your coding');	


SELECT id,comments  FROM blog where comments @@ to_tsquery('Program');

SELECT id,comments,ts_rank(comment_tsvector, plainto_tsquery('english_nostop','Ruby'), 1 ) AS rank FROM blog where comments @@ to_tsquery('Ruby');

SELECT id,comments,ts_rank_cd(comment_tsvector, plainto_tsquery('english_nostop','Ruby'), 1 ) AS rank FROM blog where comments @@ to_tsquery('Ruby');

SELECT id,comments,ts_rank(comment_tsvector, plainto_tsquery('english_nostop','Ruby,Rails'), 1 ) AS rank FROM blog WHERE to_tsvector('english_nostop', COALESCE(comments,'') || ' ' || COALESCE(comments,'')) @@ to_tsquery('english_nostop','Ruby') group by id,comments,comment_tsvector order by rank desc;

/************************************************ OR **************************************************/

drop table blog;
create table blog(id serial,comments varchar,author varchar);
-- insert all values 

-- At this stage our comments is simply a long string and this doesn't help us; 
-- we need to transform it into the right format via the function to_tsvector().
SELECT to_tsvector('Try not to become a man of success, but rather try to become a man of value');

-- Something weird just happened. First there are less words than in the original sentence,
 -- some of the words are different (try became tri) and they are all followed by numbers. Why?

-- A tsvector value is a sorted list of distinct lexemes which are words that have been normalized 
-- to make different variants of the same word look alike. 
-- For example, normalization almost always includes folding upper-case letters to lower-case and 
-- often involves removal of suffixes (such as 's', 'es' or 'ing' in English). 
-- This allows searches to find variant forms of the same word without tediously entering 
-- all the possible variants.

-- The numbers represent the location of the lexeme in the original string. 
-- For example, "man" is present at position 6 and 15.
--The reason these positions are important because of the relivancy ranking


-- For running a query against a tsvector we can use the @@ operator


SELECT id,to_tsvector(comments)  FROM blog where comments @@ to_tsquery('Program');
select id,comments from(SELECT id,comments,to_tsvector(comments) as comments_vector  FROM blog) blogs where comments @@ to_tsquery('Programmer,Life');
select id,comments from(SELECT id,comments,to_tsvector(comments) as comments_vector  FROM blog) blogs where comments @@ to_tsquery('program|life');
select id,comments from(SELECT id,comments,to_tsvector(comments) as comments_vector  FROM blog) blogs where comments @@ to_tsquery('Programming');


-- A tsquery value stores lexemes that are to be searched for, and combines them honoring the Boolean operators & (AND), | (OR), and ! (NOT). Parentheses can be used to enforce grouping of the operators




-- **************************** Example 2 **********************************

CREATE TABLE comments(
	id integer primary key,
	user_id integer,
	body text
);


INSERT into comments values(1,1,'lets enjoye studying maths');
INSERT into comments values(2,1,'enjoyed fullest');
INSERT into comments values(3,1,'enjoying in the garden');
INSERT into comments values(4,2,'Rain Rain come Again');
INSERT into comments values(5,2,'cat');
INSERT into comments values(6,2,'catapult');
INSERT into comments values(7,2,'cataclysmic');
INSERT into comments values(8,2,'octocat');
INSERT into comments values(9,2,'scatter');
INSERT into comments values(10,2,'prognosticate');
INSERT into comments values(11,1,'What brand of oil do you use? Have you tried QuillSwill?');


-- Find comments about "enjoying" something

-- V @@ Q 			=> search V for Q

SELECT body
FROM comments
WHERE to_tsvector('english',body)
	@@ to_tsquery('english','enjoying');

┌────────────────────────────┐
│            body            │
├────────────────────────────┤
│ lets enjoye studying maths │
│ enjoyed fullest            │
│ enjoying in the garden     │
└────────────────────────────┘

/*
 we gonna prepare the body of our comment by calling to_tsvector() on it 
 with english search configuration.
 then we gonna query that for the query term 'enjoying'
*/

-- Search Anything starting with cat
-- tsquery only supports wildcard only end of a term

SELECT body
FROM comments
WHERE to_tsvector('english',body)
	@@ to_tsquery('english','cat:*');

┌─────────────┐
│    body     │
├─────────────┤
│ cat         │
│ catapult    │
│ cataclysmic │
└─────────────┘

but do not : octocat,scatter,prognosticate



-- Find Comments containing the term "oil" , and a word starting with "quil"
SELECT body	
FROM comments
WHERE to_tsvector('english',body)
@@ (to_tsquery('english','oil') && to_tsquery('english','quil:*')
);

┌──────────────────────────────────────────────────────────┐
│                           body                           │
├──────────────────────────────────────────────────────────┤
│ What brand of oil do you use? Have you tried QuillSwill? │
└──────────────────────────────────────────────────────────┘






-- Index
-- =========
/*
	Create Index blog_indx ON blog using GIN(comment_tsvector);
	
	The Gin Index is a special index for multivalued like
	a text[] or a tsvector.

	two basic type of index used for full text search GIN and GIST.
	GIN takes a little bit longer time to build the index but performance on queries is better.

*/


-- CREATE an index on the function call to_tsvector('english',body)

CREATE INDEX comments_gin_index
ON comments
USING gin(to_tsvector('english',body));


/*

Flow 
=====
each "Text" is parsed into tokens(word,numbers,paths,email-address) ==> 
each token is then normalised with dictionaries(case-folding(words will get folded to lower case) ,stemming(words will be stemmed),thesauri,stop words(will be removed)) ===>
text search vector(ts_vector) for the "Text" is created.


*/

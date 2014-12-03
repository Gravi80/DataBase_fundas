-- tsvector => Text Search Vector
-- to_tsvector parses a textual document into tokens, reduces the tokens to lexemes, and returns a tsvector which lists the lexemes together with their positions in the document.

-- to_tsquery and plainto_tsquery for converting a query to the tsquery data type.



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



-- Index
-- =========
/*
	Create Index blog_indx ON blog using GIN(comment_tsvector);

	two basic type of index used for full text search GIN and GIST.
	GIN takes a little bit longer time to build the index but performance on queries is better.

*/

/*

Flow 
=====
each "Text" is parsed into tokens(word,numbers,paths,email-address) ==> 
each token is then normalised with dictionaries(case-folding(words will get folded to lower case) ,stemming(words will be stemmed),thesauri,stop words(will be removed)) ===>
text search vector(ts_vector) for the "Text" is created.


*/

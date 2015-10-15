CREATE TABLE clubs (
id integer primary key, 
name text,
path integer[]
);


Insert into clubs values(1,'North American League','{1}');
	Insert into clubs values(2,'Eastern Division','{1,2}');
		Insert into clubs values(4,'New York Quillers','{1,2,4}');
		Insert into clubs values(5,'Boston Spine Fancy','{1,2,5}');
	Insert into clubs values(3,'Western Division','{1,3}');
		Insert into clubs values(6,'Cascadia Hog Friends','{1,3,6}');
		Insert into clubs values(7,'California Hedge Society','{1,3,7}');
			Insert into clubs values(8,'Real Hogs of the OC','{1,3,7,8}');
			Insert into clubs values(12,'Hipster Hogs','{1,3,7,12}');




-- The depth of each club is simply the length of its path.
-- array_length(array,dim) returnsthelengthofthearray
-- dim will always be 1 unless you are using multidimensional arrays.

select name,path,array_length(path,1) as depth_of_club from clubs;


-- Display the top two tiers of hedgehog clubs:
select name,path,array_length(path,1) as depth_of_club from clubs where array_length(path,1) <=2;



-- Find all the clubs that are children of the California Hedge Society, ID: 7.

SELECT id, name, path FROM clubs WHERE path && ARRAY[7] ORDER BY path;


-- Find all the clubs that are children of the Western Division, ID: 3.

SELECT id, name, path FROM clubs WHERE path && ARRAY[3] ORDER BY path;




-- Find the parents of the California Hedge Society, Path: ARRAY[1,3,7]

SELECT name, path FROM clubs WHERE ARRAY[id] && ARRAY[1,3,7] ORDER BY path;
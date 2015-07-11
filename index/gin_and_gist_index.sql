-- GiST (Generalized Search Tree)-based index.
-- GIN (Generalized Inverted Index)-based index.

-- There are two kinds of indexes that can be used to speed up full text searches.

CREATE INDEX name ON table USING gist(column);
-- Creates a GiST (Generalized Search Tree)-based index. The column can be of tsvector or tsquery type.

CREATE INDEX name ON table USING gin(column);
-- Creates a GIN (Generalized Inverted Index)-based index. The column must be of tsvector type.


/* 

A GiST index is lossy, meaning that the index may produce false matches, 
and it is necessary to check the actual table row to eliminate such false matches.

Lossiness causes performance degradation due to unnecessary fetches of table records that turn out 
to be false matches. Since random access to table records is slow, this limits the usefulness of 
GiST indexes. The likelihood of false matches depends on several factors, in particular the number 
of unique words, so using dictionaries to reduce this number is recommended.

*/




/* 
http://www.cybertec.at/gin-just-an-index-type/

GIN indexes are not lossy for standard queries, but their performance depends logarithmically 
on the number of unique words. 
(However, GIN indexes store only the words (lexemes) of tsvector values, and not their weight labels. 
Thus a table row recheck is needed when using a query that involves weights.)


Internally, a GIN index contains a B-tree index constructed over keys, where each key is an element 
of one or more indexed items (a member of an array, for example) and where each tuple in a leaf page 
contains either a pointer to a B-tree of heap pointers (a "posting tree"), or a simple list of heap 
pointers (a "posting list") when the list is small enough to fit into a single index tuple along 
with the key value.

Updating a GIN index tends to be slow because of the intrinsic nature of inverted indexes: 
inserting or updating one heap row can cause many inserts into the index 
(one for each key extracted from the indexed item).


*/




/*

In choosing which index type to use, GiST or GIN, consider these performance differences:

1). GIN index lookups are about three times faster than GiST

2). GIN indexes take about three times longer to build than GiST

3). GIN indexes are moderately slower to update than GiST indexes, 
	but about 10 times slower if fast-update support was disabled.

4). GIN indexes are two-to-three times larger than GiST indexes.


*/





/* 
As a rule of thumb, GIN indexes are best for static data because lookups are faster. 
For dynamic data, GiST indexes are faster to update. 
Specifically, GiST indexes are very good for dynamic data and fast if the number of unique words 
(lexemes) is under 100,000, while GIN indexes will handle 100,000+ lexemes better but are slower 
to update.
*/



-- Note that GIN index build time can often be improved by increasing maintenance_work_mem, 
-- while GiST index build time is not sensitive to that parameter.


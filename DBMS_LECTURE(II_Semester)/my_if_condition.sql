create table tbl_boats2 as select * from tbl_boats;
drop table tbl_boats2;

CREATE OR REPLACE FUNCTION truncate_table()
RETURNS VOID
AS
$_$
BEGIN
    IF ( (select count(1) from tbl_boats2) <> 0) THEN
    	RAISE NOTICE 'Came Here';
    	TRUNCATE TABLE tbl_boats2;
    END IF;
END;
$_$
LANGUAGE 'plpgsql';




CREATE OR REPLACE FUNCTION truncate_table()
RETURNS VOID
AS
$_$
BEGIN
    IF(exists(select count(1) from tbl_boats2)) THEN
    	RAISE NOTICE 'Came Here';
    	TRUNCATE TABLE tbl_boats2;
    END IF;
END;
$_$
LANGUAGE 'plpgsql';


exists => will return true even when query is returning 0 value




CREATE OR REPLACE FUNCTION get_boat_name(
	boat_id int
)
RETURNS VARCHAR
AS
$_$
DECLARE
    boat_name varchar;
BEGIN
    SELECT bname INTO boat_name FROM tbl_boats WHERE bid=boat_id;
    RETURN boat_name;
END;
$_$
LANGUAGE 'plpgsql';




/* declare same dataType as the column of a Table */


CREATE OR REPLACE FUNCTION get_boat_name(
	boat_id int
)
RETURNS VARCHAR
AS
$_$
DECLARE
    boat_name tbl_boats.bname%Type;
BEGIN
    SELECT bname INTO boat_name FROM tbl_boats WHERE bid=boat_id;
    RETURN boat_name;
END;
$_$
LANGUAGE 'plpgsql';



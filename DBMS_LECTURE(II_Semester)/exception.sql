CREATE OR REPLACE FUNCTION insert_into_tbl_boats ( 
	boat_id int,boat_name varchar(30),color varchar(30)
)
RETURNS VOID
AS
$_$
BEGIN	
	INSERT into tbl_boats values(boat_id,boat_name,color);
	EXCEPTION
	WHEN unique_violation THEN 
	RAISE NOTICE 'Same boat_id not allowed';
END;	
$_$
language 'plpgsql';



/* GENERIC */

CREATE OR REPLACE FUNCTION insert_into_tbl_boats ( 
	boat_id int,boat_name varchar(30),color varchar(30)
)
RETURNS VOID
AS
$_$
BEGIN	
	INSERT into tbl_boats values(boat_id,boat_name,color);
	EXCEPTION
	WHEN others THEN 
	RAISE NOTICE 'Same boat_id not allowed';
END;	
$_$
language 'plpgsql';
CREATE OR REPLACE FUNCTION cursor_function ( )
RETURNS VOID
AS
$_$
DECLARE
cursor_name CURSOR FOR
SELECT * FROM tbl_boats;	
boatid int;
boat_name VARCHAR(30);
boat_color VARCHAR(30);
BEGIN	
OPEN cursor_name;
LOOP
FETCH cursor_name INTO boatid,boat_name,boat_color ;
IF NOT FOUND THEN EXIT;
END IF;
RAISE NOTICE 'Boat Name %',boat_name;
END LOOP;
CLOSE cursor_name;
END;	
$_$
language 'plpgsql';



CREATE OR REPLACE FUNCTION cursor_function ( )
RETURNS VOID
AS
$_$
DECLARE
id int;
cursor_name CURSOR FOR
SELECT * FROM tbl_boats where bid=id;	
boatid int;
boat_name VARCHAR(30);
boat_color VARCHAR(30);
BEGIN	
id = 101;
OPEN cursor_name;
LOOP
FETCH cursor_name INTO boatid,boat_name,boat_color ;
IF NOT FOUND THEN EXIT;
END IF;
RAISE NOTICE 'Boat Name %',boat_name;
END LOOP;
CLOSE cursor_name;
END;	
$_$
language 'plpgsql';	
	



create or replace function printer()
returns void
as
$_$

declare

cor2 cursor(id int) is 
select * from tbl_boats where bid=id;

boatid int;
boatname varchar(30);
boatcolor varchar(30);

begin
 open cor2(101);
 loop
    fetch cor2 into boatid,boatname,boatcolor;
    if not found then
    exit;
    end if;
    raise notice 'boat name : %',boatname;
    end loop;
    close cor2;
    end;
$_$
language 'plpgsql';	






CREATE OR REPLACE FUNCTION cursor_function ( )
RETURNS VOID
AS
$_$
DECLARE
cursor_name REFCURSOR;
boatid int;
boat_name VARCHAR(30);
boat_color VARCHAR(30);

sailorid int;
sailor_name VARCHAR(30);
BEGIN	

OPEN cursor_name FOR
SELECT * FROM tbl_boats;	
LOOP
FETCH cursor_name INTO boatid,boat_name,boat_color ;
IF NOT FOUND THEN EXIT;
END IF;
RAISE NOTICE 'Boat Name %',boat_name;
END LOOP;
CLOSE cursor_name;

OPEN cursor_name FOR
SELECT sid,sname FROM tbl_sailors;	
LOOP
FETCH cursor_name INTO sailorid,sailor_name;
IF NOT FOUND THEN EXIT;
END IF;
RAISE NOTICE 'Sailor Name %',sailor_name;
END LOOP;
CLOSE cursor_name;

END;	
$_$
language 'plpgsql';




/* Move Cursors from one function to another */
/* phases in cursor---->	DECLARE
							OPEN      => results will be populted
							FETCH
							CLOSE
*/


CREATE OR REPLACE FUNCTION refcursor_function(v1 REFCURSOR) 
 RETURNS REFCURSOR
AS
$_$
BEGIN
 OPEN v1 FOR
 SELECT * FROM tbl_boats;
 RETURN v1;
END;	
$_$
language 'plpgsql';


-- begin;
-- SELECT function_name('ref1');
-- FETCH ALL FROM ref1;
-- COMMIT;


CREATE OR REPLACE FUNCTION call_refcursor_function() 
 RETURNS VOID
AS
DECLARE
 ref1 REFCURSOR;
$_$
BEGIN
	SELECT refcursor_function(ref1);
	FETCH ALL IN ref1;
END;	
$_$
language 'plpgsql';	




	

CREATE OR REPLACE FUNCTION refcursor_function() 
 RETURNS REFCURSOR
AS
$_$
DECLARE
  v1 REFCURSOR;
BEGIN
 OPEN v1 FOR
 SELECT * FROM tbl_boats;
 RETURN v1;
END;	
$_$
language 'plpgsql';	


begin;
SELECT refcursor_function();   => will give  <unnamed portal 1>  , this is system defined cursor
FETCH ALL FROM ref1;         
COMMIT;


begin;
SELECT refcursor_function();
FETCH ALL IN "<unnamed portal 1>";         
COMMIT;




/* FOR record_variable cursor-name */       /*  => will take care of  OPEN FETCH CLOSE  */

CREATE OR REPLACE FUNCTION cursor_function ( )
RETURNS VOID
AS
$_$
DECLARE
cursor_name CURSOR FOR
SELECT * FROM tbl_boats;	
record_variable RECORD;
BEGIN	
FOR record_variable in cursor_name
LOOP
RAISE NOTICE 'Boat Name %',record_variable.bname;
END LOOP;
END;	
$_$
language 'plpgsql';





/* Return Multiple  values */

CREATE OR REPLACE FUNCTION cursor_function_returning_mutiple_values ( )
RETURNS SETOF INT
AS
$_$
DECLARE
cursor_name CURSOR FOR
SELECT bid FROM tbl_boats;	
record_variable RECORD;
BEGIN	
FOR record_variable in cursor_name
LOOP
	RETURN NEXT record_variable.bid;
END LOOP;
END;	
$_$
language 'plpgsql';


select cursor_function_returning_mutiple_values();  => /* record Object */
select * from cursor_function_returning_mutiple_values();  => /* table Object */



CREATE OR REPLACE FUNCTION cursor_function_returning_table ( )
RETURNS SETOF TBL_BOATS
AS
$_$
DECLARE
cursor_name CURSOR FOR
SELECT * FROM tbl_boats;	
record_variable RECORD;
BEGIN	
FOR record_variable in cursor_name
LOOP
	RETURN NEXT record_variable;
END LOOP;
END;	
$_$
language 'plpgsql';



/* if don't want to iterate and no processing, a single select and u want to return set of all result */

CREATE OR REPLACE FUNCTION cursor_function_returning_table2 ( )
RETURNS SETOF TBL_BOATS
AS
$_$
BEGIN	
	RETURN query select * from tbl_boats;
END;	
$_$
language 'plpgsql';



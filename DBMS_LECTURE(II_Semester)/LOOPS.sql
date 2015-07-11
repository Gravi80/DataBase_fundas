CREATE OR REPLACE FUNCTION fibonacci_series(
	numbers int
)
RETURNS VOID
AS
$_$
DECLARE
    a int;b int;temp int;index int;
BEGIN
	a=0;b=1;index=0;
    RAISE NOTICE '%',a;
    RAISE NOTICE '%',b;
    LOOP
        IF(index=(numbers-2)) Then EXIT;
        END IF;   
        temp=a+b;
        a=b;
        b=temp;
    	RAISE NOTICE '%',temp;
    	index=index+1;
    END LOOP;
END;
$_$
LANGUAGE 'plpgsql';




CREATE OR REPLACE FUNCTION fibonacci_series(
	numbers int
)
RETURNS VOID
AS
$_$
DECLARE
    a int;b int;index int;
BEGIN
	a=0;b=1;index=0;
    RAISE NOTICE '%',a;
    RAISE NOTICE '%',b;
    LOOP
        IF(index=(numbers-2)) Then EXIT;
        END IF;   
        select b,a+b into a,b;
    	RAISE NOTICE '%',b;
    	index=index+1;
    END LOOP;
END;
$_$
LANGUAGE 'plpgsql';





/* While LOOP */

CREATE OR REPLACE FUNCTION fibonacci_series(
    numbers int
)
RETURNS VOID
AS
$_$
DECLARE
    a int;b int;index int;
BEGIN
    a=0;b=1;index=2;
    RAISE NOTICE '%',a;
    RAISE NOTICE '%',b;
    WHILE (index <=numbers)
    LOOP
        select b,a+b into a,b;
        RAISE NOTICE '%',b;
        index=index+1;
    END LOOP;
END;
$_$
LANGUAGE 'plpgsql';




/* FOR LOOP */

CREATE OR REPLACE FUNCTION fibonacci_series(
    numbers int
)
RETURNS VOID
AS
$_$
DECLARE
    a int;b int;
BEGIN
    a=0;b=1;
    RAISE NOTICE '%',a;
    RAISE NOTICE '%',b;
    FOR index  IN 2..numbers
    LOOP
        select b,a+b into a,b;
        RAISE NOTICE '%',b;
    END LOOP;

END;
$_$
LANGUAGE 'plpgsql';



/* one by one i want to iterate on bid in boat table ,  select will give me all bid at onnce */

CREATE OR REPLACE FUNCTION print_boat_names()
RETURNS VOID
AS
$_$
DECLARE
    record_variable RECORD;
BEGIN
    FOR record_variable  IN ( select * from tbl_boats)
    LOOP
        RAISE NOTICE 'BoatId is %  and  BoatName is %',record_variable.bid,record_variable.bname;
    END LOOP;
END;
$_$
LANGUAGE 'plpgsql';




CREATE OR REPLACE FUNCTION print_boat_names()
RETURNS VOID
AS
$_$
DECLARE
    record_variable tbl_boats%ROWTYPE;               => is pre-populated for holding all columns
BEGIN
    FOR record_variable  IN ( select bname from tbl_boats)   => here we are getting only one column
    LOOP
        RAISE NOTICE 'BoatId is %  and  BoatName is %',record_variable.bid,record_variable.bname;
    END LOOP;
END;
$_$
LANGUAGE 'plpgsql';






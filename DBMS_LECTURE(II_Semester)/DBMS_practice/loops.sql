

    LOOP
        IF( condition ) Then EXIT;
    END LOOP;

    
    WHILE (condition)
    LOOP
    END LOOP;    

    FOR index  IN 2..numbers
    LOOP
    END LOOP;



    /* print Student Name and Id */

CREATE OR REPLACE FUNCTION print_all_student_detail(
)
RETURNS VOID
AS
$$
DECLARE
record_variable RECORD; 
BEGIN
 FOR record_variable IN ( select * from student)
 LOOP
  RAISE NOTICE 'StudentId is %  and  StudentName is %',record_variable.sid,record_variable.sname;
 END LOOP;
END;
$$
LANGUAGE 'plpgsql';



CREATE OR REPLACE FUNCTION print_all_student_name(
)
RETURNS SETOF VARCHAR
AS
$$
DECLARE
record_variable RECORD;
BEGIN
  FOR record_variable in ( select * from student)
  LOOP
   RETURN NEXT record_variable.sname;
  END LOOP;
END;
$$
LANGUAGE 'plpgsql'; 

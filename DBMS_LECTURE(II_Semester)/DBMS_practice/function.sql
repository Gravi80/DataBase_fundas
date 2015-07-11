CREATE OR REPLACE FUNCTION get_student_name(
 IN student_id int,OUT student_name varchar(20)
)
RETURNS varchar
AS
$$
BEGIN
 SELECT sname INTO student_name FROM student WHERE sid=student_id;
END;
$$
LANGUAGE 'plpgsql';



CREATE OR REPLACE FUNCTION get_student_record(
	student_id int
)
RETURNS RECORD
AS
$$
DECLARE 
student_record RECORD; 	
BEGIN
SELECT * INTO student_record FROM student where sid=student_id;
RETURN student_record;
END;
$$
LANGUAGE 'plpgsql';

select * from get_student_record(123);



CREATE OR REPLACE FUNCTION get_all_student_record(
)
RETURNS TABLE(sID int, sName text, GPA real, sizeHS int)
AS
$$
BEGIN
return query SELECT * FROM student;
END;
$$
LANGUAGE 'plpgsql';

select * from get_all_student_record();


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

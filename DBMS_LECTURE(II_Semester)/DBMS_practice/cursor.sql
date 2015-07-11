	CREATE OR REPLACE FUNCTION print_student_names(
	)
	RETURNS VOID
	AS
	$$
	DECLARE
	cursor_name CURSOR FOR
	select sname,gpa from student;
	student_name varchar(20);
	gpa decimal;
	BEGIN
	OPEN cursor_name;
	LOOP
	FETCH cursor_name into student_name,gpa;
	IF NOT FOUND THEN 
	EXIT;
	END IF;
	 RAISE NOTICE 'Student Name %',student_name;
	END LOOP;
	CLOSE cursor_name;
	END;
	$$
	LANGUAGE 'plpgsql'; 


CREATE OR REPLACE FUNCTION get_student_name(
student_id int)
RETURNS VOID
AS
$$
DECLARE
cursor_name CURSOR(stu_id int) is
select sname from student where student.sid=stu_id;
student_name varchar(20);
BEGIN
OPEN cursor_name(student_id);
FETCH cursor_name INTO student_name;
RAISE NOTICE 'Student Name %',student_name;
CLOSE cursor_name;
END;
$$
LANGUAGE 'plpgsql';	
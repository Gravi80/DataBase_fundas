CREATE OR REPLACE FUNCTION get_result(
student_id int
)
RETURNS VOID
AS
$$
DECLARE marks decimal;
BEGIN
 select gpa into marks FROM student where sid=student_id;
 IF ( marks > 3.4) THEN
 	RAISE NOTICE 'PASS';
 END IF;  
END;
$$
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION get_result(
student_id int
)
RETURNS VOID
AS
$$
DECLARE marks decimal;
BEGIN
 select gpa into marks FROM student where sid=student_id;
 IF ( marks > 3.4) THEN
 	RAISE NOTICE 'PASS';
 ELSE
 	RAISE NOTICE 'FAIL';
 END IF;  
END;
$$
LANGUAGE 'plpgsql';


CREATE OR REPLACE FUNCTION print_one_two(
 num int
)
RETURNS VOID
AS
$$
BEGIN
	IF(num=1) THEN
		RAISE NOTICE 'One';
	ELSEIF(num=2) THEN
		RAISE NOTICE 'Two';
	ELSE
		RAISE NOTICE 'give only one two';
	END IF;
END;
$$
LANGUAGE 'plpgsql';



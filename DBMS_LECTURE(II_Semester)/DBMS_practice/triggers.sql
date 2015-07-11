ROW-LEVEL TRIGGERS => executes after each row
STATEMENT LEVEL TRIGGERS  => if there are multiple update in a transaction , it will only execute trigger on last update


CREATE OR REPLACE FUNCTION check_gpa(
)
RETURNS TRIGGER
LANGUAGE plpgsql
AS
$$
BEGIN
RAISE NOTICE 'Table Name is %',TG_TABLE_NAME;
IF(TG_OP='INSERT') THEN
IF (NEW.gpa < 3.4) THEN
RAISE NOTICE 'Can not Insert or update student gpa is less';
ELSE
-- EXECUTE 'INSERT INTO student(sid,sname,gpa,sizehs) values($1.sid,$1.sname,$1.gpa,$1.sizehs)' USING NEW; 	
-- INSERT INTO student values(NEW.sid,NEW.sname,NEW.gpa,NEW.sizehs); 	
RETURN NEW;
END IF;
END IF;
RETURN null;
END;
$$;


LANGUAGE 'plpgsql';


CREATE TRIGGER check_student_gpa
BEFORE INSERT OR UPDATE
ON student
FOR EACH ROW
execute PROCEDURE check_gpa();


insert into Student values (498, 'Pamy',2.0,3000);
insert into Student values (598, 'Samy',4.0,2000);

drop trigger check_student_gpa on student;	
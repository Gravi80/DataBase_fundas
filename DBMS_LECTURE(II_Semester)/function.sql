CREATE OR REPLACE FUNCTION show_full_name (
     Prefix varchar(5),First_name varchar(30),Last_name varchar(30)                               
) 
RETURNS VARCHAR
AS
$$
BEGIN
   RETURN CONCAT_WS(',',(NULLIF(Prefix,'') || '.'),NULLIF(First_name,''),NULLIF(Last_name,''));  
END;
$$
LANGUAGE 'plpgsql';


select show_full_name('Mr',null,'Sharma') into variable;
select show_full_name('Mr','Ravi','Sharma');
select show_full_name(null,'Ravi','Sharma');
select show_full_name('Mr','Ravi',null);
select show_full_name('','Ravi','Sharma');
select show_full_name('Mr','','Sharma');
select show_full_name('Mr','Ravi','');
select show_full_name('','','');
select show_full_name('','','s');





In "IN" type of argument => u can't change the value of argument, postgres allows it.
In "IN OUT" type of argument => u can change the value of argument.
In "OUT" type of argument => u did't get any input.  




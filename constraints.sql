PRIMARY KEY   ---------> not allow NULL values
UNIQUE KEY   ----------> allows NULL values
FOREIGN KEY ==> CASCADE
CHECK
NOT NULL

By ANSI definition UNIQUE constraint will allow only one NULL value ===> some database follow this and some not.
Postgres doesn't follow this Oracle and SQL follow.



PRIMARY KEY
============

create table department(dept_no varchar,dept_name varchar(50),PRIMARY KEY (dept_no)); 
drop table department; 
create table department(dept_no varchar,dept_name varchar(50),CONSTRAINT primary_key_deptNo_department PRIMARY KEY (dept_no)); 


create table department(dept_no varchar,dept_name varchar(50)); 

ALTER TABLE department add PRIMARY KEY (dept_no);
ALTER TABLE department add CONSTRAINT primary_key_deptNo_department  PRIMARY KEY (dept_no);
ALTER TABLE department drop CONSTRAINT primary_key_deptNo_department;


FOREIGN KEY
============

create table department(dept_no varchar,dept_name varchar(50),PRIMARY KEY (dept_no)); 

create table employee(emp_no integer,emp_name varchar,dept_no varchar,hire_date date,gender char(1),salary integer,mgr_no integer,comm integer,PRIMARY KEY (emp_no),FOREIGN KEY (dept_no) REFERENCES department);

create table employee(emp_no integer,emp_name varchar,dept_no varchar,hire_date date,gender char(1),salary integer,mgr_no integer,comm integer,PRIMARY KEY (emp_no),FOREIGN KEY (dept_no) REFERENCES department ON DELETE CASCADE ON UPDATE NO ACTION);

CASCADE keyword says that if a department row is deleted, all employee rows that refer to it are to be deleted as well.

If the UPDATE clause specified CASCADE, and the dept_no column of a department row is updated,
this update is also carried out in each employee row that refers to the updated department row.

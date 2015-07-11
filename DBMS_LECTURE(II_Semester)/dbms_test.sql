create table employee(emp_no integer,emp_name varchar,dept_no varchar,hire_date date,gender char(1),salary integer,mgr_no integer,comm integer);
create table department(dept_no varchar,dept_name varchar(50));

insert into employee values(000010,'CHRISTINE','A00','1965-01-01','F',52750,NULL,4220);
insert into employee values(000020,'MICHAEL','B01','1973-10-10','M',41250,000010,3300);
insert into employee values(000030,'SALLY','C01','1975-04-05','F',38250,000010,2092);
insert into employee values(000050,'JOHN','E01','1949-08-17','M',40175,000010,3300);
insert into employee values(000060,'IRVING','D11','1973-09-14','M',32250,000030,2580);
insert into employee values(000070,'EVA','D21','1980-09-30','F',36170,000030,2893);	
insert into employee values(000090,'EILEEN','E11','1970-08-15','F',29750,000060,2380);
insert into employee values(000100,'THEODORE','E21','1980-06-19','M',26150,000060,2092);
insert into employee values(000110,'VINCENZO','A00','1958-05-16','M',46500,000010,3720);
insert into employee values(000120,'SEAN%','A00','1963-12-05','M',NULL,000010,2340);
insert into employee values(000130,'DOLORES','C01','1971-07-28','F',23800,000020,1904);
insert into employee values(000140,'HEATHER','C01','1976-12-15','F',28420,000020,2274);	


insert into department values('A00','SPIFFY COMPUTER SERVICE DIV');
insert into department values('B01','PLANNING');
insert into department values('C01','INFORMATION CENTER');
insert into department values('D01','DEVELOPMENT CENTER');
insert into department values('D11','MANUFACTURING SYSTEMS');
insert into department values('D21','ADMINISTRATION SYSTEMS');
insert into department values('E01','SUPPORT SERVICES');
insert into department values('E11','OPERATIONS');
insert into department values('E21','SOFTWARE SUPPORT');
insert into department values('F22','BRANCH OFFICE F2');
insert into department values('G22','BRANCH OFFICE G2');
insert into department values('H22','BRANCH OFFICE H2');
insert into department values('I22','BRANCH OFFICE I2');
insert into department values('I22','BRANCH OFFICE I2');	


Q1). Write a Query to delete duplicate rows in the “department” table.

WITH RowNumbers AS
(
SELECT dept_no
  ,ROW_NUMBER()
    OVER (PARTITION BY  dept_no) AS rn
FROM department
)
DELETE FROM RowNumbers WHERE rn > 1


delete from ( SELECT dept_no,ROW_NUMBER() OVER (PARTITION BY  dept_no) AS rn FROM department ) as duplicate_rows where rn>1;




Q2). Write a Query to get the employee details from “employee” table who joined before January 1st 1970.
select * from (select salary,rank() over(order by salary desc) from employee where salary IS NOT NULL)emp where rank=4;


Q3).Write a Query to get the employee details from “employee” table who joined before January 1st 1970.
explain analyze select * from employee where hire_date > to_date('01 jan 1970','DD Mon YYYY');
explain analyze select * from employee where hire_date > '01 jan 1970';


Q4).Write a Query to get names of employees from employee table who have '%' in their names.
select emp_name from employee where position('%' in emp_name) > 0;

Q5).Write a Query to select the first 3 characters of Emp_Name from “employee”.
select substr(emp_name,1,3) as name from employee;

Q6). Write a Query to get Emp_Name from employee table after removing white spaces from beginning and end.
select trim(both ' ' from emp_name)as emp_name from employee ;

Q7).Write a Query to get the employee details from “employee” table for employees who have joined in the year “1980”.
select emp_name from employee where date_part('year',hire_date)=1980;
select emp_name from employee where extract('year'from hire_date)=1980;

Q8).Write a Query to get department (name) wise average salary from “employee” table and order the result by ascending order of salaries.
select d.dept_no,d.dept_name,avg(e.salary) from employee e join department d on e.dept_no=d.dept_no group by d.dept_name,d.dept_no;

Q9).Write a Query to display the Count of the number of employees by department (id).
select dept_no,count(1) from employee group by dept_no;

Q10). Write a Query to find the 4th maximum salary in the “employee” table.
select emp_name from (select emp_name,salary,rank() over (order by coalesce(salary,0) desc) from employee)salary_rank where rank=4;

Q11)Write a Query to List Dept_No and Dept_Names for all “Department” s in which there are no “Employee”s. Write the query using OUTER JOIN (LEFT/RIGHT).





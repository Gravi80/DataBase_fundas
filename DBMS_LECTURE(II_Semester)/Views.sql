/*
SIMPLE ONE-TABLE VIEW
Student ID and college name of students who have been accepted into CS
*/

create view CSaccept as
select sID, cName
from Apply
where major = 'CS' and decision = 'Y';

select * from CSaccept;

/*
  USE VIEW IN QUERY
  Students accepted to CS at Stanford with GPA < 3.8
*/

select Student.sID, sName, GPA
from Student, CSaccept
where Student.sID = CSaccept.sID and cName = 'Stanford' and GPA < 3.8;

/*
  TEMPORARY TABLE IMPLEMENTATION (everything)
*/


/*
create temporary table T as
select sID, cName
from Apply
where major = 'CS' and decision = 'Y';

select Student.sID, sName, GPA
from Student, T
where Student.sID = T.sID and cName = 'Stanford' and GPA < 3.8;

drop table T;
*/

/*
  AUTOMATIC QUERY REWRITE TO ELIMINATE VIEW
  (straightforward version)
*/

select Student.sID, sName, GPA
from Student,
     (select sID, cName from Apply
      where major = 'CS' and decision = 'Y') as CSaccept
where Student.sID = CSaccept.sID and cName = 'Stanford' and GPA < 3.8;

/*
  AUTOMATIC QUERY REWRITE TO ELIMINATE VIEW
  ("flattened" version)
*/

select Student.sID, sName, GPA
from Student, Apply
where major = 'CS' and decision = 'Y'
and Student.sID = Apply.sID and cName = 'Stanford' and GPA < 3.8;

/*
  VIEW LAYERING
  Students accepted into CS at Berkeley with sizeHS > 500
*/

create view CSberk as
select Student.sID, sName, GPA
from Student, CSaccept
where Student.sID = CSaccept.sID and cName = 'Berkeley' and sizeHS > 500;

select * from CSberk;

/*
  QUERY OVER LAYERED VIEW
  Students accepted to CS at Berkeley with sizeHS > 500 and GPA > 3.8
*/

select * from CSberk where GPA > 3.8;

/*
  RECURSIVE QUERY REWRITE TO ELIMINATE LAYERED VIEWS
  (straightforward version)
*/

select * from
(select Student.sID, sName, GPA
from Student, (select sID, cName from Apply
               where major = 'CS' and decision = 'Y') as CSaccept
where Student.sID = CSaccept.sID and cName = 'Berkeley' and sizeHS > 500) CSberk
where GPA > 3.8;

/*
  DROP ORIGINAL VIEW
*/

drop view CSaccept;
select * from CSberk;


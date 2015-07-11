/*Query1*/

select sID, sName
from Student
where sID in (select sID from Apply where major = 'CS');

/*Query2*/

select sID, sName
from Student, Apply
where Student.sID = Apply.sID and major = 'CS';

/*Query3*/

select Student.sID, sName
from Student, Apply
where Student.sID = Apply.sID and major = 'CS';

/*Query4*/

select distinct Student.sID, sName
from Student, Apply
where Student.sID = Apply.sID and major = 'CS';

/*Query5*/

select sName
from Student
where sID in (select sID from Apply where major = 'CS');

/*Query6*/

select sName
from Student, Apply
where Student.sID = Apply.sID and major = 'CS';

/*Query7*/

select distinct sName
from Student, Apply
where Student.sID = Apply.sID and major = 'CS';

/*Query8*/

select GPA
from Student
where sID in (select sID from Apply where major = 'CS');

/*Query9*/

select GPA
from Student, Apply
where Student.sID = Apply.sID and major = 'CS';

/*Query10*/

select distinct GPA
from Student, Apply
where Student.sID = Apply.sID and major = 'CS';

/*Query11*/

select sID, sName
from Student
where sID in (select sID from Apply where major = 'CS')
  and sID not in (select sID from Apply where major = 'EE');

/*Query12*/

select sID, sName
from Student
where sID in (select sID from Apply where major = 'CS')
  and not sID in (select sID from Apply where major = 'EE');

/*Query13*/

select cName, state
from College C1
where exists (select * from College C2
              where C2.state = C1.state);

/*Query14*/

select cName, state
from College C1
where exists (select 1 from College C2
              where C2.state = C1.state and C2.cName <> C1.cName);

/*Query15*/

select cName
from College C1
where not exists (select 1 from College C2
                  where C2.enrollment > C1.enrollment);

/*Query16*/

select sName
from Student C1
where not exists (select 1 from Student C2
                  where C2.GPA > C1.GPA);

/*Query17*/

select sName, GPA
from Student C1
where not exists (select 1 from Student C2
                  where C2.GPA > C1.GPA);

/*Query18*/

select S1.sName, S1.GPA
from Student S1, Student S2
where S1.GPA > S2.GPA;

/*Query19*/

select distinct S1.sName, S1.GPA
from Student S1, Student S2
where S1.GPA > S2.GPA;

/*Query20*/

select sName, GPA
from Student
where GPA >= all (select GPA from Student);

/*Query21*/

select sName, GPA
from Student S1
where GPA > all (select GPA from Student S2
                 where S2.sID <> S1.sID);

/*Query22*/

select cName
from College S1
where enrollment > all (select enrollment from College S2
                        where S2.cName <> S1.cName);

/*Query23*/

select cName
from College S1
where not enrollment <= any (select enrollment from College S2
                             where S2.cName <> S1.cName);

/*Query24*/

select sID, sName, sizeHS
from Student
where sizeHS > any (select sizeHS from Student);

/*Query25*/

select sID, sName, sizeHS
from Student S1
where exists (select * from Student S2
              where S2.sizeHS < S1.sizeHS);

/*Query26*/

select sID, sName
from Student
where sID = any (select sID from Apply where major = 'CS')
  and sID <> any (select sID from Apply where major = 'EE');

/*Query27*/

select sID, sName
from Student
where sID = any (select sID from Apply where major = 'CS')
  and not sID = any (select sID from Apply where major = 'EE');

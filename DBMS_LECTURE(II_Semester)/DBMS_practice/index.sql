create table indexDemo as select * from student;
insert into indexDemo values (343, 'Amy', 3.1, 2000);
insert into indexDemo values (348, 'Amy', 6.1, 3000);
insert into indexDemo select * from indexDemo;
create index IX_IndexDemo_sname on indexDemo(sname);	
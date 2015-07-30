create table participants(p_id integer primary key,name varchar(15));

create table donations(d_id integer primary key,recipient_id integer,amount integer,foreign key(recipient_id) references participants);

create table blogs(b_id integer primary key,participant_id integer,foreign key(participant_id) references participants);

insert into participants values(1,'ravi');
insert into participants values(2,'sandeep');
insert into participants values(3,'gaurav');


insert into donations values(1,1,100);
insert into donations values(2,1,300);
insert into donations values(3,1,400);
insert into donations values(4,1,300);


insert into blogs values(1,1);
insert into blogs values(2,1);
insert into blogs values(3,1);
insert into blogs values(4,2);



SELECT p_id,
       name,
       amount,
       blogs_count
FROM participants p
LEFT JOIN
  (SELECT recipient_id,
          sum(amount) amount
   FROM donations
   GROUP BY recipient_id)d ON p.p_id=d.recipient_id
LEFT JOIN
  (SELECT participant_id,
          count(1) blogs_count
   FROM blogs
   GROUP BY participant_id)b ON p.p_id=b.participant_id;


  


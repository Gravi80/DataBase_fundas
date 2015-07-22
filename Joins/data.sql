DROP TABLE person;
DROP TABLE person_location;
DROP TABLE salesperson;
DROP TABLE customer;
DROP TABLE orders;

create table person(
	person_id integer,
	person_desc varchar(50)
);

ALTER TABLE person add CONSTRAINT pk_person PRIMARY KEY (person_id);


insert into person values (1,'Ravi');
insert into person values (2,'Vishal');
insert into person values (3,'Rakesh');



create table person_location (
	person_loc_id integer,
	person_id integer,
	person_loc_desc VARCHAR(50)
);

ALTER TABLE person_location add CONSTRAINT pk_person_loc PRIMARY KEY (person_loc_id);


insert into person_location values (1,1,'Delhi');
insert into person_location values (2,2,'Batala');
insert into person_location values (3,4,'Chennai');



-- SET 2

create table salesperson(
	id integer primary key,
	name varchar(50),
	age integer,
	salary float
);


insert into salesperson values(1,'Abe',61,140000);
insert into salesperson values(2,'Bob',34,44000);
insert into salesperson values(5,'Chris',34,40000);
insert into salesperson values(7,'Dan',41,52000);
insert into salesperson values(8,'Ken',57,115000);
insert into salesperson values(11,'Joe',38,38000);


create table customer(
	id integer primary key,
	name varchar(50),
	city varchar(30),
	industry_type char
);

insert into customer values(4,'Samsonic','pleasant','J');
insert into customer values(6,'Panasung','oaktown','J');
insert into customer values(7,'Samony','jackson','B');
insert into customer values(9,'Orange','Jackson','B');


create table orders(
	id integer,
	order_date date,
	cust_id integer,
	salesperson_id integer,
	amount float
);

insert into orders values(10,'8/2/96',4,2,540);
insert into orders values(20,'1/30/99',4,8,1800);
insert into orders values(30,'7/14/95',9,1,460);
insert into orders values(40,'1/29/98',7,2,2400);
insert into orders values(50,'2/3/98',6,7,600);
insert into orders values(60,'3/2/98',6,7,720);
insert into orders values(70,'5/6/98',9,7,150);

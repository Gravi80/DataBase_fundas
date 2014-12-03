create database demo;


CREATE TABLE Persons(
	P_Id Serial NOT NULL,
	Name varchar,
	City varchar,
	PRIMARY KEY (P_Id)
);

CREATE TABLE Orders(
	O_Id Serial NOT NULL,
	OrderNo int NOT NULL,
	P_Id int,
	Description varchar,
	PRIMARY KEY (O_Id),
	FOREIGN KEY (P_Id) REFERENCES Persons(P_Id)
);


insert into Persons values(1,'Ravi','Delhi');
insert into Persons values(2,'Sandeep','Chennai');
insert into Persons values(3,'Chetan','Bangalore');	

insert into Orders values(1,1,1,'Sports Equipment');
insert into Orders values(2,2,3,'Books');
insert into Orders values(3,3,2,'Furnitures');
insert into Orders values(4,4,1,'Sports Equipment');
insert into Orders values(5,5,2,'Furnitures');
insert into Orders values(6,6,3,'Sports Equipment');
insert into Orders values(7,7,1,'Sports Equipment');
insert into Orders values(8,8,2,'Medical');
insert into Orders values(9,9,3,'Books');
insert into Orders values(10,10,2,'Furnitures');


-- This will return a single column per row in the words table.
select row_to_json(Persons) from Persons;
select row_to_json(Orders) from Orders;

-- However, sometimes we only want to include some columns in the JSON 
-- instead of the entire row.﻿
select row_to_json(row(O_Id,Description)) from Orders; --misses field names
select row_to_json(t)from (select O_Id,Description from Orders) t;


--array_agg and array_to_json. 
-- array_agg is a aggregate function like sum or count. It aggregates its argument into a PostgreSQL array. 
-- array_to_json takes a PostgreSQL array and flattens it into a single JSON value.

select array_to_json(array_agg(row_to_json(t)))from (select P_Id,Name from Persons) t;

-- we can also use subqueries to return an entire object graph:
select array_to_json(array_agg(row_to_json(t)))from (select P_Id,Name,(select array_to_json(array_agg(row_to_json(d))) orders from (select O_Id,Description from Orders where P_Id=Persons.P_Id order by O_Id asc)d  ) from Persons) t;



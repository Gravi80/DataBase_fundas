CREATE TABLE TBL_Sailors (
       sid         INTEGER
     , sname         CHAR(20)
     , rating         INTEGER
     , age         DECIMAL(10,2)
     , CONSTRAINT PK_Sailors_sid PRIMARY KEY (sid)
);

INSERT INTO TBL_Sailors (sid, sname, rating, age)
VALUES (22,'Dustin',7,45.0)
     , (31,'Lubber',8,55.5)
     , (95,'Bob',3,63.5);

CREATE TABLE TBL_Boats (
       bid         INTEGER
     , bname         CHAR (20)
     , color         CHAR(10) 
     , CONSTRAINT PK_Boats_bid PRIMARY KEY (bid)
);

INSERT INTO TBL_Boats (bid, bname, color)
VALUES (101,'Interlake','blue')
     , (102,'Interlake','red')
     , (103,'Clipper','green')
     , (104,'Marine','red');

CREATE TABLE TBL_Reserves (
     sid         INTEGER
      , bid         INTEGER
      , day         DATE
      , CONSTRAINT PK_Reserves_sid_bid PRIMARY KEY (sid, bid,day)
      , CONSTRAINT FK_Reserves_sid_Sailors_sid FOREIGN KEY (sid) REFERENCES TBL_Sailors (sid)
      , CONSTRAINT FK_Reserves_bid_Boats_bid  FOREIGN KEY (bid) REFERENCES TBL_Boats (bid)
);

INSERT INTO TBL_Reserves (sid, bid, day)
VALUES (22,101,'1996-10-10')
     , (95,103,'1996-12-11');


CREATE TABLE RegionalSales
(
  SalesID         INT         NOT NULL PRIMARY KEY,
  SalesGroup         VARCHAR(30)     NOT NULL,
  Country         VARCHAR(30)     NOT NULL,
  AnnualSales         INT         NOT NULL
);

INSERT INTO RegionalSales
  (SalesID, SalesGroup, Country, AnnualSales)
VALUES
  (1,'North America', 'United States', 22000),
  (2,'North America', 'Canada', 32000),
  (3,'North America', 'Mexico', 28000),
  (4,'Europe', 'France', 19000),
  (5,'Europe', 'Germany', 22000),
  (6,'Europe', 'Italy', 18000),
  (7,'Europe', 'Greece', 16000),
  (8,'Europe', 'Spain', 16000),
  (9,'Europe', 'United Kingdom', 32000),
  (10,'Pacific', 'Australia', 18000),
  (11,'Pacific', 'China', 28000),
  (12,'Pacific', 'Singapore', 21000),
  (13,'Pacific', 'New Zealand', 18000),
  (14,'Pacific', 'Thailand', 17000),
  (15,'Pacific', 'Malaysia', 19000),
  (16,'Pacific', 'Japan', 22000);


  

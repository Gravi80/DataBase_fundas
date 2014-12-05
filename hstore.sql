-- hstore is A Key Value Pair inside your data base

CREATE EXTENSION hstore;  -- Enable hstore datatype

CREATE TABLE users(
	id integer NOT NULL,
	email character varying(255),
	data hstore,
	created_at timestamp without time zone,
	last_login timestamp without time zone
);

-- data is of type hstore , u can put any information related to user in it

INSERT INTO users VALUES(
1,
'ravi.sharma@gmail.com',
'gender=>"M",country=>"India"',
now(),
now()
);


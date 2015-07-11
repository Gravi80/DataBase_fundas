CREATE OR REPLACE FUNCTION convert_color_to_int ( 
	color varchar
)
RETURNS int
AS
$$
BEGIN
	if (color='blue') then RETURN 1;
	elsif (color='red') then RETURN 2;
	elsif (color='green') then RETURN 3;
	else RETURN 4;
	END IF;
END;
$$
LANGUAGE 'plpgsql';




EXPLAIN select * from tbl_boats1 where convert_color_to_int(color)=1;

Seq Scan on tbl_boats1  (cost=0.00..71653.16 rows=1311 width=36)
   Filter: (convert_color_to_int((color)::character varying) = 1)


CREATE INDEX IX_BOATS_COLOR ON TBL_BOATS1(convert_color_to_int(color));
ERROR:  functions in index expression must be marked IMMUTABLE     => the value in the index sholud be stable, at any given point of time if i call color blue it sholud give me 1


CREATE OR REPLACE FUNCTION convert_color_to_int ( 
	color varchar
)
RETURNS int
AS
$$
BEGIN
	if (color='blue') then RETURN 1;
	elsif (color='red') then RETURN 2;
	elsif (color='green') then RETURN 3;
	else RETURN 4;
	END IF;
END;
$$
LANGUAGE 'plpgsql'
IMMUTABLE;


CREATE INDEX IX_BOATS_COLOR ON TBL_BOATS1(convert_color_to_int(color));
EXPLAIN select * from tbl_boats1 where convert_color_to_int(color)=1;



EXPLAIN select * from tbl_boats1 where color=2;  => try to convert the literal into column datatype

  dateTime=Date('23-09-1919');  -----> try to do this
  dateTime='23-09-1919';  -------> don't try to do this

because database need to convert all the column value into literal datatype then it need to compare.




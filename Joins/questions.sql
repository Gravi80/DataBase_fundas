-- The names of all salespeople that have an order with Samsonic.

SELECT * from orders where cust_id=(SELECT id from customer where name='Samsonic');

SELECT s.id,s.name from (SELECT * from orders where cust_id=(SELECT id from customer where name='Samsonic')) a 
INNER JOIN salesperson s
ON s.id=a.salesperson_id;

-- ┌────┬──────┐
-- │ id │ name │
-- ├────┼──────┤
-- │  2 │ Bob  │
-- │  8 │ Ken  │
-- └────┴──────┘


-- The names of all salespeople that do not have any order with Samsonic.


-- The names of salespeople that have 2 or more orders.





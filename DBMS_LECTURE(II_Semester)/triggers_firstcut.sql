drop table if exists account_savings;
drop table if exists account_current;
drop table if exists log; 

CREATE TABLE account_current
(
  customer_id integer NOT NULL,
  customer_name character varying,
  balance numeric,
  CONSTRAINT account_current_pkey PRIMARY KEY (customer_id)
);

CREATE TABLE account_savings
(
customer_id integer NOT NULL,
customer_name character varying,
balance numeric,
CONSTRAINT account_savings_pkey PRIMARY KEY (customer_id)
);

CREATE TABLE log
(
log_id serial NOT NULL,
log_time time with time zone,
description character varying,
CONSTRAINT log_pkey PRIMARY KEY (log_id)
);

CREATE OR REPLACE FUNCTION add_log_trigg_function()  /* idempotent => because of using REPLACE , so that u can change the add_log_trigg_function */
  RETURNS trigger    /* only when we r using this fuction in trigger */  
  LANGUAGE plpgsql  /* you can give java or any language */
  AS
$_$               /* is to identify where the body starts and where the body ends of function*/
DECLARE
    account_type varchar;
BEGIN
    IF (TG_TABLE_NAME = 'account_current') THEN
        account_type := 'Current';
        RAISE NOTICE 'TRIGER called on %', TG_TABLE_NAME;
 
    ELSIF (TG_TABLE_NAME = 'account_savings') THEN
        account_type := 'Savings';
        RAISE NOTICE 'TRIGER called on %', TG_TABLE_NAME;
 
    END IF;
 
    IF (TG_OP = 'INSERT') THEN   /* Trigger Operation */
        INSERT INTO log(
                log_time,
                description)
            VALUES(
                now(),
                'New customer added. Account type: ' || account_type || ', Customer ID: ' || NEW.customer_id || ', Name: ' || NEW.customer_name || ', Balance: ' || NEW.balance);  /**/
        RETURN NEW;
    ELSIF (TG_OP = 'UPDATE') THEN
        IF (NEW.balance < 0) THEN
            RAISE EXCEPTION 'Can''t withdraw the amount because of low balance! Available balance: %, Requested amount: %', OLD.balance, OLD.balance + (- NEW.balance);
        END IF;
        IF NEW.balance != OLD.balance THEN
            EXECUTE 'INSERT INTO log(log_time,description) VALUES(now(), ''Balance updated. Account type: ' || account_type || ', Customer ID: '' || $1.customer_id || ''. Old balance: '' || $2.balance || '', New balance: '' || $1.balance)' USING NEW, OLD;
        END IF;
        RETURN NEW;
 
    ELSIF (TG_OP = 'DELETE') THEN
            INSERT INTO log(
                log_time,
                description)
            VALUES(
                now(),
                'Account deleted. Account type: ' || account_type || ', Customer ID: ' || OLD.customer_id);
            RETURN OLD;
 
    END IF;
 
    RETURN null;
END;
$_$;
  


CREATE TRIGGER add_log_current_trigger
BEFORE INSERT OR UPDATE OR DELETE
ON account_current
FOR EACH ROW                                   /* function will execute after each row , if not given function will excute after the last update/delete         */
EXECUTE PROCEDURE add_log_trigg_function();

CREATE TRIGGER add_log_savings_trigger
BEFORE INSERT OR UPDATE OR DELETE
ON account_savings
FOR EACH ROW                                  /* if we remove it ,it will become statement level trigger */
EXECUTE PROCEDURE add_log_trigg_function();

delete from account_savings;
delete from account_current;
delete from log;

INSERT INTO account_savings VALUES (1, 'Bob', 2000);
INSERT INTO account_savings VALUES (2, 'Tom', 1000);
INSERT INTO account_current VALUES (3, 'Roy', 12000);
 
UPDATE account_savings SET balance = balance - 300 WHERE customer_id = 1;
UPDATE account_savings SET balance = balance + 300 WHERE customer_id = 2;
DELETE FROM account_savings WHERE customer_id = 1;

SELECT * FROM LOG;

drop table account_savings;
drop table account_current;
drop table log;

commit;

/*record type variable is used to store a row of a table */
/* NEW OLD are record type variables provided by DB just for trigger*/

/* NEW and OLD will be created before inserting/updating/deleting of data*/
/* Before Trigger => checks */ 
/* After Trigger => Audit */ 

/* BEFORE triggers run the trigger action before the triggering statement is run. */

/* ROW-LEVEL TRIGGERS => executes after each row
STATEMENT LEVEL TRIGGERS  => if there are multiple update in a transaction , it will only execute trigger on last update */
/*in case of check BEFORE TRIGGER should be used*/


CREATE OR REPLACE FUNCTION check_trigger_function()
  RETURNS trigger
  LANGUAGE plpgsql
  AS
$_$
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
 
    IF (TG_OP = 'UPDATE') THEN
        IF (NEW.balance < 0) THEN
            RAISE EXCEPTION 'Can''t withdraw the amount because of low balance! Available balance: %, Requested amount: %', OLD.balance, OLD.balance + (- NEW.balance);
        END IF;
        IF NEW.balance != OLD.balance THEN
            EXECUTE 'INSERT INTO log(log_time,description) VALUES(now(), ''Balance updated. Account type: ' || account_type || ', Customer ID: '' || $1.customer_id || ''. Old balance: '' || $2.balance || '', New balance: '' || $1.balance)' USING NEW, OLD;
        END IF;
        RETURN NEW;
    END IF;
 
    RETURN null;
END;
$_$;


CREATE TRIGGER update_current_trigger
BEFORE UPDATE
ON account_savings
FOR EACH ROW
EXECUTE PROCEDURE check_trigger_function();

INSERT INTO account_savings VALUES (1, 'Bob', 2000);
INSERT INTO account_savings VALUES (2, 'Tom', 1000);
INSERT INTO account_current VALUES (3, 'Roy', 12000);
 
UPDATE account_savings SET balance = balance - 300000 WHERE customer_id = 1;
UPDATE account_savings SET balance = balance + 300000 WHERE customer_id = 2;
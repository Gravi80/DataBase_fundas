/*in case of audit AFTER TRIGGER should be used*/


CREATE OR REPLACE FUNCTION audit_trigger_function()
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
 
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO log(
                log_time,
                description)
            VALUES(
                now(),
                'New customer added. Account type: ' || account_type || ', Customer ID: ' || NEW.customer_id || ', Name: ' || NEW.customer_name || ', Balance: ' || NEW.balance);  /**/
        RETURN NEW;
    END IF;
 
    RETURN null;
END;
$_$;


CREATE TRIGGER add_log_current_trigger
AFTER INSERT
ON account_savings
FOR EACH ROW
EXECUTE PROCEDURE audit_trigger_function();

INSERT INTO account_savings VALUES (1, 'Bob', 2000);
INSERT INTO account_savings VALUES (2, 'Tom', 1000);
INSERT INTO account_savings VALUES (3, 'Roy', 12000);

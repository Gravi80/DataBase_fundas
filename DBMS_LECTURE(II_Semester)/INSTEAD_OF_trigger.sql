CREATE OR REPLACE FUNCTION insert_into_account_saving_function()
  RETURNS trigger
  LANGUAGE plpgsql
  AS
$_$
DECLARE
BEGIN
    IF (TG_OP = 'INSERT') THEN
        INSERT INTO account_savings VALUES (NEW.customer_id,NEW.customer_name,NEW.balance);
        RETURN NEW;
    END IF;
END;
$_$;

CREATE TRIGGER insert_into_account_saving
INSTEAD OF INSERT
ON a_saving                                                    /* a_saving is a view of account_savings */
FOR EACH ROW
EXECUTE PROCEDURE insert_into_account_saving_function();

INSERT INTO a_saving VALUES (5, 'Ravi', 3000);
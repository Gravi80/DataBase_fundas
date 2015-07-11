CREATE OR REPLACE FUNCTION show_message_function()
  RETURNS trigger
  LANGUAGE plpgsql
  AS
$_$
DECLARE
    account_type varchar;
BEGIN
    IF (TG_TABLE_NAME = 'account_savings') THEN
        account_type := 'Savings';
        RAISE NOTICE 'TRIGER called on %', TG_TABLE_NAME;
    END IF;
 
    IF (TG_OP = 'UPDATE') THEN
        RAISE NOTICE 'Rows Updated';
    END IF;
    IF (TG_OP = 'INSERT') THEN
        RAISE NOTICE 'Rows Inserted';
    END IF;
    RETURN null;
END;
$_$;

CREATE TRIGGER update_saving_trigger
BEFORE UPDATE
ON account_savings
EXECUTE PROCEDURE show_message_function();


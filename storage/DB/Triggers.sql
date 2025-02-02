CREATE OR REPLACE FUNCTION Ref_trigger_function() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.Referal_code IS NOT NULL THEN 
        INSERT INTO REFERS(Refree, Referrer)
        VALUES(
            NEW.ID,
            NEW.Referal_code
        );
        PERFORM Calc_Referal_DISCOUNT(NEW.ID,NEW.Referal_code);
    END IF;
    RETURN NEW;
END;
$$ 
LANGUAGE plpgsql;

CREATE TRIGGER Referal_trigger
AFTER INSERT ON CLIENT 
FOR EACH ROW
EXECUTE FUNCTION Ref_trigger_function();
CREATE OR REPLACE FUNCTION Calc_Referal_DISCOUNT(new_user_id INT, referrer_id INT) 
RETURNS VOID AS $$
DECLARE
    current_id          INT;
    current_level       INT := 1;
    discount_percentage FLOAT;
    discount_amount     BIGINT;
    discount_code_id    INT;  

BEGIN
    current_id := referrer_id;
    
    WHILE current_id IS NOT NULL LOOP
        discount_percentage := 50 / (2 ^ (current_level - 1));

        IF discount_percentage < 1 THEN 
            discount_amount := 50000;
        ELSE 
            discount_amount := (1000000 * discount_percentage) / 100;
        END IF;

        INSERT INTO DISCOUNT_CODE (Amount, Usage_Limit, Usage_count, Expiration_date)
        VALUES (
        discount_amount,
        1, 
        1,
        CURRENT_TIMESTAMP + INTERVAL
        '7 Days'
        )
        RETURNING Code INTO discount_code_id;

        INSERT INTO PRIVATE_CODE (Code, ID)
        VALUES (discount_code_id, current_id);

        SELECT Referrer INTO current_id FROM REFERS WHERE Refree = current_id;

        EXIT WHEN current_id IS NULL;

        current_level := current_level + 1;
    END LOOP;
END;
$$ 
LANGUAGE plpgsql;

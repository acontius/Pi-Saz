CREATE EXTENSION pg_cron;

-- Referal invite's handling 
CREATE OR REPLACE FUNCTION Ref_trigger_function() RETURNS TRIGGER AS $$
BEGIN
    IF NEW.Referal_code IS NOT NULL THEN 
        -- Ensure the referrer exists
        IF NOT EXISTS (SELECT 1 FROM CLIENT WHERE Referal_code = NEW.Referal_code) THEN
            RAISE EXCEPTION 'Invalid referral code!';
        END IF;

        -- Prevent self-referral
        IF NEW.Referal_code = (SELECT Referal_code FROM CLIENT WHERE ID = NEW.ID) THEN
            RAISE EXCEPTION 'You cannot refer yourself!';
        END IF;

        -- Insert into REFERS table
        INSERT INTO REFERS(Refree, Referrer)
        VALUES(
            NEW.ID,
            (SELECT ID FROM CLIENT WHERE Referal_code = NEW.Referal_code)
        );

        -- Calculate referral discount
        PERFORM Calc_Referal_DISCOUNT(NEW.ID, (SELECT ID FROM CLIENT WHERE Referal_code = NEW.Referal_code));
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER Referal_trigger
AFTER INSERT ON CLIENT 
FOR EACH ROW
EXECUTE FUNCTION Ref_trigger_function();

CREATE TRIGGER Referal_trigger
AFTER INSERT ON CLIENT 
FOR EACH ROW
EXECUTE FUNCTION Ref_trigger_function();


-- Trigger to Prevent Adding Products to Locked Carts
CREATE OR REPLACE FUNCTION Not_leeting_locked_shoppingCarts() RETURNS TRIGGER AS $$
DECLARE
    cart_status cart_status;
BEGIN
    SELECT STATUS INTO cart_status 
    FROM SHOPPING_CART 
    WHERE Number = NEW.Cart_number; 

    IF cart_status IN ('locked', 'blocked') THEN 
        RAISE EXCEPTION 'Blocked or locked carts cannot take any actions!';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER Add_to_cart_Limits
BEFORE INSERT ON ADDED_TO
FOR EACH ROW
EXECUTE FUNCTION Not_leeting_locked_shoppingCarts();


-- Prevent Applying Discounts to Locked Carts
CREATE OR REPLACE FUNCTION Prevent_discount_locked_carts() RETURNS TRIGGER AS $$
DECLARE
    cart_status cart_status;
BEGIN
    SELECT STATUS INTO cart_status
    FROM SHOPPING_CART 
    WHERE Number = NEW.Cart_number;

    IF cart_status = 'locked' THEN 
        RAISE EXCEPTION 'LOCKED SHOPPING CARTS CANT TAKE ANY ACTIONS(DISCOUNT)';
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER Locked_discount_limitionS
BEFORE INSERT ON APPLIED_TO
FOR EACH ROW 
EXECUTE FUNCTION Prevent_discount_locked_carts();

-- Prevent Transactions on Locked Carts
CREATE OR REPLACE FUNCTION No_transactions_on_lockedShoppingcarts() RETURNS TRIGGER AS $$
DECLARE
    cart_status cart_status;
BEGIN
    SELECT STATUS INTO cart_status
    FROM SHOPPING_CART 
    WHERE Number = NEW.Cart_number;

    IF cart_status = 'locked' THEN 
        RAISE EXCEPTION 'LOCKED SHOPPING CARTS CANT TAKE ANY ACTIONS(TRANSACION)';
    END IF;

RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER Locked_transactions_limitions
BEFORE INSERT ON ISSUED_FOR
FOR EACH ROW
EXECUTE FUNCTION No_transactions_on_lockedShoppingcarts();


-- Control The Number Of Carts
CREATE OR REPLACE FUNCTION Cart_count_limits() 
RETURNS TRIGGER AS $$
DECLARE 
    cart_Counter INT;
    is_vip BOOLEAN;
BEGIN
    SELECT COUNT(*) INTO cart_Counter
    FROM SHOPPING_CART 
    WHERE ID = NEW.ID;

    SELECT is_vip INTO is_vip 
    FROM CLIENT 
    WHERE ID = NEW.ID;

    IF is_vip AND cart_Counter >= 5 THEN 
        RAISE EXCEPTION 'VIP USERS HAS LIMITS OF ONLY 5 CARTS !';
    ELSIF NOT is_vip AND cart_Counter >= 1 THEN 
        RAISE EXCEPTION 'CIP USERS HAS LIMITS OF ONLY 1 CART !' ;
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER cart_limit_trigger
BEFORE INSERT ON SHOPPING_CART
FOR EACH ROW 
EXECUTE FUNCTION Cart_count_limits();

-- Users Cannot Add Out-of-Stock Products to Their Shopping Cart
CREATE OR REPLACE FUNCTION Prevent_Out_stock() RETURNS TRIGGER AS $$
DECLARE
    quantity INT;
BEGIN 
    SELECT stock_count INTO quantity
    FROM PRODUCTS
    WHERE ID = NEW.Product_ID;
    
    IF quantity <= 0 THEN 
        RAISE EXCEPTION 'Items that are out of stock cannot be added to the cart!';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER stock_controller
BEFORE INSERT OR UPDATE ON ADDED_TO
FOR EACH ROW 
EXECUTE FUNCTION Prevent_Out_stock();

-- Update the Quantity if it was added or removed from shopping cart
CREATE OR REPLACE FUNCTION Update_the_quantity_on_cart_change() RETURNS TRIGGER AS $$

BEGIN 
    IF TG_OP = 'INSERT' THEN 
        UPDATE PRODUCTS
        SET stock_count = stock_count - 1
        WHERE id = NEW.Product_ID;

    ELSIF TG_OP = 'DELETE' THEN 
        UPDATE PRODUCTS
        SET stock_count = stock_count + 1
        WHERE id = OLD.Product_ID;
    END IF;

    RETURN NULL;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER Update_quantity 
AFTER INSERT OR DELETE ON ADDED_TO 
FOR EACH ROW
EXECUTE FUNCTION Update_the_quantity_on_cart_change();


-- Handling Percentage and Amount Discount and their ceilling !
CREATE OR REPLACE FUNCTION Amount_Percentage_ceil() RETURNS TRIGGER AS $$
DECLARE
    discount_amount     BIGINT;
    cart_total          BIGINT;
    discount_type       VARCHAR(10);
    max_discount        BIGINT := 5000000;
BEGIN
    SELECT Amount, discount_type INTO discount_amount, discount_type
    FROM DISCOUNT_CODE
    WHERE Code = NEW.Code;

    SELECT SUM(P.current_price * A.Quantity) INTO cart_total
    FROM ADDED_TO A 
    JOIN PRODUCTS P ON A.Product_ID = P.ID
    WHERE A.Cart_number = NEW.Cart_number;

    IF discount_type = 'percentage' THEN
        discount_amount := (cart_total * discount_amount) / 100;

        IF discount_amount > max_discount THEN
            discount_amount := max_discount;
        END IF;

    ELSIF discount_type = 'fixed' THEN
        IF discount_amount > cart_total THEN
            RAISE EXCEPTION 'Fixed discount cannot be more than the total amount of the cart!';
        END IF;
    END IF;

    RETURN NEW;    
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER Check_discount_mode
BEFORE INSERT ON APPLIED_TO
FOR EACH ROW 
EXECUTE FUNCTION Amount_Percentage_ceil();


-- Limit Discount Code Usage per User
CREATE OR REPLACE FUNCTION Usage_Per_User() RETURNS TRIGGER AS $$
    DECLARE
        Usage_count     INT;
        Max_usage_count INT;

    BEGIN
        SELECT COUNT(*) INTO Usage_count
        FROM APPLIED_TO
        WHERE ID = NEW.ID AND Code = NEW.Code;

        SELECT Usage_Limit INTO Max_usage_count
        FROM discount_code
        WHERE Code = NEW.Code;

        IF Usage_count >= Max_usage_count THEN 
            RAISE EXCEPTION 'User has exceeded the allowed number of uses for this discount code!';
        END IF;

        RETURN NEW;
END;
$$ 
LANGUAGE plpgsql;

CREATE TRIGGER Counter_Limiter
BEFORE INSERT ON APPLIED_TO
FOR EACH ROW
EXECUTE FUNCTION Usage_Per_User();


-- Epiration Date Controller 
CREATE OR REPLACE FUNCTION Expiration_date_Controller() RETURNS TRIGGER AS $$
    DECLARE
        Exi TIMESTAMP WITH TIME ZONE;
    BEGIN
        SELECT Expiration_date INTO Exi
        FROM DISCOUNT_CODE 
        WHERE Code = NEW.Code;


        IF Exi < NOW() THEN 
            RAISE EXCEPTION 'THIS CODE HAS BEEN EXPIRED!';
        END IF;
    
    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER Expiration_date_Controller_TRIGGER
BEFORE INSERT ON APPLIED_TO
FOR EACH ROW
EXECUTE function Expiration_date_Controller();


-- Unlock Shopping Cart After Payment
CREATE or REPLACE FUNCTION unlocked_after_payment() RETURNS TRIGGER AS $$
    BEGIN
        IF NEW.STATUS = 'Successful' THEN 
            UPDATE SHOPPING_CART
            SET STATUS = 'unlocked'
            WHERE Number = (SELECT Cart_number 
                            FROM ISSUED_FOR
                            WHERE Tracking_code = NEW.Tracking_code);
        END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER unlock_cart_after_payment
AFTER INSERT OR UPDATE ON TRANSACTION
FOR EACH ROW
EXECUTE FUNCTION unlocked_after_payment();

/* After 3 Days the Products will return */
CREATE OR REPLACE FUNCTION Restore_Stock_Block_Cart()
RETURNS VOID AS $$
BEGIN
    UPDATE PRODUCTS
    SET stock_count = stock_count + A.quantity
    FROM (
        SELECT Product_ID, COUNT(*) AS quantity
        FROM ADDED_TO
        WHERE Cart_ID IN (
            SELECT ID
            FROM SHOPPING_CART
            WHERE STATUS = 'locked'
              AND Time_stamp < NOW() - INTERVAL '3 DAYS'
        )
        GROUP BY Product_ID
    ) AS A
    WHERE PRODUCTS.id = A.Product_ID;

    UPDATE SHOPPING_CART
    SET 
        STATUS = 'blocked',
        Blocked_until = NOW() + INTERVAL '7 DAYS'
    WHERE STATUS = 'locked'
      AND Time_stamp < NOW() - INTERVAL '3 DAYS';
END;
$$ LANGUAGE plpgsql;

SELECT cron.schedule(
    'restore_stock_job', --task
    '0 0 * * *', -- scedual time to check every day
    $$CALL Restore_Stock_Block_Cart()$$
);

/* claculates the level and the amount of dicount by refaring */
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
        IF new_user_id = current_id THEN 
            RAISE EXCEPTION 'YOU CANT REFAER YOURSELF ! ';
        END IF;
        discount_percentage := 50 / (2 ^ (current_level - 1));

        IF discount_percentage < 1 THEN 
            discount_amount := 50000;
        ELSE 
            discount_amount := (1000000 * discount_percentage) / 100;
        END IF;

        INSERT INTO DISCOUNT_CODE (Amount, Usage_Limit, Expiration_date)
        VALUES (
            discount_amount,
            1, 
            CURRENT_TIMESTAMP + INTERVAL '7 DAYS'
        )
        RETURNING Code INTO discount_code_id;

        INSERT INTO PRIVATE_CODE (Code, Client_ID)
        VALUES (discount_code_id, current_id);

        SELECT Referral_Referrer INTO current_id 
        FROM CLIENT 
        WHERE ID = current_id;


        EXIT WHEN current_id IS NULL;
        current_level := current_level + 1;
    END LOOP;
END;
$$ LANGUAGE plpgsql;

/* checks if the subscription ended or not */
CREATE OR REPLACE FUNCTION Check_VIP_Expiration()
RETURNS VOID AS $$
BEGIN
    DELETE FROM VIP_CLIENT
    WHERE Subscription_expiration_time < NOW();

    UPDATE CLIENT
    SET is_vip = FALSE
    WHERE ID IN (
        SELECT ID
        FROM VIP_CLIENT
        WHERE Subscription_expiration_time < NOW()
    );
END;
$$ LANGUAGE plpgsql;

SELECT cron.schedule(
    'check_vip_expiration', --do this 
    '0 0 * * *', --everyday at 00:00
    $$CALL Check_VIP_Expiration()$$
);


/* dissabling 4 carts after subscription has expired */
CREATE OR REPLACE FUNCTION Disable_Extra_Carts()
RETURNS TRIGGER AS $$
BEGIN
    DELETE FROM SHOPPING_CART
    WHERE Client_ID = OLD.ID
      AND ID NOT IN (
          SELECT ID
          FROM SHOPPING_CART
          WHERE Client_ID = OLD.ID
          ORDER BY Time_stamp
          LIMIT 1
      );
    RETURN OLD;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER Remove_Extra_Carts
AFTER DELETE ON VIP_CLIENT
FOR EACH ROW
EXECUTE FUNCTION Disable_Extra_Carts();

CREATE OR REPLACE FUNCTION Monthly_15Percent_Refund()
RETURNS VOID AS $$
BEGIN
    UPDATE CLIENT C
    SET Wallet_balance = Wallet_balance + refund_data.refund_amount
    FROM (
        SELECT 
            S.Client_ID,
            SUM(P.current_price * A.Quantity * 0.15) AS refund_amount
        FROM 
            TRANSACTION T
        JOIN ISSUED_FOR I ON T.Tracking_code = I.Tracking_code
        JOIN SHOPPING_CART S ON I.Cart_number = S.Number
        JOIN ADDED_TO A ON S.Number = A.Cart_number
        JOIN PRODUCTS P ON A.Product_ID = P.ID
        WHERE 
            T.STATUS = 'Successful'
            AND T.Timestamp >= DATE_TRUNC('MONTH', CURRENT_DATE - INTERVAL '1 MONTH')
            AND T.Timestamp < DATE_TRUNC('MONTH', CURRENT_DATE)
        GROUP BY S.Client_ID
    ) AS refund_data
    WHERE C.ID = refund_data.Client_ID;
END;
$$ LANGUAGE plpgsql;

SELECT cron.schedule(
    'monthly_refund', 
    '0 0 1 * *', -- First day of Every month
    $$CALL Monthly_15Percent_Refund()$$
);

/* scedualed functions checks by this  */
-- SELECT * FROM cron.job_run_details;
-- to run each file 
-- psql -U UserName -d DBName -a -f file name.sql 
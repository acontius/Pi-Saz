BEGIN;

-- Referal invite's handling 
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


-- Trigger to Prevent Adding Products to Locked Carts
CREATE OR REPLACE FUNCTION Not_leeting_locked_shoppingCarts() RETURNS TRIGGER AS $$
DECLARE
    cart_status cart_status;

BEGIN
    SELECT STATUS INTO cart_status 
    FROM SHOPPING_CART 
    WHERE Number = NEW.Cart_number;

    IF cart_status = 'locked' THEN 
        RAISE EXCEPTION 'LOCKED CARTS CAN NOT TAKE ANY ACTIONS(ADD TO)';
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

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
CREATE OR REPLACE FUNCTION Cart_count_limits() RETURNS TRIGGER AS $$
DECLARE 
    cart_Counter INT;
    user_Type    BOOLEAN; 

BEGIN
    SELECT COUNT(*) INTO cart_Counter
    FROM SHOPPING_CART 
    WHERE ID = NEW.ID;
    SELECT EXISTS (SELECT 1 FROM VIP_CLIENT
    WHERE ID = NEW.ID) INTO user_Type;

    IF (user_Type) AND (cart_Counter > 5) THEN 
        RAISE EXCEPTION 'CAN NOT REQUEST FOR MORE THAN FIVE CARTS AS AN VIP USER';
    ELSIF NOT (user_Type) AND (cart_Counter > 1) THEN 
        RAISE EXCEPTION 'CAN NOT REQUEST FOR MORE THAN 1 CARTS AS AN CIP USER';
    END IF;

    RETURN NEW;
END;
$$
LANGUAGE plpgsql;

CREATE TRIGGER cart_limtter_trigger
BEFORE INSERT ON SHOPPING_CART
FOR EACH ROW 
EXECUTE FUNCTION Cart_count_limits() ;


-- Users Cannot Add Out-of-Stock Products to Their Shopping Cart
CREATE OR REPLACE FUNCTION Prevent_Out_stock() RETURNS TRIGGER AS $$
DECLARE
    quantity INT;

BEGIN 
    -- TG_OP is PSQL internal function that tells us which operationg is calling the trigger 
    IF NEW.Product_ID IS DISTINCT FROM OLD.Product_ID OR TG_OP = 'INSERT' THEN
    
    SELECT stock_count INTO quantity
    FROM PRODUCTS
    WHERE ID = NEW.ID;
    
        IF quantity <= 0 THEN 
            RAISE EXCEPTION 'ITEMS THAT ARE OUT OF STOCK CANT TAKE ANY ACTIONS TILL REFILL';
        END IF;
    END IF;
        RETURN NEW;

    END;
$$ 
LANGUAGE plpgsql;

CREATE TRIGGER stock_controller
BEFORE INSERT OR UPDATE ON ADDED_TO
FOR EACH ROW 
EXECUTE FUNCTION Prevent_Out_stock();

-- Update the Quantity if it was added or removed from shopping cart
CREATE OR REPLACE FUNCTION Update_the_quantity_on_cart_change() RETURNS TRIGGER AS $$

BEGIN 
    IF TG_OP = "INSERT" THEN 
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
        Amount            BIGINT;
        cart_total        BIGINT;
        discount_type     VARCHAR(10);
        max_discount      BIGINT := 5000000;

    BEGIN
        SELECT Amount, discount_type INTO Amount, discount_type
        FROM DISCOUNT_CODE
        WHERE Code = NEW.Code;

        SELECT SUM(P.current_price) INTO cart_total
        FROM added_to A JOIN products P ON A.products_ID = P.ID
        WHERE A.Cart_number = NEW.Cart_number;


        IF discount_type = 'percentage' THEN
            Amount := (cart_total * Amount) / 100;

            IF Amount > max_discount THEN
                Amount := max_discount;
            END IF;

        ELSIF discount_type = 'fixed' THEN
            IF Amount > cart_total THEN
                RAISE EXCEPTION 'Fixed Discount Can not be More Than Total Amount Of Cart!';
            END IF;
        END IF;
    
    RETURN NEW;    
END;
$$
LANGUAGE plpgsql;

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
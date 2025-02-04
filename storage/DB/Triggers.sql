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
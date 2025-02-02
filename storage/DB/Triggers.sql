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

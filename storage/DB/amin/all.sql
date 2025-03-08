CREATE TABLE IF NOT EXISTS PRODUCTS (
    id Serial PRIMARY KEY,
    category CHAR(255),
    image BYTEA,
    current_price INT CHECK (current_price > 0),
    stock_count INT CHECK (stock_count >= 0),
    brand VARCHAR(255),
    model VARCHAR(255)
);

CREATE TABLE IF NOT EXISTS HDD (
    id INT PRIMARY KEY,
    rotational_speed INT CHECK (rotational_speed >= 0),
    wattage INT CHECK (wattage >= 0),
    capacity INT CHECK (capacity >= 0),
    depth FLOAT CHECK (depth >= 0.0),
    height FLOAT CHECK (height >= 0.0),
    width FLOAT CHECK (width >= 0.0),
    FOREIGN KEY (id) REFERENCES PRODUCTS(id) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS CASE_TABLE (
    id BIGINT PRIMARY KEY,
    number_of_fans INT CHECK (number_of_fans >= 0),
    fan_size FLOAT CHECK (fan_size >= 0.0),
    wattage INT CHECK (wattage >= 0),
    type VARCHAR(30),
    material VARCHAR(30),
    color CHAR(7),  -- Hexadecimal Color Codes including '#'
    depth FLOAT CHECK (depth >= 0.0),
    height FLOAT CHECK (height >= 0.0),
    width FLOAT CHECK (width >= 0.0),
    FOREIGN KEY (id) REFERENCES PRODUCTS(id) ON DELETE CASCADE 
);

CREATE TABLE IF NOT EXISTS POWER_SUPPLY (
    id BIGINT PRIMARY KEY,
    supported_wattage INT CHECK (supported_wattage >= 0), 
    depth FLOAT CHECK (depth >= 0.0),
    height FLOAT CHECK (height >= 0.0),
    width FLOAT CHECK (width >= 0.0),
    FOREIGN KEY (id) REFERENCES PRODUCTS(id) ON DELETE CASCADE 
);

CREATE TABLE IF NOT EXISTS GPU (
    id BIGINT PRIMARY KEY,
    clock_speed INT CHECK (clock_speed >= 0), 
    ram_size INT CHECK (ram_size >= 0),        
    number_of_fans INT CHECK (number_of_fans >= 0), 
    wattage INT CHECK (wattage >= 0),         
    depth FLOAT CHECK (depth >= 0.0),
    height FLOAT CHECK (height >= 0.0),
    width FLOAT CHECK (width >= 0.0),
    FOREIGN KEY (id) REFERENCES PRODUCTS(id) ON DELETE CASCADE 
);

CREATE TABLE IF NOT EXISTS SSD (
    id BIGINT PRIMARY KEY,
    capacity INT CHECK (capacity >= 0), 
    wattage INT CHECK (wattage >= 0),        
    FOREIGN KEY (id) REFERENCES PRODUCTS(id) ON DELETE CASCADE 
);

CREATE TABLE IF NOT EXISTS RAM_STICK (
    id BIGINT PRIMARY KEY,
    frequency INT CHECK (frequency >= 0), 
    capacity INT CHECK (capacity >= 0),        
    generation VARCHAR(20), 
    wattage INT CHECK (wattage >= 0),         
    depth FLOAT CHECK (depth >= 0.0),
    height FLOAT CHECK (height >= 0.0),
    width FLOAT CHECK (width >= 0.0),
    FOREIGN KEY (id) REFERENCES PRODUCTS(id) ON DELETE CASCADE 
);

CREATE TABLE IF NOT EXISTS MOTHERBOARD (
    id BIGINT PRIMARY KEY,
    chipset VARCHAR(30), 
    number_of_memory_slots INT CHECK (number_of_memory_slots >= 0),        
    memory_speed_range INT CHECK (memory_speed_range >= 0), 
    wattage INT CHECK (wattage >= 0),         
    depth FLOAT CHECK (depth >= 0.0),
    height FLOAT CHECK (height >= 0.0),
    width FLOAT CHECK (width >= 0.0),
    FOREIGN KEY (id) REFERENCES PRODUCTS(id) ON DELETE CASCADE 
);

CREATE TABLE IF NOT EXISTS CPU (
    id BIGINT PRIMARY KEY,
    maximum_addressable_memory_limit INT CHECK (maximum_addressable_memory_limit >= 0),
    boost_frequency FLOAT CHECK (boost_frequency > 0.0),
    base_frequency FLOAT CHECK (base_frequency > 0.0),
    number_of_cores INT CHECK (number_of_cores > 0),
    number_of_threads INT CHECK (number_of_threads >= 0),
    microarchitecture VARCHAR(30),
    generation VARCHAR(20), 
    wattage INT CHECK (wattage >= 0),
    FOREIGN KEY (id) REFERENCES PRODUCTS(id) ON DELETE CASCADE 
);

CREATE TABLE IF NOT EXISTS COOLER (
    id BIGINT PRIMARY KEY,
    maximum_rotational_speed INT CHECK (maximum_rotational_speed >= 0),
    wattage INT CHECK (wattage >= 0),
    fan_size FLOAT CHECK (fan_size >= 0.0),
    cooling_method VARCHAR(30),
    depth FLOAT CHECK (depth >= 0.0),
    height FLOAT CHECK (height >= 0.0),
    width FLOAT CHECK (width >= 0.0),
    FOREIGN KEY (id) REFERENCES PRODUCTS(id) ON DELETE CASCADE 
);

CREATE TABLE IF NOT EXISTS CONNECTOR_COMPATIBLE_WITH (
    Gpu_id INT,
    Power_id INT,
    PRIMARY KEY (Gpu_id, Power_id),
    FOREIGN KEY (Gpu_id) REFERENCES GPU(id) ON DELETE CASCADE,
    FOREIGN KEY (Power_id) REFERENCES POWER_SUPPLY(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS SM_SLOT_COMPATIBLE_WITH (
    Motherboard_id INT,
    Ssd_id INT,
    PRIMARY KEY (Motherboard_id, Ssd_id),
    FOREIGN KEY (Motherboard_id) REFERENCES MOTHERBOARD(id) ON DELETE CASCADE,
    FOREIGN KEY (Ssd_id) REFERENCES SSD(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS GM_SLOT_COMPATIBLE_WITH (
    Motherboard_id INT,
    Gpu_id INT,
    PRIMARY KEY (Motherboard_id, Gpu_id),
    FOREIGN KEY (Motherboard_id) REFERENCES MOTHERBOARD(id) ON DELETE CASCADE,
    FOREIGN KEY (Gpu_id) REFERENCES GPU(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS RM_SLOT_COMPATIBLE_WITH (
    Motherboard_id INT,
    Ram_id INT,
    PRIMARY KEY (Motherboard_id, Ram_id),
    FOREIGN KEY (Motherboard_id) REFERENCES MOTHERBOARD(id) ON DELETE CASCADE,
    FOREIGN KEY (Ram_id) REFERENCES RAM_STICK(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS MC_SOCKET_COMPATIBLE_WITH (
    Motherboard_id INT,
    Cpu_id INT,
    PRIMARY KEY (Motherboard_id, Cpu_id),
    FOREIGN KEY (Motherboard_id) REFERENCES MOTHERBOARD(id) ON DELETE CASCADE,
    FOREIGN KEY (Cpu_id) REFERENCES CPU(id) ON DELETE CASCADE
);

CREATE TABLE IF NOT EXISTS CC_SOCKET_COMPATIBLE_WITH (
    Cooler_id INT,
    Cpu_id INT,
    PRIMARY KEY (Cooler_id, Cpu_id),
    FOREIGN KEY (Cooler_id) REFERENCES COOLER(id) ON DELETE CASCADE,
    FOREIGN KEY (Cpu_id) REFERENCES CPU(id) ON DELETE CASCADE
);
CREATE TABLE IF NOT EXISTS CLIENT(
    ID             SERIAL PRIMARY KEY,
    Phone_number   VARCHAR(11) UNIQUE NOT NULL,
    First_name     VARCHAR(255) NOT NULL,
    Last_name      VARCHAR(255) NOT NULL,
    Wallet_balance BIGINT CHECK(Wallet_balance >= 0) DEFAULT 0,
    Time_stamp     TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    Referal_code   VARCHAR(10) UNIQUE,
    is_vip         BOOLEAN DEFAULT FALSE,
    userPassword   VARCHAR(128) NOT NULL
);

CREATE TABLE IF NOT EXISTS VIP_CLIENT(
    ID                           INT PRIMARY KEY,
    Subscription_expiration_time TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP NOT NULL,
    
    FOREIGN KEY(ID) REFERENCES CLIENT(ID) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS REFERS(
    Refree   INT PRIMARY KEY,
    Referrer INT NOT NULL,

    FOREIGN KEY(Refree) REFERENCES CLIENT(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(Referrer) REFERENCES CLIENT(ID) ON DELETE CASCADE ON UPDATE CASCADE 
); 


CREATE TABLE IF NOT EXISTS ADDRESS(
    ID       INT NOT NULL,
    Province VARCHAR(255) NOT NULL,
    Remainer VARCHAR(511) NOT NULL,
    
    PRIMARY KEY(ID,Province,Remainer) ,
    FOREIGN KEY(ID) REFERENCES CLIENT(ID) ON DELETE CASCADE
);

CREATE TYPE cart_status AS ENUM(
    'archived',   -- After a period or end of proccess 
    'unlocked',   -- Open to use
    'locked',     -- After first submit
    'ready',      -- Ready to final submition
    'blocked'     -- after 3 days no paying 
);

CREATE TABLE IF NOT EXISTS SHOPPING_CART (
    Blocked_until TIMESTAMP,
    ID            INT NOT NULL,
    Number        VARCHAR(16) NOT NULL UNIQUE,
    Time_stamp    TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP, 
    STATUS        cart_status NOT NULL CHECK(STATUS <> 'locked') DEFAULT 'unlocked',

    PRIMARY KEY(ID,Number),
    FOREIGN KEY(ID) REFERENCES CLIENT(ID) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS LOCKED_SHOPPING_CART(
    ID          INT NOT NULL,
    Number      VARCHAR(16) NOT NULL UNIQUE,
    Cart_number VARCHAR(16) NOT NULL UNIQUE,
    Timestamp   TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY(ID,Cart_number,Number),
    FOREIGN KEY(ID) REFERENCES CLIENT(ID) ON DELETE CASCADE,
    FOREIGN KEY(Cart_number) REFERENCES SHOPPING_CART(Number) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS DISCOUNT_CODE(
    Code            SERIAL NOT NULL PRIMARY KEY UNIQUE,
    Amount          BIGINT CHECK(Amount > 0) NOT NULL,
    Usage_Limit     BIGINT CHECK(Usage_Limit > 0) NOT NULL,
    Usage_count     SMALLINT NOT NULL ,
    Expiration_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    discount_type   VARCHAR(10) CHECK (discount_type IN('fixed', 'percentage'))
);

CREATE TABLE IF NOT EXISTS PRIVATE_CODE(
    Code      INT NOT NULL PRIMARY KEY UNIQUE,
    ID        INT NOT NULL UNIQUE,
    Timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP + INTERVAL '10 days',

    FOREIGN KEY(ID) REFERENCES CLIENT(ID) ON DELETE CASCADE,
    FOREIGN KEY(Code) REFERENCES DISCOUNT_CODE(Code) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS PUBLIC_CODE(
    Code INT NOT NULL PRIMARY KEY,
        
    FOREIGN KEY(Code) REFERENCES DISCOUNT_CODE(Code) ON DELETE CASCADE
); 


CREATE TYPE TRANSACTION_STATUS AS ENUM(
    'Semi-Successful',
    'Successful',
    'Failed'
);


CREATE TABLE IF NOT EXISTS TRANSACTION(
    Timestamp     TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    Tracking_code VARCHAR(20) PRIMARY KEY UNIQUE,
    STATUS        TRANSACTION_STATUS NOT NULL
);


CREATE TABLE IF NOT EXISTS BANK_TRANSACTION(
    Tracking_code VARCHAR(20) PRIMARY KEY UNIQUE,
    Card_number   VARCHAR(16) NOT NULL,

    FOREIGN KEY(Tracking_code) REFERENCES TRANSACTION(Tracking_code) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS WALLET_TRANSACTION(
    Tracking_code VARCHAR(20) NOT NULL UNIQUE PRIMARY KEY,

    FOREIGN KEY(Tracking_code) REFERENCES TRANSACTION(Tracking_code) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS DEPOSITS_INTO_WALLET(
    Tracking_code VARCHAR(20) PRIMARY KEY ,
    ID            INT NOT NULL,
    Amount        BIGINT CHECK(Amount > 0) NOT NULL,

    FOREIGN KEY(ID) REFERENCES CLIENT(ID) ON DELETE CASCADE ON UPDATE CASCADE,
    FOREIGN KEY(Tracking_code) REFERENCES TRANSACTION(Tracking_code) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS SUBSCRIBES(
    Tracking_code VARCHAR(20) NOT NULL PRIMARY KEY UNIQUE,
    ID            INT NOT NULL,

    FOREIGN KEY(ID) REFERENCES CLIENT(ID) ON DELETE CASCADE,
    FOREIGN KEY(Tracking_code) REFERENCES TRANSACTION(Tracking_code) ON DELETE CASCADE ON UPDATE CASCADE
);


CREATE TABLE IF NOT EXISTS APPLIED_TO(
    ID            INT NOT NULL UNIQUE,
    Code          INT NOT NULL UNIQUE,
    Cart_number   VARCHAR(16) NOT NULL UNIQUE,
    Locked_number VARCHAR(16) NOT NULL UNIQUE,
    Timestamp     TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    PRIMARY KEY(ID,Code,Cart_number,Locked_number),
    FOREIGN KEY(ID) REFERENCES CLIENT(ID) ON DELETE CASCADE,
    FOREIGN KEY(Code) REFERENCES DISCOUNT_CODE(Code) ON DELETE CASCADE,
    FOREIGN KEY(Locked_number) REFERENCES LOCKED_SHOPPING_CART(Number) ON DELETE CASCADE,
    FOREIGN KEY(Cart_number) REFERENCES LOCKED_SHOPPING_CART(Cart_number) ON DELETE CASCADE
    );


CREATE TABLE IF NOT EXISTS ISSUED_FOR(
    ID            INT NOT NULL UNIQUE,
    Cart_number   VARCHAR(16) NOT NULL UNIQUE,
    Locked_number VARCHAR(16) NOT NULL UNIQUE,
    Tracking_code VARCHAR(20) NOT NULL PRIMARY KEY UNIQUE,

    FOREIGN KEY(ID) REFERENCES CLIENT(ID) ON DELETE CASCADE,
    FOREIGN KEY(Tracking_code) REFERENCES TRANSACTION(Tracking_code) ON DELETE CASCADE,
    FOREIGN KEY(Locked_number) REFERENCES LOCKED_SHOPPING_CART(Number) ON DELETE CASCADE,
    FOREIGN KEY(Cart_number) REFERENCES LOCKED_SHOPPING_CART(Cart_number) ON DELETE CASCADE
);


CREATE TABLE IF NOT EXISTS ADDED_TO(
    ID            INT NOT NULL UNIQUE,
    Product_ID    INT NOT NULL UNIQUE,
    Cart_number   VARCHAR(16) NOT NULL UNIQUE,
    Locked_number VARCHAR(16) NOT NULL UNIQUE,
    Quantity      INT CHECK (Quantity > 0) DEFAULT 1,

    PRIMARY KEY(ID,Product_ID,Cart_number,Locked_number),
    FOREIGN KEY(ID) REFERENCES CLIENT(ID) ON DELETE CASCADE,
    FOREIGN KEY(Product_ID) REFERENCES PRODUCTS(ID) ON DELETE CASCADE,
    FOREIGN KEY(Locked_number) REFERENCES LOCKED_SHOPPING_CART(Number) ON DELETE CASCADE,
    FOREIGN KEY(Cart_number) REFERENCES LOCKED_SHOPPING_CART(Cart_number) ON DELETE CASCADE
);

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
    WHERE Client_ID = NEW.Client_ID;

    SELECT is_vip INTO is_vip 
    FROM CLIENT 
    WHERE ID = NEW.Client_ID;

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
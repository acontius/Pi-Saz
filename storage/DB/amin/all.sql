BEGIN;

CREATE TABLE IF NOT EXISTS CLIENT(
    ID             SERIAL PRIMARY KEY,
    Phone_number   VARCHAR(11) UNIQUE NOT NULL,
    First_name     VARCHAR(255) NOT NULL,
    Last_name      VARCHAR(255) NOT NULL,
    Wallet_balance BIGINT CHECK(Wallet_balance >= 0) DEFAULT 0,
    Time_stamp     TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    Referal_code   INT UNIQUE,
    userPassword   VARCHAR(128) NOT NULL
);

-- ALTER TABLE CLIENT
-- ADD COLUMN userPassword VARCHAR(128) DEFAULT 'temporary_password' NOT NULL;


-- ALTER TABLE CLIENT ALTER COLUMN userPassword DROP DEFAULT;


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
    'archived',
    'unlocked',
    'locked',
    'ready'
);


CREATE TABLE IF NOT EXISTS SHOPPING_CART (
    ID     INT NOT NULL,
    Number VARCHAR(16) NOT NULL UNIQUE,
    STATUS cart_status NOT NULL (STATUS <> 'locked') DEFAULT 'unlocked',

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
    Timestamp TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,

    FOREIGN KEY(ID) REFERENCES CLIENT(ID) ON DELETE CASCADE,
    FOREIGN KEY (Code) REFERENCES DISCOUNT_CODE(Code) ON DELETE CASCADE
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

    PRIMARY KEY(ID,Product_ID,Cart_number,Locked_number),
    FOREIGN KEY(ID) REFERENCES CLIENT(ID) ON DELETE CASCADE,
    FOREIGN KEY(Product_ID) REFERENCES PRODUCTS(ID) ON DELETE CASCADE,
    FOREIGN KEY(Locked_number) REFERENCES LOCKED_SHOPPING_CART(Number) ON DELETE CASCADE,
    FOREIGN KEY(Cart_number) REFERENCES LOCKED_SHOPPING_CART(Cart_number) ON DELETE CASCADE
);


COMMIT;create DATABASE psaz;
\c psaz;-- creating DataBase
\i DataBase.sql

-- creating tables in order P then C
\i Products.sql
\i Clients.sql

-- creating constraints 
-- referal handling for all levels of inviters 
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
        
        IF NEW.Referal_code = NEW.ID THEN RAISE EXCEPTION 'A user cannot refer themselves';
        END IF;

        EXIT WHEN current_id IS NULL;

        current_level := current_level + 1;
    END LOOP;
END;
$$ 
LANGUAGE plpgsql;

-- accepted test case is :
-- INSERT INTO CLIENT (Phone_number, First_name, Last_name, Referal_code)
-- VALUES ('09123456789', 'Ali', 'Ahmadi', NULL);


--failed testcase are :
-- INSERT INTO CLIENT (Phone_number, First_name, Last_name, Referal_code)
-- VALUES ('09351234567', 'Test', 'User', 9999);

-- INSERT INTO CLIENT (Phone_number, First_name, Last_name, Referal_code)
-- VALUES ('09129999999', 'Duplicate', 'Test', 2);

-- Self-referral (should fail)
-- INSERT INTO CLIENT (Phone_number, First_name, Last_name, Referal_code)
-- VALUES ('09127777777', 'Self', 'Loop', 6);
BEGIN;

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
    id BIGINT PRIMARY KEY,
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

COMMIT;BEGIN;

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

    SELECT EXISTS (SELECT 1 FROM VIP_CLIENT WHERE ID = NEW.ID) INTO user_Type;

    IF user_Type AND cart_Counter >= 5 THEN 
        RAISE EXCEPTION 'CAN NOT REQUEST MORE THAN FIVE CARTS AS A VIP USER';

    ELSIF NOT user_Type AND cart_Counter >= 1 THEN 
        RAISE EXCEPTION 'CAN NOT REQUEST MORE THAN 1 CART AS A REGULAR USER';
    END IF;

    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER cart_limtter_trigger
BEFORE INSERT ON SHOPPING_CART
FOR EACH ROW 
EXECUTE FUNCTION Cart_count_limits();


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
    SELECT discount_code.Amount, discount_code.discount_type INTO discount_amount, discount_type
    FROM DISCOUNT_CODE
    WHERE Code = NEW.Code;

    SELECT SUM(P.current_price) INTO cart_total
    FROM ADDED_TO A JOIN PRODUCTS P ON A.Product_ID = P.ID
    WHERE A.Cart_number = NEW.Cart_number;

    IF discount_type = 'percentage' THEN
        discount_amount := (cart_total * discount_amount) / 100;

        IF discount_amount > max_discount THEN
            discount_amount := max_discount;
        END IF;

    ELSIF discount_type = 'fixed' THEN
        IF discount_amount > cart_total THEN
            RAISE EXCEPTION 'Fixed Discount Cannot Be More Than Total Amount Of Cart!';
        END IF;
    END IF;

    RETURN NEW;    
END;
$$ LANGUAGE plpgsql;


CREATE TRIGGER Check_discount_mode
BEFORE INSERT ON APPLIED_TO
FOR EACH ROW 
EXECUTE FUNCTION Amount_Percentage_ceil();

INSERT INTO ADDED_TO (ID, Product_ID, Cart_number, Locked_number)
VALUES (1, 1, 'CART123456789', 'LOCK123');




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



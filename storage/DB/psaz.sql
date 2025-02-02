-- CREATE DATABASE psaz;
-- \c psaz; PSQL INTERNAL COMMNAD

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


CREATE TABLE IF NOT EXISTS CLIENT(
    ID             SERIAL PRIMARY KEY,
    Phone_number   VARCHAR(11) UNIQUE NOT NULL,
    First_name     VARCHAR(255) NOT NULL,
    Last_name      VARCHAR(255) NOT NULL,
    Wallet_balance BIGINT CHECK(Wallet_balance >= 0) DEFAULT 0,
    Time_stamp     TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    Referal_code   INT UNIQUE
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
    'archived',
    'unlocked',
    'locked',
    'ready'
);


CREATE TABLE IF NOT EXISTS SHOPPING_CART (
    ID     INT NOT NULL,
    Number VARCHAR(16) NOT NULL UNIQUE,
    STATUS cart_status NOT NULL,

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
    Usage_Limit           BIGINT CHECK(Usage_Limit > 0) NOT NULL,
    Usage_count     SMALLINT NOT NULL ,
    Expiration_date TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
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


COMMIT;

-- if you accidentally used the command abow :
    -- DROP SCHEMA public CASCADE;  --ATTENTION : DONT RUN THIS COMMAND UNTILL YOU ARE SURE !!! 
-- use : create schema if not exists public; then use : psql -U userName -d databaseName -f psaz.sql to compile it !

-- SELECT table_name from information_schema.tables where table_schema = 'public'; 


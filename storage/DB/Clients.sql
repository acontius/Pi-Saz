CREATE TABLE IF NOT EXISTS CLIENT(
    ID             SERIAL PRIMARY KEY,
    Phone_number   VARCHAR(11) UNIQUE NOT NULL,
    First_name     VARCHAR(255) NOT NULL,
    Last_name      VARCHAR(255) NOT NULL,
    Wallet_balance BIGINT CHECK(Wallet_balance >= 0) DEFAULT 0,
    Time_stamp     TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    Referal_code   VARCHAR(10) UNIQUE,
    is_vip         BOOLEAN DEFAULT FALSE
);


-- alter table CLIENT
-- drop column userPassword;

-- INSERT into CLIENT(Phone_number, First_name, Last_name, Wallet_balance, is_vip)
-- VALUES ('09180048517', 'amin', 'shahabi', 285000, True)


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



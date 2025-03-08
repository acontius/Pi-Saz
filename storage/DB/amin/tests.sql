-- CIP user
INSERT INTO CLIENT (Phone_number, First_name, Last_name, userPassword) 
VALUES ('09123456789', 'Amin', 'shahabi', 'pass123');


-- VIP USER
INSERT INTO CLIENT (Phone_number, First_name, Last_name, Referal_code, userPassword) 
VALUES ('09123456780', 'Sepehr', 'Aberi', '123', 'pass456');


-- drop DATABASE psaz with(force);



INSERT INTO CLIENT (Phone_number, First_name, Last_name, Wallet_balance, is_vip)
VALUES 
    ('09123456789', 'John', 'Doe', 150000, FALSE),
    ('09187654321', 'Jane', 'Doe', 50000, TRUE);


INSERT INTO VIP_CLIENT (ID, Subscription_expiration_time)
VALUES 
    (1, '2024-12-31T23:59:59Z'),
    (3, '2024-06-30T23:59:59Z');

INSERT INTO ADDRESS (ID, Province, Remainer)
VALUES 
    (1, 'Tehran', '123 Main St'),
    (2, 'Isfahan', '456 Elm St'),
    (3, 'Shiraz', '789 Oak St');

INSERT INTO SHOPPING_CART (ID, Number, STATUS)
VALUES 
    (1, 'CART001', 'unlocked'),
    (2, 'CART002', 'ready');
    (3, 'CART003', 'blocked');
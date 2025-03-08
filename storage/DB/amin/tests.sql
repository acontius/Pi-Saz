-- CIP user
INSERT INTO CLIENT (Phone_number, First_name, Last_name, userPassword) 
VALUES ('09123456789', 'Amin', 'shahabi', 'pass123');


-- VIP USER
INSERT INTO CLIENT (Phone_number, First_name, Last_name, Referal_code, userPassword) 
VALUES ('09123456780', 'Sepehr', 'Aberi', '123', 'pass456');


-- drop DATABASE psaz with(force);
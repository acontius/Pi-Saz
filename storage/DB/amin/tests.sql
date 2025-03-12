-- -- CIP user
-- INSERT INTO CLIENT (Phone_number, First_name, Last_name, userPassword) 
-- VALUES ('09123456789', 'Amin', 'shahabi', 'pass123');


-- -- VIP USER
-- INSERT INTO CLIENT (Phone_number, First_name, Last_name, Referal_code, userPassword) 
-- VALUES ('09123456780', 'Sepehr', 'Aberi', '123', 'pass456');


-- -- drop DATABASE psaz with(force);



-- INSERT INTO CLIENT (Phone_number, First_name, Last_name, Wallet_balance, is_vip)
-- VALUES 
--     ('09123456789', 'John', 'Doe', 150000, FALSE),
--     ('09187654321', 'Jane', 'Doe', 50000, TRUE);


-- INSERT INTO VIP_CLIENT (ID, Subscription_expiration_time)
-- VALUES 
--     (1, '2024-12-31T23:59:59Z'),
--     (3, '2024-06-30T23:59:59Z');

-- INSERT INTO ADDRESS (ID, Province, Remainer)
-- VALUES 
--     (1, 'Tehran', '123 Main St'),
--     (2, 'Isfahan', '456 Elm St'),
--     (3, 'Shiraz', '789 Oak St');

-- INSERT INTO SHOPPING_CART (ID, Number, STATUS)
-- VALUES 
--     (1, 'CART001', 'unlocked'),
--     (2, 'CART002', 'ready'),
--     (3, 'CART003', 'blocked');



-- -- Insert Products
-- INSERT INTO PRODUCTS (id, category, brand, model, current_price, stock_count) VALUES
-- -- CPU
-- (1, 'CPU', 'Intel', 'i7-10700K', 30000, 10),
-- -- Motherboard (Compatible with CPU 1)
-- (2, 'Motherboard', 'ASUS', 'Z490-A', 20000, 5),
-- -- RAM (DDR4 Compatible)
-- (3, 'RAM', 'Corsair', 'Vengeance LPX 16GB', 8000, 20),
-- -- RAM (DDR3 Incompatible)
-- (4, 'RAM', 'Kingston', 'DDR3 8GB', 4000, 15),
-- -- Power Supply
-- (5, 'PowerSupply', 'Corsair', 'RM750x', 15000, 8),
-- -- GPU
-- (6, 'GPU', 'NVIDIA', 'RTX 3080', 70000, 3),
-- -- Case
-- (7, 'Case', 'NZXT', 'H510', 8000, 12),
-- -- Cooler
-- (8, 'Cooler', 'Cooler Master', 'Hyper 212', 5000, 7);

-- -- Insert CPU Details
-- INSERT INTO CPU (id, base_frequency, boost_frequency, number_of_cores, number_of_threads, wattage, microarchitecture, generation)
-- VALUES (1, 3.8, 5.1, 8, 16, 125, 'Comet Lake', '10th Gen');

-- -- Insert Motherboard Details
-- INSERT INTO MOTHERBOARD (id, chipset, number_of_memory_slots, memory_speed_range, wattage, depth, height, width)
-- VALUES (2, 'Z490', 4, 3200, 50, 30.5, 24.4, 30.5);

-- -- Insert RAM Details
-- INSERT INTO RAM_STICK (id, frequency, capacity, generation, wattage, depth, height, width)
-- VALUES
-- (3, 3200, 16, 'DDR4', 5, 13.3, 3.1, 13.3),  -- Compatible
-- (4, 1600, 8, 'DDR3', 4, 13.3, 3.1, 13.3);   -- Incompatible

-- -- Insert Power Supply
-- INSERT INTO POWER_SUPPLY (id, supported_wattage, depth, height, width)
-- VALUES (5, 750, 15.0, 8.6, 15.0);

-- -- Insert GPU
-- INSERT INTO GPU (id, clock_speed, ram_size, number_of_fans, wattage, depth, height, width)
-- VALUES (6, 1710, 10, 3, 320, 28.5, 11.2, 5.0);

-- -- Insert Case
-- INSERT INTO CASE_TABLE (id, number_of_fans, fan_size, wattage, type, material, color, depth, height, width)
-- VALUES (7, 2, 12.0, 0, 'Mid Tower', 'Steel', '#000000', 45.0, 45.0, 20.0);

-- -- Insert Cooler
-- INSERT INTO COOLER (id, maximum_rotational_speed, wattage, fan_size, cooling_method, depth, height, width)
-- VALUES (8, 2000, 10, 12.0, 'Air', 12.0, 15.8, 8.0);

-- -- Compatibility Tables
-- -- CPU-Motherboard Compatibility
-- INSERT INTO MC_SOCKET_COMPATIBLE_WITH (motherboard_id, cpu_id) VALUES (2, 1);

-- -- RAM-Motherboard Compatibility (Only DDR4)
-- INSERT INTO RM_SLOT_COMPATIBLE_WITH (motherboard_id, ram_id) VALUES (2, 3);

-- -- GPU-Power Supply Compatibility
-- INSERT INTO CONNECTOR_COMPATIBLE_WITH (gpu_id, power_id) VALUES (6, 5);

-- -- Cooler-CPU Compatibility
-- INSERT INTO CC_SOCKET_COMPATIBLE_WITH (cooler_id, cpu_id) VALUES (8, 1);


INSERT INTO CLIENT (Phone_number, First_name, Last_name, Wallet_balance, is_vip)
VALUES ('09180048517', 'Amin', 'Shahabi', 285000, FALSE);


INSERT INTO CLIENT (Phone_number, First_name, Last_name, Wallet_balance, is_vip)
VALUES ('09181112222', 'Sara', 'Ahmadi', 500000, TRUE);


INSERT INTO CLIENT (Phone_number, First_name, Last_name, Wallet_balance, is_vip)
VALUES ('09182223333', 'Ali', 'Mohammadi', 100000, FALSE);

INSERT INTO PRODUCTS (category, current_price, stock_count, brand, model)
VALUES ('HDD', 3000000, 10, 'Seagate', 'Barracuda')
RETURNING id;

INSERT INTO HDD (id, rotational_speed, wattage, capacity, depth, height, width)
VALUES (1, 7200, 5, 2000, 147.0, 26.1, 101.6);


INSERT INTO PRODUCTS (category, current_price, stock_count, brand, model)
VALUES ('GPU', 15000000, 5, 'NVIDIA', 'RTX 3080')
RETURNING id;


INSERT INTO PRODUCTS (category, current_price, stock_count, brand, model)
VALUES ('GPU', 15000000, 5, 'NVIDIA', 'RTX 3080')
RETURNING id;


INSERT INTO GPU (id, clock_speed, ram_size, number_of_fans, wattage, depth, height, width)
VALUES (2, 1710, 10, 3, 320, 285.0, 112.0, 50.0);


INSERT INTO PRODUCTS (category, current_price, stock_count, brand, model)
VALUES ('SSD', 2000000, 15, 'Samsung', '970 EVO')
RETURNING id;


INSERT INTO SSD (id, capacity, wattage)
VALUES (3, 1000, 6);



INSERT INTO ADDRESS (ID, Province, Remainer)
VALUES (1, 'Tehran', '123 Main St, Tehran');



INSERT INTO ADDRESS (ID, Province, Remainer)
VALUES (2, 'Isfahan', '789 Historic Ave, Isfahan');



INSERT INTO CLIENT (Phone_number, First_name, Last_name, Wallet_balance, is_vip)
VALUES ('09180000000', 'Ali', 'Mohammadi', 100000, FALSE);


INSERT INTO ADDRESS (ID, Province, Remainer)
VALUES (8, 'Shiraz', '101 Garden Blvd, Shiraz'); 

INSERT INTO VIP_CLIENT (ID, Subscription_expiration_time)
VALUES (2, CURRENT_TIMESTAMP + INTERVAL '30 days');


INSERT INTO REFERS (Refree, Referrer)
VALUES (5, 1);



-- Insert additional products
INSERT INTO PRODUCTS (category, current_price, stock_count, brand, model)
VALUES ('Motherboard', 5000000, 8, 'ASUS', 'ROG Strix Z690-E')
RETURNING id;


INSERT INTO PRODUCTS (category, current_price, stock_count, brand, model)
VALUES ('CPU', 8000000, 6, 'Intel', 'Core i9-12900K')
RETURNING id;


INSERT INTO PRODUCTS (category, current_price, stock_count, brand, model)
VALUES ('RAM Stick', 3000000, 10, 'Corsair', 'Vengeance DDR5 32GB')
RETURNING id;

INSERT INTO RAM_STICK (id, frequency, capacity, generation, wattage, depth, height, width)
VALUES (6, 5200, 32, 'DDR5', 10, 133.0, 35.0, 7.0);

INSERT INTO PRODUCTS (category, current_price, stock_count, brand, model)
VALUES ('Power Supply', 4000000, 7, 'Corsair', 'RM850x')
RETURNING id;

INSERT INTO POWER_SUPPLY (id, supported_wattage, depth, height, width)
VALUES (7, 850, 160.0, 86.0, 150.0);

-- Insert compatibility data
INSERT INTO MC_SOCKET_COMPATIBLE_WITH (Motherboard_id, Cpu_id)
VALUES (4, 5); -- Motherboard (ASUS ROG Strix Z690-E) compatible with CPU (Intel Core i9-12900K)

INSERT INTO RM_SLOT_COMPATIBLE_WITH (Motherboard_id, Ram_id)
VALUES (4, 6); -- Motherboard compatible with RAM (Corsair Vengeance DDR5)

INSERT INTO GM_SLOT_COMPATIBLE_WITH (Motherboard_id, Gpu_id)
VALUES (4, 2); -- Motherboard compatible with GPU (NVIDIA RTX 3080)

INSERT INTO SM_SLOT_COMPATIBLE_WITH (Motherboard_id, Ssd_id)
VALUES (4, 3); -- Motherboard compatible with SSD (Samsung 970 EVO)

INSERT INTO CONNECTOR_COMPATIBLE_WITH (Gpu_id, Power_id)
VALUES (2, 7); -- GPU (NVIDIA RTX 3080) compatible with Power Supply (Corsair RM850x)

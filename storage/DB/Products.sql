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

COMMIT;
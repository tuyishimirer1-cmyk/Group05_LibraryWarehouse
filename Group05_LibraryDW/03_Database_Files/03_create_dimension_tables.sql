-- DIMENSION TABLES
USE library_analytics_dw;

-- 1. DATE DIMENSION (Critical for time analysis)
CREATE TABLE dim_date (
    date_key INT PRIMARY KEY,  -- Surrogate key: YYYYMMDD
    full_date DATE NOT NULL,
    day INT,
    month INT,
    month_name VARCHAR(20),
    quarter INT,
    quarter_name VARCHAR(10),
    year INT,
    day_of_week VARCHAR(20),
    is_weekend BOOLEAN,
    is_holiday BOOLEAN DEFAULT FALSE
);

-- 2. STUDENT DIMENSION
CREATE TABLE dim_student (
    student_key INT AUTO_INCREMENT PRIMARY KEY,  -- Surrogate key
    student_id VARCHAR(20) UNIQUE,  -- Natural key: STU-2024-001
    department_standardized VARCHAR(50),
    student_level VARCHAR(20),  -- Undergraduate, Graduate, Staff, Faculty
    is_active BOOLEAN DEFAULT TRUE
);

-- 3. RESOURCE DIMENSION
CREATE TABLE dim_resource (
    resource_key INT AUTO_INCREMENT PRIMARY KEY,
    resource_id VARCHAR(50),  -- ISBN for books, resource code for digital
    resource_type VARCHAR(20),  -- 'Physical Book', 'E-book', 'Journal', 'Study Room'
    category VARCHAR(50),  -- Fiction, Reference, Textbook, etc.
    title VARCHAR(255),  -- Book title (if available)
    is_digital BOOLEAN
);

-- 4. LOCATION DIMENSION (for study rooms)
CREATE TABLE dim_location (
    location_key INT AUTO_INCREMENT PRIMARY KEY,
    room_number_standardized VARCHAR(10),  -- R101 (standardized)
    room_type VARCHAR(20),  -- Small, Medium, Large, Group Study
    building VARCHAR(50),
    capacity INT
);

-- 5. TIME SLOT DIMENSION (for room bookings)
CREATE TABLE dim_time_slot (
    time_slot_key INT AUTO_INCREMENT PRIMARY KEY,
    time_slot_standardized VARCHAR(20),  -- Morning, Afternoon, Evening
    start_time TIME,
    end_time TIME
);
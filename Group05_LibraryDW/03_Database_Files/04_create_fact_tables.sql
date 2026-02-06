-- FACT TABLES
USE library_analytics_dw;

-- Main consolidated fact table
CREATE TABLE fact_library_usage (
    usage_key BIGINT AUTO_INCREMENT PRIMARY KEY,
    
    -- FOREIGN KEYS (links to dimensions)
    date_key INT NOT NULL,
    student_key INT,
    resource_key INT,
    location_key INT,
    time_slot_key INT,
    
    -- MEASURES (quantitative data)
    loan_count INT DEFAULT 0,           -- For book transactions
    download_count INT DEFAULT 0,       -- For digital resources
    booking_count INT DEFAULT 0,        -- For room bookings
    loan_duration_days INT,             -- NULL if not a loan
    download_duration_minutes INT,      -- NULL if not a download
    booking_duration_hours DECIMAL(5,2), -- NULL if not a booking
    
    -- Source tracking
    source_system VARCHAR(20),          -- 'BOOK', 'DIGITAL', 'ROOM'
    original_transaction_id VARCHAR(50), -- Original ID from source
    
    -- Timestamps
    created_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    
    -- CONSTRAINTS
    FOREIGN KEY (date_key) REFERENCES dim_date(date_key),
    FOREIGN KEY (student_key) REFERENCES dim_student(student_key),
    FOREIGN KEY (resource_key) REFERENCES dim_resource(resource_key),
    FOREIGN KEY (location_key) REFERENCES dim_location(location_key),
    FOREIGN KEY (time_slot_key) REFERENCES dim_time_slot(time_slot_key),
    
    -- Ensure at least one measure is > 0
    CONSTRAINT chk_at_least_one_measure CHECK (
        loan_count > 0 OR 
        download_count > 0 OR 
        booking_count > 0
    )
);
-- STAGING TABLES (raw data from sources)
USE library_analytics_dw;

CREATE TABLE staging_book_transactions (
    staging_id INT AUTO_INCREMENT PRIMARY KEY,
    TransactionID INT,
    StudentID VARCHAR(20),
    BookISBN VARCHAR(20),
    CheckoutDate VARCHAR(50),  -- String for various formats
    ReturnDate VARCHAR(50),
    Department VARCHAR(50),
    BookCategory VARCHAR(50),
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    source_file VARCHAR(100)
);

CREATE TABLE staging_digital_usage (
    staging_id INT AUTO_INCREMENT PRIMARY KEY,
    Date VARCHAR(50),
    UserType VARCHAR(50),
    ResourceType VARCHAR(50),
    Faculty VARCHAR(50),
    DownloadCount INT,
    Duration_Minutes INT,
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE staging_room_bookings (
    staging_id INT AUTO_INCREMENT PRIMARY KEY,
    BookingID INT,
    RoomNumber VARCHAR(10),
    BookingDate VARCHAR(50),
    TimeSlot VARCHAR(20),
    StudentID VARCHAR(20),
    DurationHours DECIMAL(5,2),
    Purpose VARCHAR(50),
    load_timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);
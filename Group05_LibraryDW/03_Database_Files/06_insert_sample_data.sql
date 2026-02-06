-- SAMPLE DATA INSERTION SCRIPT
-- Run after creating all tables (01-05 scripts)
USE library_analytics_dw;

-- ============================================
-- 1. POPULATE DATE DIMENSION (3 months of data)
-- ============================================
INSERT INTO dim_date (date_key, full_date, day, month, month_name, quarter, quarter_name, year, day_of_week, is_weekend)
VALUES
-- January 2024
(20240101, '2024-01-01', 1, 1, 'January', 1, 'Q1', 2024, 'Monday', FALSE),
(20240102, '2024-01-02', 2, 1, 'January', 1, 'Q1', 2024, 'Tuesday', FALSE),
(20240103, '2024-01-03', 3, 1, 'January', 1, 'Q1', 2024, 'Wednesday', FALSE),
(20240104, '2024-01-04', 4, 1, 'January', 1, 'Q1', 2024, 'Thursday', FALSE),
(20240105, '2024-01-05', 5, 1, 'January', 1, 'Q1', 2024, 'Friday', FALSE),
(20240106, '2024-01-06', 6, 1, 'January', 1, 'Q1', 2024, 'Saturday', TRUE),
(20240107, '2024-01-07', 7, 1, 'January', 1, 'Q1', 2024, 'Sunday', TRUE),
(20240115, '2024-01-15', 15, 1, 'January', 1, 'Q1', 2024, 'Monday', FALSE),
(20240116, '2024-01-16', 16, 1, 'January', 1, 'Q1', 2024, 'Tuesday', FALSE),

-- February 2024
(20240201, '2024-02-01', 1, 2, 'February', 1, 'Q1', 2024, 'Thursday', FALSE),
(20240210, '2024-02-10', 10, 2, 'February', 1, 'Q1', 2024, 'Saturday', TRUE),
(20240212, '2024-02-12', 12, 2, 'February', 1, 'Q1', 2024, 'Monday', FALSE),
(20240215, '2024-02-15', 15, 2, 'February', 1, 'Q1', 2024, 'Thursday', FALSE),

-- March 2024
(20240301, '2024-03-01', 1, 3, 'March', 1, 'Q1', 2024, 'Friday', FALSE),
(20240305, '2024-03-05', 5, 3, 'March', 1, 'Q1', 2024, 'Tuesday', FALSE),
(20240310, '2024-03-10', 10, 3, 'March', 1, 'Q1', 2024, 'Sunday', TRUE),
(20240315, '2024-03-15', 15, 3, 'March', 1, 'Q1', 2024, 'Friday', FALSE),
(20240320, '2024-03-20', 20, 3, 'March', 1, 'Q1', 2024, 'Wednesday', FALSE);

-- ============================================
-- 2. POPULATE STUDENT DIMENSION
-- ============================================
INSERT INTO dim_student (student_id, department_standardized, student_level, is_active)
VALUES
-- Computer Science students
('STU-2024-001', 'Computer Science', 'Undergraduate', TRUE),
('STU-2024-002', 'Computer Science', 'Undergraduate', TRUE),
('STU-2024-003', 'Computer Science', 'Graduate', TRUE),

-- Engineering students
('STU-2024-004', 'Engineering', 'Undergraduate', TRUE),
('STU-2024-005', 'Engineering', 'Graduate', TRUE),

-- Business students
('STU-2024-006', 'Business', 'Undergraduate', TRUE),
('STU-2024-007', 'Business', 'Graduate', TRUE),

-- Faculty/Staff
('FAC-2024-001', 'Computer Science', 'Faculty', TRUE),
('STA-2024-001', 'Library', 'Staff', TRUE),

-- Unknown (for walk-ins)
('UNKNOWN-001', 'Unknown', 'Other', TRUE);

-- ============================================
-- 3. POPULATE RESOURCE DIMENSION
-- ============================================
INSERT INTO dim_resource (resource_id, resource_type, category, title, is_digital)
VALUES
-- Physical Books
('978-0134685991', 'Physical Book', 'Textbook', 'Database System Concepts', FALSE),
('978-0133970777', 'Physical Book', 'Textbook', 'Operating System Concepts', FALSE),
('978-0262033848', 'Physical Book', 'Textbook', 'Introduction to Algorithms', FALSE),
('978-1982100551', 'Physical Book', 'Fiction', 'Test Book Fiction', FALSE),
('978-1234567890', 'Physical Book', 'Reference', 'Library Reference Guide', FALSE),

-- E-books
('EBOOK-001', 'E-book', 'Textbook', 'Data Mining E-book', TRUE),
('EBOOK-002', 'E-book', 'Textbook', 'Machine Learning Basics', TRUE),
('EBOOK-003', 'E-book', 'Journal', 'Journal of Computer Science', TRUE),

-- Journals
('JRNL-2024-001', 'Journal', 'Academic', 'IEEE Transactions', TRUE),
('JRNL-2024-002', 'Journal', 'Academic', 'ACM Computing Surveys', TRUE),

-- Study Rooms (treated as resources)
('ROOM-R101', 'Study Room', 'Group Study', 'Room R101', FALSE),
('ROOM-R102', 'Study Room', 'Individual', 'Room R102', FALSE),
('ROOM-R201', 'Study Room', 'Group Study', 'Room R201', FALSE);

-- ============================================
-- 4. POPULATE LOCATION DIMENSION
-- ============================================
INSERT INTO dim_location (room_number_standardized, room_type, building, capacity)
VALUES
('R101', 'Group Study', 'Main Library', 8),
('R102', 'Individual', 'Main Library', 1),
('R201', 'Group Study', 'Main Library', 12),
('R202', 'Conference', 'Main Library', 20),
('D101', 'Digital Lab', 'Science Wing', 15);

-- ============================================
-- 5. POPULATE TIME SLOT DIMENSION
-- ============================================
INSERT INTO dim_time_slot (time_slot_standardized, start_time, end_time)
VALUES
('Morning', '08:00:00', '12:00:00'),
('Afternoon', '12:00:00', '17:00:00'),
('Evening', '17:00:00', '22:00:00'),
('Night', '22:00:00', '08:00:00');

-- ============================================
-- 6. POPULATE FACT TABLE (Library Usage)
-- ============================================
INSERT INTO fact_library_usage 
    (date_key, student_key, resource_key, location_key, time_slot_key, 
     loan_count, download_count, booking_count, loan_duration_days, 
     download_duration_minutes, booking_duration_hours, source_system, original_transaction_id)
VALUES
-- BOOK LOANS (Computer Science students borrowing books)
(20240115, 1, 1, NULL, NULL, 1, 0, 0, 14, NULL, NULL, 'BOOK', '1001'), -- CS student borrows DB book for 14 days
(20240115, 2, 2, NULL, NULL, 1, 0, 0, 7, NULL, NULL, 'BOOK', '1002'), -- CS student borrows OS book
(20240116, 3, 3, NULL, NULL, 1, 0, 0, 21, NULL, NULL, 'BOOK', '1003'), -- CS grad student borrows Algorithms

-- DIGITAL DOWNLOADS (Engineering students downloading e-books)
(20240115, 4, 6, NULL, NULL, 0, 1, 0, NULL, 45, NULL, 'DIGITAL', 'D001'), -- Eng student downloads Data Mining ebook
(20240116, 5, 7, NULL, NULL, 0, 1, 0, NULL, 90, NULL, 'DIGITAL', 'D002'), -- Eng grad downloads ML ebook
(20240201, 4, 9, NULL, NULL, 0, 3, 0, NULL, 120, NULL, 'DIGITAL', 'D003'), -- Eng student downloads IEEE journal

-- STUDY ROOM BOOKINGS
(20240315, 1, 11, 1, 1, 0, 0, 1, NULL, NULL, 2.0, 'ROOM', '5001'), -- CS student books R101 in morning
(20240315, 2, 12, 2, 2, 0, 0, 1, NULL, NULL, 3.5, 'ROOM', '5002'), -- CS student books R102 in afternoon
(20240320, 6, 13, 3, 3, 0, 0, 1, NULL, NULL, 4.0, 'ROOM', '5003'), -- Business student books R201 in evening

-- MIXED USAGE (same student uses multiple services)
(20240210, 1, 6, NULL, NULL, 0, 1, 0, NULL, 60, NULL, 'DIGITAL', 'D004'), -- CS student also downloads ebook
(20240212, 1, 11, 1, 2, 0, 0, 1, NULL, NULL, 2.0, 'ROOM', '5004'), -- Same student books room later

-- BUSINESS DEPARTMENT USAGE
(20240215, 6, 4, NULL, NULL, 1, 0, 0, 10, NULL, NULL, 'BOOK', '1004'), -- Business student borrows fiction
(20240305, 7, 5, NULL, NULL, 1, 0, 0, 5, NULL, NULL, 'BOOK', '1005'), -- Business grad borrows reference

-- UNKNOWN/WALK-IN ROOM BOOKING
(20240310, 10, 11, 1, 3, 0, 0, 1, NULL, NULL, 1.5, 'ROOM', '5005'), -- Unknown walk-in books room

-- FACULTY USAGE
(20240103, 8, 8, NULL, NULL, 0, 1, 0, NULL, 30, NULL, 'DIGITAL', 'D005'), -- Faculty downloads journal
(20240104, 8, 2, NULL, NULL, 1, 0, 0, 30, NULL, NULL, 'BOOK', '1006'); -- Faculty borrows textbook

-- ============================================
-- 7. POPULATE STAGING TABLES (Raw source data - with issues!)
-- ============================================

-- STAGING BOOK TRANSACTIONS (with data quality issues)
INSERT INTO staging_book_transactions 
    (TransactionID, StudentID, BookISBN, CheckoutDate, ReturnDate, Department, BookCategory, source_file)
VALUES
-- Inconsistent department names
(1001, 'STU-2024-001', '978-0134685991', '2024-01-15', '2024-01-29', 'CS', 'Textbook', 'book_export.csv'),
(1002, 'STU-2024-002', '978-0133970777', '2024-01-15', NULL, 'Computer Science', 'Textbook', 'book_export.csv'), -- NULL return date
(1003, 'STU-2024-003', '978-0262033848', '01/16/2024', '02/06/2024', 'CompSci', 'Textbook', 'book_export.csv'), -- Different date format

-- More inconsistent data
(1004, 'STU-2024-006', '978-1982100551', '2024-02-15', '2024-02-25', 'Business', 'Fiction', 'book_export.csv'),
(1005, 'STU-2024-007', '978-1234567890', '2024-03-05', '2024-03-10', 'BUS', 'Reference', 'book_export.csv'), -- Different department code

-- Faculty transaction
(1006, 'FAC-2024-001', '978-0133970777', '2024-01-04', '2024-02-03', 'CS', 'Textbook', 'book_export.csv');

-- STAGING DIGITAL USAGE (with data quality issues)
INSERT INTO staging_digital_usage 
    (Date, UserType, ResourceType, Faculty, DownloadCount, Duration_Minutes)
VALUES
-- Multiple date formats
('2024-01-15', 'Student', 'E-book', 'ENG', 1, 45),
('2024-01-16', 'Graduate Student', 'e-Book', 'Engineering', 1, 90), -- Inconsistent capitalization
('2024-02-01', 'Student', 'Journal', 'Engr', 3, 120), -- Different faculty code
('Jan 15, 2024', 'Faculty', 'Journal', 'CS', 1, 30), -- Different date format
('2024-02-10', 'Student', 'E-book', 'CS', 1, NULL); -- NULL duration

-- STAGING ROOM BOOKINGS (with data quality issues)
INSERT INTO staging_room_bookings 
    (BookingID, RoomNumber, BookingDate, TimeSlot, StudentID, DurationHours, Purpose)
VALUES
-- Inconsistent room numbers
(5001, 'R101', '2024-03-15', 'Morning', 'STU-2024-001', 2.0, 'Study'),
(5002, 'R-102', '2024-03-15', '8AM-10AM', 'STU-2024-002', 2.0, 'Group Project'), -- Different room format
(5003, 'Room201', '2024-03-20', 'Evening', 'STU-2024-006', 4.0, 'Meeting'), -- Different room format
(5004, 'R101', '2024-02-12', '12PM-2PM', 'STU-2024-001', 2.0, 'Study'), -- Different time format
(5005, 'R101', '15-Mar-2024', 'Night', NULL, 1.5, 'Study'), -- NULL student ID (walk-in), different date format
(5006, 'R101', '2024-03-15', 'Morning', 'STU-2024-001', 2.0, 'Study'); -- Potential duplicate

-- ============================================
-- 8. VERIFICATION QUERIES
-- ============================================

-- Count records in each table
SELECT 'dim_date' as table_name, COUNT(*) as record_count FROM dim_date
UNION ALL
SELECT 'dim_student', COUNT(*) FROM dim_student
UNION ALL
SELECT 'dim_resource', COUNT(*) FROM dim_resource
UNION ALL
SELECT 'dim_location', COUNT(*) FROM dim_location
UNION ALL
SELECT 'dim_time_slot', COUNT(*) FROM dim_time_slot
UNION ALL
SELECT 'fact_library_usage', COUNT(*) FROM fact_library_usage
UNION ALL
SELECT 'staging_book_transactions', COUNT(*) FROM staging_book_transactions
UNION ALL
SELECT 'staging_digital_usage', COUNT(*) FROM staging_digital_usage
UNION ALL
SELECT 'staging_room_bookings', COUNT(*) FROM staging_room_bookings;

-- Sample business question: Which department uses library most?
SELECT 
    s.department_standardized AS department,
    SUM(f.loan_count) AS total_loans,
    SUM(f.download_count) AS total_downloads,
    SUM(f.booking_count) AS total_bookings,
    (SUM(f.loan_count) + SUM(f.download_count) + SUM(f.booking_count)) AS total_usage
FROM fact_library_usage f
JOIN dim_student s ON f.student_key = s.student_key
GROUP BY s.department_standardized
ORDER BY total_usage DESC;

-- Sample business question: Monthly usage trends
SELECT 
    d.year,
    d.month_name,
    SUM(f.loan_count) AS physical_books,
    SUM(f.download_count) AS digital_downloads,
    SUM(f.booking_count) AS room_bookings
FROM fact_library_usage f
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY d.year, d.month_name, d.month
ORDER BY d.year, d.month;

-- Show data quality issues in staging
SELECT 'Book Transactions' as source, 'Inconsistent Departments' as issue, 
       GROUP_CONCAT(DISTINCT Department) as examples
FROM staging_book_transactions 
WHERE Department IN ('CS', 'CompSci', 'Computer Science')
UNION ALL
SELECT 'Digital Usage', 'Multiple Date Formats', 
       GROUP_CONCAT(DISTINCT Date LIMIT 3)
FROM staging_digital_usage
UNION ALL
SELECT 'Room Bookings', 'Inconsistent Room Numbers', 
       GROUP_CONCAT(DISTINCT RoomNumber)
FROM staging_room_bookings
WHERE RoomNumber LIKE '%101%' OR RoomNumber LIKE '%201%';
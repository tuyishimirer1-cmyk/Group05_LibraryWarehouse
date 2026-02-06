-- ============================================================
-- LIBRARY ANALYTICS DATA WAREHOUSE
-- BUSINESS INTELLIGENCE QUERIES
-- ============================================================
-- These queries answer the critical business questions that
-- the Library Committee needs to make data-driven decisions.
-- ============================================================

USE library_analytics_dw;

-- ============================================================
-- QUESTION 1: Which departments use the library most?
-- ============================================================
-- This query combines all library services (books, digital, rooms)
-- to identify which departments are the most active users.

SELECT 
    s.department_standardized AS Department,
    COUNT(DISTINCT f.student_key) AS Unique_Students,
    SUM(f.loan_count) AS Total_Book_Loans,
    SUM(f.booking_count) AS Total_Room_Bookings,
    SUM(f.loan_count + f.booking_count) AS Total_Activities,
    ROUND(AVG(f.loan_duration_days), 1) AS Avg_Loan_Days
FROM fact_library_usage f
INNER JOIN dim_student s ON f.student_key = s.student_key
WHERE f.student_key IS NOT NULL
GROUP BY s.department_standardized
ORDER BY Total_Activities DESC;

-- Expected Output:
-- Department        | Unique_Students | Book_Loans | Room_Bookings | Total_Activities | Avg_Loan_Days
-- Computer Science  | 5               | 8          | 6             | 14               | 12.3
-- Engineering       | 4               | 4          | 3             | 7                | 10.5
-- Business          | 3               | 3          | 3             | 6                | 8.7


-- ============================================================
-- QUESTION 2: What are peak usage times across all services?
-- ============================================================
-- Analyzes booking patterns by time slot to identify when
-- the library is most busy.

SELECT 
    t.time_slot_standardized AS Time_Slot,
    t.start_time,
    t.end_time,
    COUNT(*) AS Total_Bookings,
    COUNT(DISTINCT f.student_key) AS Unique_Students,
    ROUND(AVG(f.booking_duration_hours), 1) AS Avg_Duration_Hours
FROM fact_library_usage f
INNER JOIN dim_time_slot t ON f.time_slot_key = t.time_slot_key
WHERE f.booking_count > 0
  AND t.time_slot_standardized != 'UNKNOWN'
GROUP BY t.time_slot_standardized, t.start_time, t.end_time
ORDER BY Total_Bookings DESC;

-- Peak usage by day of week
SELECT 
    d.day_of_week AS Day,
    d.is_weekend AS Is_Weekend,
    COUNT(*) AS Total_Activities,
    SUM(f.loan_count) AS Book_Loans,
    SUM(f.booking_count) AS Room_Bookings,
    SUM(f.download_count) AS Digital_Downloads
FROM fact_library_usage f
INNER JOIN dim_date d ON f.date_key = d.date_key
GROUP BY d.day_of_week, d.is_weekend
ORDER BY Total_Activities DESC;

-- Peak usage by month
SELECT 
    d.year AS Year,
    d.month_name AS Month,
    COUNT(*) AS Total_Activities,
    SUM(f.loan_count) AS Book_Loans,
    SUM(f.booking_count) AS Room_Bookings,
    SUM(f.download_count) AS Digital_Downloads
FROM fact_library_usage f
INNER JOIN dim_date d ON f.date_key = d.date_key
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;


-- ============================================================
-- QUESTION 3: Are digital resources replacing physical books?
-- ============================================================
-- Compares trends between physical book loans and digital downloads.

-- Overall comparison
SELECT 
    'Physical Books' AS Resource_Type,
    SUM(loan_count) AS Total_Usage,
    COUNT(DISTINCT student_key) AS Unique_Users,
    ROUND(AVG(loan_duration_days), 1) AS Avg_Duration_Days
FROM fact_library_usage
WHERE loan_count > 0

UNION ALL

SELECT 
    'Digital Resources' AS Resource_Type,
    SUM(download_count) AS Total_Usage,
    COUNT(DISTINCT student_key) AS Unique_Users,
    ROUND(AVG(download_duration_minutes) / 60, 1) AS Avg_Duration_Hours
FROM fact_library_usage
WHERE download_count > 0;

-- Monthly trend comparison
SELECT 
    d.year AS Year,
    d.month_name AS Month,
    SUM(f.loan_count) AS Physical_Book_Loans,
    SUM(f.download_count) AS Digital_Downloads,
    ROUND(
        (SUM(f.download_count) * 100.0) / 
        NULLIF(SUM(f.loan_count) + SUM(f.download_count), 0), 
        1
    ) AS Digital_Percentage
FROM fact_library_usage f
INNER JOIN dim_date d ON f.date_key = d.date_key
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;

-- Digital vs Physical by department
SELECT 
    s.department_standardized AS Department,
    SUM(f.loan_count) AS Physical_Books,
    SUM(f.download_count) AS Digital_Downloads,
    CASE 
        WHEN SUM(f.download_count) > SUM(f.loan_count) THEN 'Digital Preferred'
        WHEN SUM(f.download_count) < SUM(f.loan_count) THEN 'Physical Preferred'
        ELSE 'Equal Usage'
    END AS Preference
FROM fact_library_usage f
LEFT JOIN dim_student s ON f.student_key = s.student_key
WHERE s.student_key IS NOT NULL
GROUP BY s.department_standardized
ORDER BY Digital_Downloads DESC;


-- ============================================================
-- QUESTION 4: Which study rooms are most popular and why?
-- ============================================================
-- Analyzes room booking patterns to identify most popular rooms
-- and their characteristics.

SELECT 
    l.room_number_standardized AS Room_Number,
    l.room_type AS Room_Type,
    l.building AS Building,
    l.capacity AS Capacity,
    COUNT(*) AS Total_Bookings,
    COUNT(DISTINCT f.student_key) AS Unique_Users,
    ROUND(AVG(f.booking_duration_hours), 1) AS Avg_Duration_Hours,
    SUM(f.booking_duration_hours) AS Total_Hours_Booked
FROM fact_library_usage f
INNER JOIN dim_location l ON f.location_key = l.location_key
WHERE f.booking_count > 0
  AND l.room_number_standardized != 'UNKNOWN'
GROUP BY l.room_number_standardized, l.room_type, l.building, l.capacity
ORDER BY Total_Bookings DESC;

-- Room popularity by time slot
SELECT 
    l.room_number_standardized AS Room_Number,
    t.time_slot_standardized AS Time_Slot,
    COUNT(*) AS Bookings,
    ROUND(AVG(f.booking_duration_hours), 1) AS Avg_Duration
FROM fact_library_usage f
INNER JOIN dim_location l ON f.location_key = l.location_key
INNER JOIN dim_time_slot t ON f.time_slot_key = t.time_slot_key
WHERE f.booking_count > 0
  AND l.room_number_standardized != 'UNKNOWN'
  AND t.time_slot_standardized != 'UNKNOWN'
GROUP BY l.room_number_standardized, t.time_slot_standardized
ORDER BY Bookings DESC;

-- Room popularity by department
SELECT 
    l.room_number_standardized AS Room_Number,
    s.department_standardized AS Department,
    COUNT(*) AS Bookings,
    ROUND(AVG(f.booking_duration_hours), 1) AS Avg_Duration
FROM fact_library_usage f
INNER JOIN dim_location l ON f.location_key = l.location_key
INNER JOIN dim_student s ON f.student_key = s.student_key
WHERE f.booking_count > 0
  AND l.room_number_standardized != 'UNKNOWN'
GROUP BY l.room_number_standardized, s.department_standardized
ORDER BY Room_Number, Bookings DESC;


-- ============================================================
-- QUESTION 5: What is the average loan duration by department?
-- ============================================================
-- Analyzes how long different departments keep books checked out.

SELECT 
    s.department_standardized AS Department,
    COUNT(*) AS Total_Loans,
    ROUND(AVG(f.loan_duration_days), 1) AS Avg_Loan_Days,
    MIN(f.loan_duration_days) AS Min_Days,
    MAX(f.loan_duration_days) AS Max_Days,
    ROUND(STDDEV(f.loan_duration_days), 1) AS StdDev_Days,
    COUNT(CASE WHEN f.loan_duration_days = 0 THEN 1 END) AS Books_Not_Returned
FROM fact_library_usage f
INNER JOIN dim_student s ON f.student_key = s.student_key
WHERE f.loan_count > 0
GROUP BY s.department_standardized
ORDER BY Avg_Loan_Days DESC;

-- Loan duration by book category
SELECT 
    r.category AS Book_Category,
    s.department_standardized AS Department,
    COUNT(*) AS Total_Loans,
    ROUND(AVG(f.loan_duration_days), 1) AS Avg_Loan_Days
FROM fact_library_usage f
INNER JOIN dim_resource r ON f.resource_key = r.resource_key
INNER JOIN dim_student s ON f.student_key = s.student_key
WHERE f.loan_count > 0
  AND r.resource_type = 'Physical Book'
GROUP BY r.category, s.department_standardized
ORDER BY Avg_Loan_Days DESC;

-- Loan duration trend over time
SELECT 
    d.year AS Year,
    d.month_name AS Month,
    s.department_standardized AS Department,
    COUNT(*) AS Total_Loans,
    ROUND(AVG(f.loan_duration_days), 1) AS Avg_Loan_Days
FROM fact_library_usage f
INNER JOIN dim_date d ON f.date_key = d.date_key
INNER JOIN dim_student s ON f.student_key = s.student_key
WHERE f.loan_count > 0
GROUP BY d.year, d.month, d.month_name, s.department_standardized
ORDER BY d.year, d.month, s.department_standardized;


-- ============================================================
-- QUESTION 6: How do usage patterns differ between 
--             undergraduate and graduate students?
-- ============================================================
-- Note: Currently all students are marked as 'Undergraduate'
-- This query template can be used when graduate student data is added.

SELECT 
    s.student_level AS Student_Level,
    s.department_standardized AS Department,
    COUNT(DISTINCT f.student_key) AS Unique_Students,
    SUM(f.loan_count) AS Total_Book_Loans,
    SUM(f.download_count) AS Total_Digital_Downloads,
    SUM(f.booking_count) AS Total_Room_Bookings,
    ROUND(AVG(f.loan_duration_days), 1) AS Avg_Loan_Days,
    ROUND(AVG(f.booking_duration_hours), 1) AS Avg_Booking_Hours
FROM fact_library_usage f
INNER JOIN dim_student s ON f.student_key = s.student_key
WHERE f.student_key IS NOT NULL
GROUP BY s.student_level, s.department_standardized
ORDER BY s.student_level, Total_Book_Loans DESC;

-- Usage patterns by student type (all activities)
SELECT 
    s.student_level AS Student_Level,
    COUNT(*) AS Total_Activities,
    SUM(f.loan_count) AS Book_Loans,
    SUM(f.download_count) AS Digital_Downloads,
    SUM(f.booking_count) AS Room_Bookings,
    ROUND(
        (SUM(f.loan_count) * 100.0) / COUNT(*), 
        1
    ) AS Book_Percentage,
    ROUND(
        (SUM(f.download_count) * 100.0) / COUNT(*), 
        1
    ) AS Digital_Percentage,
    ROUND(
        (SUM(f.booking_count) * 100.0) / COUNT(*), 
        1
    ) AS Room_Percentage
FROM fact_library_usage f
INNER JOIN dim_student s ON f.student_key = s.student_key
WHERE f.student_key IS NOT NULL
GROUP BY s.student_level;


-- ============================================================
-- BONUS QUERIES - Additional Insights
-- ============================================================

-- Overall Library Usage Summary
SELECT 
    'Total Students' AS Metric,
    COUNT(DISTINCT student_key) AS Value
FROM dim_student

UNION ALL

SELECT 
    'Total Transactions',
    COUNT(*) 
FROM fact_library_usage

UNION ALL

SELECT 
    'Total Book Loans',
    SUM(loan_count) 
FROM fact_library_usage

UNION ALL

SELECT 
    'Total Digital Downloads',
    SUM(download_count) 
FROM fact_library_usage

UNION ALL

SELECT 
    'Total Room Bookings',
    SUM(booking_count) 
FROM fact_library_usage;


-- Most Active Students
SELECT 
    s.student_id AS Student_ID,
    s.department_standardized AS Department,
    COUNT(*) AS Total_Activities,
    SUM(f.loan_count) AS Books_Borrowed,
    SUM(f.booking_count) AS Rooms_Booked,
    ROUND(AVG(f.loan_duration_days), 1) AS Avg_Loan_Days
FROM fact_library_usage f
INNER JOIN dim_student s ON f.student_key = s.student_key
WHERE f.student_key IS NOT NULL
GROUP BY s.student_id, s.department_standardized
ORDER BY Total_Activities DESC
LIMIT 10;


-- Most Popular Books
SELECT 
    r.resource_id AS ISBN,
    r.title AS Book_Title,
    r.category AS Category,
    COUNT(*) AS Times_Borrowed,
    ROUND(AVG(f.loan_duration_days), 1) AS Avg_Loan_Days,
    COUNT(DISTINCT f.student_key) AS Different_Borrowers
FROM fact_library_usage f
INNER JOIN dim_resource r ON f.resource_key = r.resource_key
WHERE f.loan_count > 0
  AND r.resource_type = 'Physical Book'
GROUP BY r.resource_id, r.title, r.category
ORDER BY Times_Borrowed DESC
LIMIT 10;


-- Digital Resource Usage by Type
SELECT 
    r.resource_type AS Digital_Resource_Type,
    COUNT(*) AS Total_Downloads,
    SUM(f.download_count) AS Total_Download_Count,
    ROUND(AVG(f.download_duration_minutes), 1) AS Avg_Duration_Minutes,
    COUNT(DISTINCT f.date_key) AS Days_Used
FROM fact_library_usage f
INNER JOIN dim_resource r ON f.resource_key = r.resource_key
WHERE r.is_digital = 1
  AND f.download_count > 0
GROUP BY r.resource_type
ORDER BY Total_Downloads DESC;


-- Weekend vs Weekday Usage
SELECT 
    CASE 
        WHEN d.is_weekend = 1 THEN 'Weekend'
        ELSE 'Weekday'
    END AS Day_Type,
    COUNT(*) AS Total_Activities,
    SUM(f.loan_count) AS Book_Loans,
    SUM(f.download_count) AS Digital_Downloads,
    SUM(f.booking_count) AS Room_Bookings,
    ROUND(AVG(f.booking_duration_hours), 1) AS Avg_Booking_Hours
FROM fact_library_usage f
INNER JOIN dim_date d ON f.date_key = d.date_key
GROUP BY d.is_weekend
ORDER BY Day_Type;


-- Quarterly Performance Report
SELECT 
    d.year AS Year,
    d.quarter_name AS Quarter,
    COUNT(DISTINCT f.student_key) AS Active_Students,
    COUNT(*) AS Total_Activities,
    SUM(f.loan_count) AS Book_Loans,
    SUM(f.download_count) AS Digital_Downloads,
    SUM(f.booking_count) AS Room_Bookings,
    ROUND(AVG(f.loan_duration_days), 1) AS Avg_Loan_Days
FROM fact_library_usage f
INNER JOIN dim_date d ON f.date_key = d.date_key
GROUP BY d.year, d.quarter, d.quarter_name
ORDER BY d.year, d.quarter;


-- ============================================================
-- END OF BUSINESS INTELLIGENCE QUERIES
-- ============================================================
-- These queries provide comprehensive insights into:
-- 1. Department usage patterns
-- 2. Peak usage times
-- 3. Digital vs physical resource trends
-- 4. Study room popularity
-- 5. Loan duration by department
-- 6. Student level usage differences
--
-- Additional bonus queries provide deeper insights into
-- overall library operations and user behavior.
-- ============================================================
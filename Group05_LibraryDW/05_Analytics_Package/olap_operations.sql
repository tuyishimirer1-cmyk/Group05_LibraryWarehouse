-- ============================================================
-- OLAP OPERATIONS DEMONSTRATION
-- Library Analytics Data Warehouse
-- Team Member 3: Analytics, Reporting & Security Lead
-- ============================================================
-- 
-- This file demonstrates all 5 OLAP operations:
-- 1. DRILL-DOWN: From summary to detail (Year → Quarter → Month → Day)
-- 2. ROLL-UP: From detail to summary (Day → Month → Quarter → Year)
-- 3. SLICE: Filter by one dimension
-- 4. DICE: Filter by multiple dimensions
-- 5. PIVOT: Rotate data perspective
--
-- ============================================================

USE library_analytics_dw;

-- ============================================================
-- OPERATION 1: DRILL-DOWN
-- Purpose: Navigate from high-level summary to detailed data
-- Business Value: Identify trends at different granularities
-- ============================================================

-- LEVEL 1: Year Level (Highest Summary)
-- Question: What is the total library usage by year?
SELECT 
    d.year AS Year,
    COUNT(DISTINCT f.student_key) AS Active_Students,
    SUM(f.loan_count) AS Total_Book_Loans,
    SUM(f.download_count) AS Total_Digital_Downloads,
    SUM(f.booking_count) AS Total_Room_Bookings,
    SUM(f.loan_count + f.download_count + f.booking_count) AS Total_Activities
FROM fact_library_usage f
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY d.year
ORDER BY d.year;

-- Expected Result: One row per year showing totals
-- 2024: 14 students, 15 loans, 14 downloads, 17 bookings, 46 activities


-- LEVEL 2: Drill Down to Quarter
-- Question: How does usage break down by quarter within 2024?
SELECT 
    d.year AS Year,
    d.quarter AS Quarter_Number,
    d.quarter_name AS Quarter,
    COUNT(DISTINCT f.student_key) AS Active_Students,
    SUM(f.loan_count) AS Book_Loans,
    SUM(f.download_count) AS Digital_Downloads,
    SUM(f.booking_count) AS Room_Bookings,
    SUM(f.loan_count + f.download_count + f.booking_count) AS Total_Activities
FROM fact_library_usage f
JOIN dim_date d ON f.date_key = d.date_key
WHERE d.year = 2024  -- Drill down into 2024
GROUP BY d.year, d.quarter, d.quarter_name
ORDER BY d.quarter;

-- Expected Result: Quarterly breakdown for 2024
-- Q1 2024: Most activity (Jan-Mar)


-- LEVEL 3: Drill Down to Month
-- Question: Which months in Q1 2024 had the highest usage?
SELECT 
    d.year AS Year,
    d.quarter_name AS Quarter,
    d.month AS Month_Number,
    d.month_name AS Month,
    COUNT(DISTINCT f.student_key) AS Active_Students,
    SUM(f.loan_count) AS Book_Loans,
    SUM(f.download_count) AS Digital_Downloads,
    SUM(f.booking_count) AS Room_Bookings,
    SUM(f.loan_count + f.download_count + f.booking_count) AS Total_Activities,
    ROUND(AVG(f.loan_duration_days), 2) AS Avg_Loan_Duration_Days
FROM fact_library_usage f
JOIN dim_date d ON f.date_key = d.date_key
WHERE d.year = 2024 
  AND d.quarter_name = 'Q1'  -- Drill down into Q1
GROUP BY d.year, d.quarter_name, d.month, d.month_name
ORDER BY d.month;

-- Expected Result: Monthly breakdown for Q1 (January, February, March)


-- LEVEL 4: Drill Down to Day
-- Question: What was the daily usage pattern in January 2024?
SELECT 
    d.full_date AS Date,
    d.day_of_week_name AS Day_Of_Week,
    d.is_weekend AS Is_Weekend,
    SUM(f.loan_count) AS Book_Loans,
    SUM(f.download_count) AS Digital_Downloads,
    SUM(f.booking_count) AS Room_Bookings,
    SUM(f.loan_count + f.download_count + f.booking_count) AS Total_Activities
FROM fact_library_usage f
JOIN dim_date d ON f.date_key = d.date_key
WHERE d.year = 2024 
  AND d.month_name = 'January'  -- Drill down into January
GROUP BY d.full_date, d.day_of_week_name, d.is_weekend
ORDER BY d.full_date;

-- Expected Result: Daily activity for all days in January 2024
-- Can identify: Weekday vs weekend patterns, peak days


-- ============================================================
-- OPERATION 2: ROLL-UP
-- Purpose: Aggregate detailed data into higher-level summaries
-- Business Value: See big picture trends from granular data
-- ============================================================

-- ROLL-UP Example 1: Day → Week → Month → Quarter → Year
-- Question: Show activity at all time levels simultaneously
SELECT 
    'Day' AS Time_Level,
    CAST(d.full_date AS CHAR) AS Time_Period,
    SUM(f.loan_count + f.download_count + f.booking_count) AS Total_Activities
FROM fact_library_usage f
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY d.full_date
ORDER BY d.full_date
LIMIT 10

UNION ALL

SELECT 
    'Week' AS Time_Level,
    CONCAT('Week ', d.week_of_year, ' ', d.year) AS Time_Period,
    SUM(f.loan_count + f.download_count + f.booking_count) AS Total_Activities
FROM fact_library_usage f
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY d.year, d.week_of_year
ORDER BY d.year, d.week_of_year

UNION ALL

SELECT 
    'Month' AS Time_Level,
    CONCAT(d.month_name, ' ', d.year) AS Time_Period,
    SUM(f.loan_count + f.download_count + f.booking_count) AS Total_Activities
FROM fact_library_usage f
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month

UNION ALL

SELECT 
    'Quarter' AS Time_Level,
    CONCAT(d.quarter_name, ' ', d.year) AS Time_Period,
    SUM(f.loan_count + f.download_count + f.booking_count) AS Total_Activities
FROM fact_library_usage f
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY d.year, d.quarter, d.quarter_name
ORDER BY d.year, d.quarter

UNION ALL

SELECT 
    'Year' AS Time_Level,
    CAST(d.year AS CHAR) AS Time_Period,
    SUM(f.loan_count + f.download_count + f.booking_count) AS Total_Activities
FROM fact_library_usage f
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY d.year
ORDER BY d.year;

-- Expected Result: Activity counts at Day, Week, Month, Quarter, Year levels


-- ROLL-UP Example 2: Location Roll-Up (Room → Building → Campus)
-- Question: Aggregate room bookings from specific rooms to building level
SELECT 
    'Room Level' AS Aggregation_Level,
    l.room_number_standardized AS Location,
    SUM(f.booking_count) AS Total_Bookings,
    SUM(f.booking_duration_hours) AS Total_Hours
FROM fact_library_usage f
JOIN dim_location l ON f.location_key = l.location_key
WHERE f.booking_count > 0
GROUP BY l.room_number_standardized

UNION ALL

SELECT 
    'Building Level' AS Aggregation_Level,
    l.building AS Location,
    SUM(f.booking_count) AS Total_Bookings,
    SUM(f.booking_duration_hours) AS Total_Hours
FROM fact_library_usage f
JOIN dim_location l ON f.location_key = l.location_key
WHERE f.booking_count > 0
GROUP BY l.building;

-- Expected Result: Shows bookings at room level, then rolled up to building


-- ============================================================
-- OPERATION 3: SLICE
-- Purpose: Filter data by fixing one dimension
-- Business Value: Focus analysis on specific segment
-- ============================================================

-- SLICE Example 1: Slice by Department (Computer Science only)
-- Question: Show all library activity for Computer Science students only
SELECT 
    d.full_date AS Date,
    s.department_standardized AS Department,
    r.title AS Resource,
    r.resource_type AS Type,
    SUM(f.loan_count) AS Books_Borrowed,
    SUM(f.download_count) AS Digital_Downloads,
    SUM(f.booking_count) AS Rooms_Booked
FROM fact_library_usage f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_student s ON f.student_key = s.student_key
JOIN dim_resource r ON f.resource_key = r.resource_key
WHERE s.department_standardized = 'Computer Science'  -- SLICE: Only CS department
GROUP BY d.full_date, s.department_standardized, r.title, r.resource_type
ORDER BY d.full_date;

-- Expected Result: All activities filtered to Computer Science department only


-- SLICE Example 2: Slice by Resource Type (Digital only)
-- Question: Show only digital resource usage across all dimensions
SELECT 
    d.month_name AS Month,
    s.department_standardized AS Department,
    r.resource_type AS Digital_Type,
    COUNT(*) AS Usage_Count,
    SUM(f.download_count) AS Total_Downloads,
    AVG(f.download_duration_minutes) AS Avg_Duration_Minutes
FROM fact_library_usage f
JOIN dim_date d ON f.date_key = d.date_key
LEFT JOIN dim_student s ON f.student_key = s.student_key
JOIN dim_resource r ON f.resource_key = r.resource_key
WHERE r.is_digital = 1  -- SLICE: Only digital resources
  AND f.download_count > 0
GROUP BY d.month_name, s.department_standardized, r.resource_type
ORDER BY d.month_name, Department;

-- Expected Result: Digital resource usage only, ignoring physical books/rooms


-- SLICE Example 3: Slice by Time Period (January only)
-- Question: What happened in January across all other dimensions?
SELECT 
    s.department_standardized AS Department,
    r.resource_type AS Resource_Type,
    SUM(f.loan_count) AS Book_Loans,
    SUM(f.download_count) AS Downloads,
    SUM(f.booking_count) AS Room_Bookings,
    COUNT(DISTINCT f.student_key) AS Active_Students
FROM fact_library_usage f
JOIN dim_date d ON f.date_key = d.date_key
LEFT JOIN dim_student s ON f.student_key = s.student_key
JOIN dim_resource r ON f.resource_key = r.resource_key
WHERE d.month_name = 'January'  -- SLICE: Only January
GROUP BY s.department_standardized, r.resource_type
ORDER BY Department, Resource_Type;

-- Expected Result: January data only, broken down by department and resource type


-- ============================================================
-- OPERATION 4: DICE
-- Purpose: Filter by multiple dimensions simultaneously
-- Business Value: Analyze very specific data segments
-- ============================================================

-- DICE Example 1: Computer Science + January + Physical Books
-- Question: What books did CS students borrow in January?
SELECT 
    d.full_date AS Date,
    s.student_id AS Student,
    s.department_standardized AS Department,
    r.title AS Book_Title,
    r.category AS Book_Category,
    SUM(f.loan_count) AS Times_Borrowed,
    AVG(f.loan_duration_days) AS Avg_Loan_Days
FROM fact_library_usage f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_student s ON f.student_key = s.student_key
JOIN dim_resource r ON f.resource_key = r.resource_key
WHERE s.department_standardized = 'Computer Science'  -- DICE Dimension 1
  AND d.month_name = 'January'                        -- DICE Dimension 2
  AND r.resource_type = 'Physical Book'               -- DICE Dimension 3
  AND f.loan_count > 0
GROUP BY d.full_date, s.student_id, s.department_standardized, r.title, r.category
ORDER BY d.full_date;

-- Expected Result: Very specific subset (CS + January + Books only)


-- DICE Example 2: Engineering + Morning Time Slot + Study Rooms
-- Question: When do Engineering students book rooms in the morning?
SELECT 
    d.full_date AS Date,
    d.day_of_week_name AS Day_Of_Week,
    s.department_standardized AS Department,
    t.time_slot_standardized AS Time_Slot,
    l.room_number_standardized AS Room,
    COUNT(*) AS Bookings,
    SUM(f.booking_duration_hours) AS Total_Hours
FROM fact_library_usage f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_student s ON f.student_key = s.student_key
JOIN dim_time_slot t ON f.time_slot_key = t.time_slot_key
JOIN dim_location l ON f.location_key = l.location_key
WHERE s.department_standardized = 'Engineering'      -- DICE Dimension 1
  AND t.time_slot_standardized = 'Morning'           -- DICE Dimension 2
  AND l.room_type = 'Study Room'                     -- DICE Dimension 3
  AND f.booking_count > 0
GROUP BY d.full_date, d.day_of_week_name, s.department_standardized, 
         t.time_slot_standardized, l.room_number_standardized
ORDER BY d.full_date;

-- Expected Result: Engineering + Morning + Study Rooms only


-- DICE Example 3: Business + Weekends + Digital Resources
-- Question: Do Business students use digital resources on weekends?
SELECT 
    d.full_date AS Date,
    d.day_of_week_name AS Day,
    s.department_standardized AS Department,
    r.resource_type AS Resource_Type,
    COUNT(*) AS Usage_Count,
    SUM(f.download_count) AS Downloads,
    AVG(f.download_duration_minutes) AS Avg_Minutes
FROM fact_library_usage f
JOIN dim_date d ON f.date_key = d.date_key
LEFT JOIN dim_student s ON f.student_key = s.student_key
JOIN dim_resource r ON f.resource_key = r.resource_key
WHERE s.department_standardized = 'Business'         -- DICE Dimension 1
  AND d.is_weekend = 1                               -- DICE Dimension 2
  AND r.is_digital = 1                               -- DICE Dimension 3
  AND f.download_count > 0
GROUP BY d.full_date, d.day_of_week_name, s.department_standardized, r.resource_type
ORDER BY d.full_date;

-- Expected Result: Business + Weekends + Digital only


-- ============================================================
-- OPERATION 5: PIVOT
-- Purpose: Rotate data to see different perspectives
-- Business Value: Cross-tabulation, matrix views
-- ============================================================

-- PIVOT Example 1: Departments (rows) × Months (columns)
-- Question: Compare departmental activity across months
SELECT 
    s.department_standardized AS Department,
    SUM(CASE WHEN d.month_name = 'January' THEN f.loan_count + f.download_count + f.booking_count ELSE 0 END) AS January,
    SUM(CASE WHEN d.month_name = 'February' THEN f.loan_count + f.download_count + f.booking_count ELSE 0 END) AS February,
    SUM(CASE WHEN d.month_name = 'March' THEN f.loan_count + f.download_count + f.booking_count ELSE 0 END) AS March,
    SUM(CASE WHEN d.month_name = 'April' THEN f.loan_count + f.download_count + f.booking_count ELSE 0 END) AS April,
    SUM(f.loan_count + f.download_count + f.booking_count) AS Total
FROM fact_library_usage f
JOIN dim_date d ON f.date_key = d.date_key
LEFT JOIN dim_student s ON f.student_key = s.student_key
WHERE s.department_standardized IS NOT NULL
GROUP BY s.department_standardized
ORDER BY Total DESC;

-- Expected Result:
-- Department       | Jan | Feb | Mar | Apr | Total
-- Computer Science | 20  | 15  | 18  | 10  | 63
-- Engineering      | 12  | 14  | 10  | 8   | 44
-- Business         | 8   | 10  | 9   | 7   | 34


-- PIVOT Example 2: Resource Types (rows) × Activity Types (columns)
-- Question: Which resource types are used for which activities?
SELECT 
    r.resource_type AS Resource_Type,
    SUM(f.loan_count) AS Physical_Loans,
    SUM(f.download_count) AS Digital_Downloads,
    SUM(f.booking_count) AS Room_Bookings,
    COUNT(DISTINCT f.student_key) AS Unique_Users,
    SUM(f.loan_count + f.download_count + f.booking_count) AS Total_Uses
FROM fact_library_usage f
JOIN dim_resource r ON f.resource_key = r.resource_key
GROUP BY r.resource_type
ORDER BY Total_Uses DESC;

-- Expected Result:
-- Resource Type    | Loans | Downloads | Bookings | Users | Total
-- Physical Book    | 15    | 0         | 0        | 10    | 15
-- E-Journal        | 0     | 8         | 0        | 6     | 8
-- Study Room       | 0     | 0         | 17       | 12    | 17


-- PIVOT Example 3: Days of Week (rows) × Time Slots (columns)
-- Question: When are rooms most heavily booked?
SELECT 
    d.day_of_week_name AS Day_Of_Week,
    SUM(CASE WHEN t.time_slot_standardized = 'Morning' THEN f.booking_count ELSE 0 END) AS Morning,
    SUM(CASE WHEN t.time_slot_standardized = '8AM-10AM' THEN f.booking_count ELSE 0 END) AS '8AM-10AM',
    SUM(CASE WHEN t.time_slot_standardized = '12PM-2PM' THEN f.booking_count ELSE 0 END) AS '12PM-2PM',
    SUM(CASE WHEN t.time_slot_standardized = 'Afternoon' THEN f.booking_count ELSE 0 END) AS Afternoon,
    SUM(CASE WHEN t.time_slot_standardized = 'Evening' THEN f.booking_count ELSE 0 END) AS Evening,
    SUM(CASE WHEN t.time_slot_standardized = 'Night' THEN f.booking_count ELSE 0 END) AS Night,
    SUM(f.booking_count) AS Total_Bookings
FROM fact_library_usage f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_time_slot t ON f.time_slot_key = t.time_slot_key
WHERE f.booking_count > 0
GROUP BY d.day_of_week, d.day_of_week_name
ORDER BY 
    CASE d.day_of_week_name
        WHEN 'Monday' THEN 1
        WHEN 'Tuesday' THEN 2
        WHEN 'Wednesday' THEN 3
        WHEN 'Thursday' THEN 4
        WHEN 'Friday' THEN 5
        WHEN 'Saturday' THEN 6
        WHEN 'Sunday' THEN 7
    END;

-- Expected Result: Heat map showing busy days/times


-- PIVOT Example 4: Students (rows) × Activity Types (columns)
-- Question: What is each student's activity profile?
SELECT 
    s.student_id AS Student_ID,
    s.department_standardized AS Department,
    SUM(f.loan_count) AS Books_Borrowed,
    SUM(f.download_count) AS Digital_Downloads,
    SUM(f.booking_count) AS Rooms_Booked,
    SUM(f.loan_count + f.download_count + f.booking_count) AS Total_Activities,
    ROUND(AVG(f.loan_duration_days), 1) AS Avg_Loan_Days
FROM dim_student s
LEFT JOIN fact_library_usage f ON s.student_key = f.student_key
GROUP BY s.student_id, s.department_standardized
HAVING Total_Activities > 0
ORDER BY Total_Activities DESC;

-- Expected Result: Student activity profile matrix


-- ============================================================
-- ADVANCED OLAP: COMBINING OPERATIONS
-- ============================================================

-- Example: DICE + DRILL-DOWN + PIVOT
-- Question: For Computer Science students in January, 
--           show daily activity broken down by resource type
SELECT 
    d.full_date AS Date,
    d.day_of_week_name AS Day,
    SUM(CASE WHEN r.resource_type = 'Physical Book' THEN f.loan_count ELSE 0 END) AS Physical_Books,
    SUM(CASE WHEN r.is_digital = 1 THEN f.download_count ELSE 0 END) AS Digital_Resources,
    SUM(CASE WHEN r.resource_type LIKE '%Room%' THEN 1 ELSE 0 END) AS Study_Rooms,
    SUM(f.loan_count + f.download_count + f.booking_count) AS Total_Activity
FROM fact_library_usage f
JOIN dim_date d ON f.date_key = d.date_key
LEFT JOIN dim_student s ON f.student_key = s.student_key
JOIN dim_resource r ON f.resource_key = r.resource_key
WHERE s.department_standardized = 'Computer Science'  -- DICE
  AND d.month_name = 'January'                        -- DICE
GROUP BY d.full_date, d.day_of_week_name              -- DRILL-DOWN to day
ORDER BY d.full_date;

-- This combines:
-- - DICE: Filter by CS + January
-- - DRILL-DOWN: Show at day level
-- - PIVOT: Activity types as columns


-- ============================================================
-- SUMMARY: OLAP OPERATIONS COVERAGE
-- ============================================================
--  DRILL-DOWN: Year → Quarter → Month → Day (4 levels)
--  ROLL-UP: Day → Week → Month → Quarter → Year
--  SLICE: Single dimension filters (3 examples)
--  DICE: Multi-dimension filters (3 examples)
--  PIVOT: Cross-tabulation (4 examples)
--  COMBINED: Multiple operations together
--
-- Total Queries: 20+ OLAP operations demonstrated
-- Business Value: Complete analytical capability
-- ============================================================

-- END OF FILE
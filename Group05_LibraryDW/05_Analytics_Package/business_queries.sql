-- ============================================================
-- BUSINESS INTELLIGENCE QUERIES
-- Library Analytics Data Warehouse
-- Team Member 3: Analytics, Reporting & Security Lead
-- ============================================================
-- 
-- This file contains 18 SQL queries for business intelligence:
-- - Aggregation queries (SUM, COUNT, AVG, MIN, MAX)
-- - Time-series analysis queries
-- - Ranking and comparison queries
-- - Complex joins across fact and dimension tables
--
-- Purpose: Answer critical business questions for library management
-- ============================================================

USE library_analytics_dw;

-- ============================================================
-- CATEGORY 1: AGGREGATION QUERIES (5 queries)
-- Purpose: Summarize data using aggregate functions
-- ============================================================

-- QUERY 1: Overall Library Usage Summary
-- Question: What is the total library usage across all activities?
-- Business Value: High-level KPIs for executive dashboard
SELECT 
    'Library Overview' AS Report_Type,
    COUNT(DISTINCT f.student_key) AS Total_Active_Students,
    SUM(f.loan_count) AS Total_Book_Loans,
    SUM(f.download_count) AS Total_Digital_Downloads,
    SUM(f.booking_count) AS Total_Room_Bookings,
    SUM(f.loan_count + f.download_count + f.booking_count) AS Total_Activities,
    ROUND(AVG(f.loan_duration_days), 2) AS Avg_Loan_Duration_Days,
    ROUND(AVG(f.download_duration_minutes), 2) AS Avg_Download_Minutes,
    ROUND(AVG(f.booking_duration_hours), 2) AS Avg_Booking_Hours
FROM fact_library_usage f
WHERE f.loan_count > 0 OR f.download_count > 0 OR f.booking_count > 0;


-- QUERY 2: Department-Level Activity Summary
-- Question: Which departments use the library most?
-- Business Value: Resource allocation, department comparisons
SELECT 
    s.department_standardized AS Department,
    COUNT(DISTINCT s.student_key) AS Active_Students,
    SUM(f.loan_count) AS Book_Loans,
    SUM(f.download_count) AS Digital_Downloads,
    SUM(f.booking_count) AS Room_Bookings,
    SUM(f.loan_count + f.download_count + f.booking_count) AS Total_Activities,
    ROUND(AVG(f.loan_duration_days), 2) AS Avg_Loan_Days,
    ROUND(100.0 * SUM(f.loan_count + f.download_count + f.booking_count) / 
          (SELECT SUM(loan_count + download_count + booking_count) FROM fact_library_usage), 2) AS Percentage_Of_Total
FROM fact_library_usage f
JOIN dim_student s ON f.student_key = s.student_key
WHERE f.student_key IS NOT NULL
GROUP BY s.department_standardized
ORDER BY Total_Activities DESC;


-- QUERY 3: Resource Type Analysis
-- Question: What types of resources are most popular?
-- Business Value: Collection development, budget allocation
SELECT 
    r.resource_type AS Resource_Type,
    r.is_digital AS Is_Digital,
    COUNT(DISTINCT r.resource_key) AS Unique_Resources,
    SUM(f.loan_count) AS Physical_Checkouts,
    SUM(f.download_count) AS Digital_Downloads,
    SUM(f.booking_count) AS Room_Bookings,
    SUM(f.loan_count + f.download_count + f.booking_count) AS Total_Usage,
    ROUND(AVG(CASE WHEN f.loan_count > 0 THEN f.loan_duration_days END), 2) AS Avg_Checkout_Days,
    ROUND(AVG(CASE WHEN f.download_count > 0 THEN f.download_duration_minutes END), 2) AS Avg_Download_Minutes
FROM fact_library_usage f
JOIN dim_resource r ON f.resource_key = r.resource_key
GROUP BY r.resource_type, r.is_digital
ORDER BY Total_Usage DESC;


-- QUERY 4: Time Slot Utilization
-- Question: When are library resources most heavily used?
-- Business Value: Staffing optimization, resource scheduling
SELECT 
    t.time_slot_standardized AS Time_Slot,
    t.start_time AS Start_Time,
    t.end_time AS End_Time,
    COUNT(*) AS Total_Bookings,
    SUM(f.booking_count) AS Room_Bookings,
    SUM(f.booking_duration_hours) AS Total_Hours_Booked,
    ROUND(AVG(f.booking_duration_hours), 2) AS Avg_Booking_Hours,
    COUNT(DISTINCT f.student_key) AS Unique_Students
FROM fact_library_usage f
JOIN dim_time_slot t ON f.time_slot_key = t.time_slot_key
WHERE f.booking_count > 0 
  AND t.time_slot_standardized != 'UNKNOWN'
GROUP BY t.time_slot_standardized, t.start_time, t.end_time
ORDER BY t.start_time;


-- QUERY 5: Location Popularity Analysis
-- Question: Which study rooms are most and least popular?
-- Business Value: Space optimization, maintenance scheduling
SELECT 
    l.room_number_standardized AS Room_Number,
    l.room_type AS Room_Type,
    l.building AS Building,
    l.capacity AS Capacity,
    COUNT(*) AS Total_Bookings,
    SUM(f.booking_count) AS Times_Booked,
    SUM(f.booking_duration_hours) AS Total_Hours_Used,
    ROUND(AVG(f.booking_duration_hours), 2) AS Avg_Hours_Per_Booking,
    COUNT(DISTINCT f.student_key) AS Unique_Users,
    MIN(d.full_date) AS First_Booking,
    MAX(d.full_date) AS Last_Booking
FROM fact_library_usage f
JOIN dim_location l ON f.location_key = l.location_key
JOIN dim_date d ON f.date_key = d.date_key
WHERE f.booking_count > 0
  AND l.room_number_standardized != 'UNKNOWN'
GROUP BY l.room_number_standardized, l.room_type, l.building, l.capacity
ORDER BY Times_Booked DESC;


-- ============================================================
-- CATEGORY 2: TIME-SERIES ANALYSIS (4 queries)
-- Purpose: Identify trends and patterns over time
-- ============================================================

-- QUERY 6: Monthly Activity Trend
-- Question: How has library usage changed month by month?
-- Business Value: Identify seasonal patterns, plan resources
SELECT 
    d.year AS Year,
    d.month AS Month_Number,
    d.month_name AS Month,
    COUNT(DISTINCT f.student_key) AS Active_Students,
    SUM(f.loan_count) AS Book_Loans,
    SUM(f.download_count) AS Digital_Downloads,
    SUM(f.booking_count) AS Room_Bookings,
    SUM(f.loan_count + f.download_count + f.booking_count) AS Total_Activities
FROM fact_library_usage f
JOIN dim_date d ON f.date_key = d.date_key
GROUP BY d.year, d.month, d.month_name
ORDER BY d.year, d.month;


-- QUERY 7: Day of Week Usage Pattern
-- Question: Which days of the week are busiest?
-- Business Value: Staffing schedules, maintenance planning
SELECT 
    d.day_of_week AS Day_Number,
    d.day_of_week_name AS Day_Of_Week,
    d.is_weekend AS Is_Weekend,
    COUNT(*) AS Total_Records,
    SUM(f.loan_count) AS Book_Loans,
    SUM(f.download_count) AS Digital_Downloads,
    SUM(f.booking_count) AS Room_Bookings,
    SUM(f.loan_count + f.download_count + f.booking_count) AS Total_Activities,
    ROUND(AVG(f.loan_count + f.download_count + f.booking_count), 2) AS Avg_Activities_Per_Day
FROM fact_library_usage f
JOIN dim_date d ON f.date_key = d.date_key
WHERE f.loan_count > 0 OR f.download_count > 0 OR f.booking_count > 0
GROUP BY d.day_of_week, d.day_of_week_name, d.is_weekend
ORDER BY d.day_of_week;


-- QUERY 8: Quarterly Performance Analysis
-- Question: How does library usage compare across quarters?
-- Business Value: Annual planning, budget cycles
SELECT 
    d.year AS Year,
    d.quarter AS Quarter_Number,
    d.quarter_name AS Quarter,
    COUNT(DISTINCT d.full_date) AS Days_With_Activity,
    COUNT(DISTINCT f.student_key) AS Active_Students,
    SUM(f.loan_count) AS Book_Loans,
    SUM(f.download_count) AS Digital_Downloads,
    SUM(f.booking_count) AS Room_Bookings,
    SUM(f.loan_count + f.download_count + f.booking_count) AS Total_Activities,
    ROUND(SUM(f.loan_count + f.download_count + f.booking_count) / 
          COUNT(DISTINCT d.full_date), 2) AS Avg_Activities_Per_Day
FROM fact_library_usage f
JOIN dim_date d ON f.date_key = d.date_key
WHERE f.loan_count > 0 OR f.download_count > 0 OR f.booking_count > 0
GROUP BY d.year, d.quarter, d.quarter_name
ORDER BY d.year, d.quarter;


-- QUERY 9: Weekend vs Weekday Comparison
-- Question: How does library usage differ between weekdays and weekends?
-- Business Value: Operating hours decisions, weekend staffing
SELECT 
    CASE WHEN d.is_weekend = 1 THEN 'Weekend' ELSE 'Weekday' END AS Period_Type,
    COUNT(DISTINCT d.full_date) AS Number_Of_Days,
    COUNT(DISTINCT f.student_key) AS Active_Students,
    SUM(f.loan_count) AS Book_Loans,
    SUM(f.download_count) AS Digital_Downloads,
    SUM(f.booking_count) AS Room_Bookings,
    SUM(f.loan_count + f.download_count + f.booking_count) AS Total_Activities,
    ROUND(SUM(f.loan_count + f.download_count + f.booking_count) / 
          COUNT(DISTINCT d.full_date), 2) AS Avg_Activities_Per_Day,
    ROUND(100.0 * SUM(f.loan_count + f.download_count + f.booking_count) / 
          (SELECT SUM(loan_count + download_count + booking_count) FROM fact_library_usage), 2) AS Percentage_Of_Total
FROM fact_library_usage f
JOIN dim_date d ON f.date_key = d.date_key
WHERE f.loan_count > 0 OR f.download_count > 0 OR f.booking_count > 0
GROUP BY d.is_weekend
ORDER BY d.is_weekend;


-- ============================================================
-- CATEGORY 3: RANKING & COMPARISON QUERIES (4 queries)
-- Purpose: Identify top performers, outliers, comparisons
-- ============================================================

-- QUERY 10: Top 10 Most Active Students
-- Question: Who are our most engaged library users?
-- Business Value: Student engagement analysis, recognition programs
SELECT 
    s.student_id AS Student_ID,
    s.department_standardized AS Department,
    s.student_level AS Student_Level,
    SUM(f.loan_count) AS Books_Borrowed,
    SUM(f.download_count) AS Digital_Resources_Used,
    SUM(f.booking_count) AS Rooms_Booked,
    SUM(f.loan_count + f.download_count + f.booking_count) AS Total_Activities,
    ROUND(AVG(f.loan_duration_days), 2) AS Avg_Loan_Duration_Days,
    COUNT(DISTINCT d.full_date) AS Days_Active,
    MIN(d.full_date) AS First_Activity_Date,
    MAX(d.full_date) AS Last_Activity_Date
FROM fact_library_usage f
JOIN dim_student s ON f.student_key = s.student_key
JOIN dim_date d ON f.date_key = d.date_key
WHERE f.loan_count > 0 OR f.download_count > 0 OR f.booking_count > 0
GROUP BY s.student_id, s.department_standardized, s.student_level
ORDER BY Total_Activities DESC
LIMIT 10;


-- QUERY 11: Top 10 Most Popular Books
-- Question: Which books are checked out most frequently?
-- Business Value: Collection development, purchase additional copies
SELECT 
    r.resource_id AS Book_ID,
    r.title AS Book_Title,
    r.category AS Category,
    COUNT(*) AS Times_Borrowed,
    SUM(f.loan_count) AS Total_Checkouts,
    COUNT(DISTINCT f.student_key) AS Unique_Borrowers,
    ROUND(AVG(f.loan_duration_days), 2) AS Avg_Loan_Duration_Days,
    MIN(f.loan_duration_days) AS Min_Loan_Days,
    MAX(f.loan_duration_days) AS Max_Loan_Days
FROM fact_library_usage f
JOIN dim_resource r ON f.resource_key = r.resource_key
WHERE f.loan_count > 0
  AND r.resource_type = 'Physical Book'
GROUP BY r.resource_id, r.title, r.category
ORDER BY Total_Checkouts DESC, Unique_Borrowers DESC
LIMIT 10;


-- QUERY 12: Department Activity Comparison with Rankings
-- Question: How do departments rank in different activity types?
-- Business Value: Fair resource distribution, departmental accountability
SELECT 
    s.department_standardized AS Department,
    SUM(f.loan_count) AS Book_Loans,
    SUM(f.download_count) AS Digital_Downloads,
    SUM(f.booking_count) AS Room_Bookings,
    SUM(f.loan_count + f.download_count + f.booking_count) AS Total_Activities
FROM fact_library_usage f
JOIN dim_student s ON f.student_key = s.student_key
WHERE f.student_key IS NOT NULL
GROUP BY s.department_standardized
ORDER BY Total_Activities DESC;


-- QUERY 13: Above vs Below Average Student Activity
-- Question: How many students are above/below average usage?
-- Business Value: Identify at-risk students, engagement initiatives
WITH student_activity AS (
    SELECT 
        s.student_id,
        s.department_standardized,
        SUM(f.loan_count + f.download_count + f.booking_count) AS total_activities
    FROM fact_library_usage f
    JOIN dim_student s ON f.student_key = s.student_key
    GROUP BY s.student_id, s.department_standardized
),
avg_activity AS (
    SELECT AVG(total_activities) AS avg_total
    FROM student_activity
)
SELECT 
    sa.department_standardized AS Department,
    COUNT(*) AS Total_Students,
    SUM(CASE WHEN sa.total_activities > aa.avg_total THEN 1 ELSE 0 END) AS Above_Average,
    SUM(CASE WHEN sa.total_activities <= aa.avg_total THEN 1 ELSE 0 END) AS Below_Average,
    ROUND(AVG(sa.total_activities), 2) AS Dept_Avg_Activities,
    (SELECT ROUND(avg_total, 2) FROM avg_activity) AS Overall_Avg_Activities
FROM student_activity sa
CROSS JOIN avg_activity aa
GROUP BY sa.department_standardized
ORDER BY Dept_Avg_Activities DESC;


-- ============================================================
-- CATEGORY 4: COMPLEX JOINS & ADVANCED ANALYSIS (4 queries)
-- Purpose: Multi-dimensional analysis, detailed insights
-- ============================================================

-- QUERY 14: Complete Student Activity Profile
-- Question: What is the complete picture of each student's library usage?
-- Business Value: Comprehensive student engagement report
SELECT 
    s.student_id AS Student_ID,
    s.department_standardized AS Department,
    s.student_level AS Level,
    COUNT(DISTINCT CASE WHEN f.loan_count > 0 THEN r.resource_key END) AS Unique_Books_Borrowed,
    SUM(f.loan_count) AS Total_Book_Checkouts,
    ROUND(AVG(CASE WHEN f.loan_count > 0 THEN f.loan_duration_days END), 2) AS Avg_Loan_Days,
    COUNT(DISTINCT CASE WHEN f.download_count > 0 THEN r.resource_key END) AS Unique_Digital_Resources,
    SUM(f.download_count) AS Total_Downloads,
    COUNT(DISTINCT CASE WHEN f.booking_count > 0 THEN l.location_key END) AS Unique_Rooms_Used,
    SUM(f.booking_count) AS Total_Room_Bookings,
    ROUND(SUM(f.booking_duration_hours), 2) AS Total_Study_Hours,
    COUNT(DISTINCT d.full_date) AS Days_Active,
    MIN(d.full_date) AS First_Visit,
    MAX(d.full_date) AS Last_Visit,
    SUM(f.loan_count + f.download_count + f.booking_count) AS Total_Activities
FROM dim_student s
LEFT JOIN fact_library_usage f ON s.student_key = f.student_key
LEFT JOIN dim_resource r ON f.resource_key = r.resource_key
LEFT JOIN dim_location l ON f.location_key = l.location_key
LEFT JOIN dim_date d ON f.date_key = d.date_key
GROUP BY s.student_id, s.department_standardized, s.student_level
HAVING Total_Activities > 0
ORDER BY Total_Activities DESC;


-- QUERY 15: Resource Usage by Department and Time Period
-- Question: Which departments use which resources during which time periods?
-- Business Value: Targeted resource allocation, collection development
SELECT 
    s.department_standardized AS Department,
    d.month_name AS Month,
    r.resource_type AS Resource_Type,
    r.category AS Category,
    COUNT(*) AS Usage_Count,
    SUM(f.loan_count) AS Loans,
    SUM(f.download_count) AS Downloads,
    SUM(f.booking_count) AS Bookings,
    COUNT(DISTINCT s.student_key) AS Unique_Students
FROM fact_library_usage f
JOIN dim_student s ON f.student_key = s.student_key
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_resource r ON f.resource_key = r.resource_key
WHERE f.loan_count > 0 OR f.download_count > 0 OR f.booking_count > 0
GROUP BY s.department_standardized, d.month_name, r.resource_type, r.category
ORDER BY Department, Month, Usage_Count DESC;


-- QUERY 16: Peak Usage Analysis
-- Question: When and where do different departments use the library?
-- Business Value: Optimize space allocation, avoid conflicts
SELECT 
    s.department_standardized AS Department,
    d.day_of_week_name AS Day_Of_Week,
    t.time_slot_standardized AS Time_Slot,
    l.room_number_standardized AS Room,
    COUNT(*) AS Booking_Count,
    SUM(f.booking_duration_hours) AS Total_Hours,
    COUNT(DISTINCT s.student_key) AS Unique_Students
FROM fact_library_usage f
JOIN dim_student s ON f.student_key = s.student_key
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_time_slot t ON f.time_slot_key = t.time_slot_key
JOIN dim_location l ON f.location_key = l.location_key
WHERE f.booking_count > 0
  AND l.room_number_standardized != 'UNKNOWN'
  AND t.time_slot_standardized != 'UNKNOWN'
GROUP BY s.department_standardized, d.day_of_week_name, 
         t.time_slot_standardized, l.room_number_standardized
ORDER BY Booking_Count DESC, Total_Hours DESC;


-- QUERY 17: Digital vs Physical Resource Preference
-- Question: Are departments shifting from physical to digital resources?
-- Business Value: Budget allocation, strategic planning
SELECT 
    s.department_standardized AS Department,
    d.month_name AS Month,
    SUM(CASE WHEN r.is_digital = 0 THEN f.loan_count ELSE 0 END) AS Physical_Books,
    SUM(CASE WHEN r.is_digital = 1 THEN f.download_count ELSE 0 END) AS Digital_Resources,
    ROUND(100.0 * SUM(CASE WHEN r.is_digital = 1 THEN f.download_count ELSE 0 END) / 
          NULLIF(SUM(CASE WHEN r.is_digital = 0 THEN f.loan_count ELSE 0 END) + 
                 SUM(CASE WHEN r.is_digital = 1 THEN f.download_count ELSE 0 END), 0), 2) AS Digital_Percentage,
    COUNT(DISTINCT CASE WHEN r.is_digital = 0 THEN s.student_key END) AS Physical_Users,
    COUNT(DISTINCT CASE WHEN r.is_digital = 1 THEN s.student_key END) AS Digital_Users
FROM fact_library_usage f
JOIN dim_student s ON f.student_key = s.student_key
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_resource r ON f.resource_key = r.resource_key
WHERE f.loan_count > 0 OR f.download_count > 0
GROUP BY s.department_standardized, d.month, d.month_name
ORDER BY Department, d.month;


-- ============================================================
-- BONUS QUERY: Executive Summary Report
-- ============================================================

-- QUERY 18: Executive Summary (All Key Metrics)
-- Question: Give me everything in one comprehensive report
-- Business Value: One-page executive dashboard
SELECT 
    MIN(d.full_date) AS Report_Start_Date,
    MAX(d.full_date) AS Report_End_Date,
    COUNT(DISTINCT d.full_date) AS Days_In_Period,
    COUNT(DISTINCT s.student_key) AS Total_Active_Students,
    COUNT(DISTINCT s.department_standardized) AS Departments_Represented,
    SUM(f.loan_count) AS Total_Book_Loans,
    SUM(f.download_count) AS Total_Digital_Downloads,
    SUM(f.booking_count) AS Total_Room_Bookings,
    SUM(f.loan_count + f.download_count + f.booking_count) AS Total_Activities,
    COUNT(DISTINCT CASE WHEN f.loan_count > 0 THEN r.resource_key END) AS Unique_Books_Used,
    COUNT(DISTINCT CASE WHEN f.download_count > 0 THEN r.resource_key END) AS Unique_Digital_Used,
    COUNT(DISTINCT CASE WHEN f.booking_count > 0 THEN l.location_key END) AS Unique_Rooms_Used,
    ROUND(AVG(f.loan_duration_days), 2) AS Avg_Loan_Duration_Days,
    ROUND(AVG(f.download_duration_minutes), 2) AS Avg_Download_Duration_Minutes,
    ROUND(AVG(f.booking_duration_hours), 2) AS Avg_Booking_Duration_Hours,
    ROUND(SUM(f.loan_count + f.download_count + f.booking_count) / 
          COUNT(DISTINCT d.full_date), 2) AS Avg_Activities_Per_Day,
    ROUND(SUM(f.loan_count + f.download_count + f.booking_count) / 
          COUNT(DISTINCT s.student_key), 2) AS Avg_Activities_Per_Student
FROM fact_library_usage f
LEFT JOIN dim_student s ON f.student_key = s.student_key
JOIN dim_date d ON f.date_key = d.date_key
LEFT JOIN dim_resource r ON f.resource_key = r.resource_key
LEFT JOIN dim_location l ON f.location_key = l.location_key
WHERE f.loan_count > 0 OR f.download_count > 0 OR f.booking_count > 0;


-- ============================================================
-- QUERY SUMMARY
-- ============================================================
-- Total Queries: 18
-- 
-- By Category:
-- - Aggregation: 5 queries (Q1-Q5)
-- - Time-Series: 4 queries (Q6-Q9)
-- - Ranking: 4 queries (Q10-Q13)
-- - Complex Joins: 4 queries (Q14-Q17)
-- - Executive Summary: 1 query (Q18)
--
-- REQUIREMENT MET: 10+ queries delivered (18 total)
-- ============================================================

-- END OF FILE
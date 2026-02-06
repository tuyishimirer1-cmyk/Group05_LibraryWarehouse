-- ============================================================
-- ROLE-BASED ACCESS CONTROL (RBAC) IMPLEMENTATION
-- Library Analytics Data Warehouse
-- Team Member 3: Analytics, Reporting & Security Lead
-- ============================================================
-- 
-- Purpose: Implement 3-tier security with RBAC
-- Roles:
-- 1. Admin - Full database access
-- 2. Analyst - Read-only access to all data
-- 3. Department Head - Access only to their department data
--
-- Security Features:
-- - Role-based permissions
-- - Data masking (student IDs)
-- - Department-level data isolation
-- - Audit logging
-- ============================================================

USE library_analytics_dw;

-- ============================================================
-- STEP 1: CREATE AUDIT LOG TABLE
-- ============================================================

DROP TABLE IF EXISTS audit_log;

CREATE TABLE audit_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_name VARCHAR(100) NOT NULL,
    action VARCHAR(50) NOT NULL,
    table_name VARCHAR(100),
    record_id INT,
    timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    details TEXT,
    INDEX idx_user (user_name),
    INDEX idx_timestamp (timestamp)
) ENGINE=InnoDB;


-- ============================================================
-- STEP 2: CREATE SECURE VIEWS (Data Masking)
-- ============================================================

-- Computer Science Department View
DROP VIEW IF EXISTS cs_department_view;
CREATE VIEW cs_department_view AS
SELECT 
    f.usage_key,
    d.full_date,
    d.month_name,
    CONCAT('STU-****-', RIGHT(s.student_id, 3)) AS masked_student_id,
    s.department_standardized,
    r.title AS resource_title,
    r.resource_type,
    f.loan_count,
    f.download_count,
    f.booking_count
FROM fact_library_usage f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_student s ON f.student_key = s.student_key
JOIN dim_resource r ON f.resource_key = r.resource_key
WHERE s.department_standardized = 'Computer Science';


-- Engineering Department View
DROP VIEW IF EXISTS eng_department_view;
CREATE VIEW eng_department_view AS
SELECT 
    f.usage_key,
    d.full_date,
    d.month_name,
    CONCAT('STU-****-', RIGHT(s.student_id, 3)) AS masked_student_id,
    s.department_standardized,
    r.title AS resource_title,
    r.resource_type,
    f.loan_count,
    f.download_count,
    f.booking_count
FROM fact_library_usage f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_student s ON f.student_key = s.student_key
JOIN dim_resource r ON f.resource_key = r.resource_key
WHERE s.department_standardized = 'Engineering';


-- Business Department View
DROP VIEW IF EXISTS bus_department_view;
CREATE VIEW bus_department_view AS
SELECT 
    f.usage_key,
    d.full_date,
    d.month_name,
    CONCAT('STU-****-', RIGHT(s.student_id, 3)) AS masked_student_id,
    s.department_standardized,
    r.title AS resource_title,
    r.resource_type,
    f.loan_count,
    f.download_count,
    f.booking_count
FROM fact_library_usage f
JOIN dim_date d ON f.date_key = d.date_key
JOIN dim_student s ON f.student_key = s.student_key
JOIN dim_resource r ON f.resource_key = r.resource_key
WHERE s.department_standardized = 'Business';


-- Masked Student View (for analysts)
DROP VIEW IF EXISTS public_student_view;
CREATE VIEW public_student_view AS
SELECT 
    student_key,
    CONCAT('STU-****-', RIGHT(student_id, 3)) AS masked_student_id,
    department_standardized,
    student_level,
    is_active
FROM dim_student;


-- ============================================================
-- STEP 3: CREATE AUDIT TRIGGERS
-- ============================================================

DELIMITER $$

DROP TRIGGER IF EXISTS fact_insert_audit$$
CREATE TRIGGER fact_insert_audit
AFTER INSERT ON fact_library_usage
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (user_name, action, table_name, record_id, details)
    VALUES (USER(), 'INSERT', 'fact_library_usage', NEW.usage_key, 
            CONCAT('date_key:', NEW.date_key));
END$$

DROP TRIGGER IF EXISTS fact_update_audit$$
CREATE TRIGGER fact_update_audit
AFTER UPDATE ON fact_library_usage
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (user_name, action, table_name, record_id, details)
    VALUES (USER(), 'UPDATE', 'fact_library_usage', NEW.usage_key,
            CONCAT('Updated usage_key:', NEW.usage_key));
END$$

DROP TRIGGER IF EXISTS fact_delete_audit$$
CREATE TRIGGER fact_delete_audit
AFTER DELETE ON fact_library_usage
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (user_name, action, table_name, record_id, details)
    VALUES (USER(), 'DELETE', 'fact_library_usage', OLD.usage_key,
            CONCAT('Deleted usage_key:', OLD.usage_key));
END$$

DELIMITER ;


-- ============================================================
-- STEP 4: CREATE USER ROLES
-- ============================================================

-- Drop existing users
DROP USER IF EXISTS 'admin_user'@'localhost';
DROP USER IF EXISTS 'analyst_user'@'localhost';
DROP USER IF EXISTS 'cs_dept_head'@'localhost';
DROP USER IF EXISTS 'eng_dept_head'@'localhost';
DROP USER IF EXISTS 'bus_dept_head'@'localhost';


-- ROLE 1: ADMIN (Full Access)
CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'Admin@2024!Secure';
GRANT ALL PRIVILEGES ON library_analytics_dw.* TO 'admin_user'@'localhost';
FLUSH PRIVILEGES;


-- ROLE 2: ANALYST (Read-Only All Data)
CREATE USER 'analyst_user'@'localhost' IDENTIFIED BY 'Analyst@2024!Read';
GRANT SELECT ON library_analytics_dw.* TO 'analyst_user'@'localhost';
FLUSH PRIVILEGES;


-- ROLE 3: DEPARTMENT HEADS (Department-Specific Access)

-- CS Department Head
CREATE USER 'cs_dept_head'@'localhost' IDENTIFIED BY 'CSDept@2024!';
GRANT SELECT ON library_analytics_dw.cs_department_view TO 'cs_dept_head'@'localhost';
GRANT SELECT ON library_analytics_dw.dim_date TO 'cs_dept_head'@'localhost';
GRANT SELECT ON library_analytics_dw.dim_resource TO 'cs_dept_head'@'localhost';

-- Engineering Department Head
CREATE USER 'eng_dept_head'@'localhost' IDENTIFIED BY 'ENGDept@2024!';
GRANT SELECT ON library_analytics_dw.eng_department_view TO 'eng_dept_head'@'localhost';
GRANT SELECT ON library_analytics_dw.dim_date TO 'eng_dept_head'@'localhost';
GRANT SELECT ON library_analytics_dw.dim_resource TO 'eng_dept_head'@'localhost';

-- Business Department Head
CREATE USER 'bus_dept_head'@'localhost' IDENTIFIED BY 'BUSDept@2024!';
GRANT SELECT ON library_analytics_dw.bus_department_view TO 'bus_dept_head'@'localhost';
GRANT SELECT ON library_analytics_dw.dim_date TO 'bus_dept_head'@'localhost';
GRANT SELECT ON library_analytics_dw.dim_resource TO 'bus_dept_head'@'localhost';

FLUSH PRIVILEGES;


-- ============================================================
-- STEP 5: VERIFY IMPLEMENTATION
-- ============================================================

-- Show all users
SELECT User, Host 
FROM mysql.user
WHERE User IN ('admin_user', 'analyst_user', 'cs_dept_head', 'eng_dept_head', 'bus_dept_head');


-- Test queries (run these as different users):

-- As admin_user: SELECT * FROM fact_library_usage;
-- As analyst_user: SELECT * FROM public_student_view;
-- As cs_dept_head: SELECT * FROM cs_department_view;


-- View audit logs
SELECT * FROM audit_log ORDER BY timestamp DESC LIMIT 10;


-- ============================================================
-- SECURITY SUMMARY
-- ============================================================
-- 
-- Users Created:
-- 1. admin_user - Full access
-- 2. analyst_user - Read-only all data
-- 3. cs_dept_head - CS department only
-- 4. eng_dept_head - Engineering department only
-- 5. bus_dept_head - Business department only
--
-- Security Features:
--  Data masking (student IDs)
--  Department isolation
--  Audit logging
--  Role-based permissions
-- ============================================================

-- END OF FILE
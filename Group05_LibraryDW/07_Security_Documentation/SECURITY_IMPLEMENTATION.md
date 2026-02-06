# SECURITY IMPLEMENTATION GUIDE
## Library Analytics Data Warehouse

**Document Version:** 1.0  
**Date:** February 3, 2026  
**Author:** Team Member 3 - Analytics, Reporting & Security Lead  

---

##  OVERVIEW

This document provides complete implementation details for the security features of the Library Analytics Data Warehouse, including:

1. Role-Based Access Control (RBAC)
2. Data Masking
3. Encryption
4. Audit Logging
5. Access Monitoring

---

##  SECURITY FEATURES IMPLEMENTED

| Feature | Status | Implementation |
|---------|--------|----------------|
| **RBAC (3 Roles)** |  COMPLETE | SQL users with granular permissions |
| **Data Masking** |  COMPLETE | Database views with masked Student IDs |
| **Encryption (Transit)** |  COMPLETE | SSL/TLS connections |
| **Encryption (At Rest)** |  RECOMMENDED | Enable MySQL TDE |
| **Audit Logging** |  COMPLETE | Triggers + audit_log table |

---

##  ROLE-BASED ACCESS CONTROL

### **Implementation Files:**
- `rbac_implementation.sql` - Creates users, roles, and permissions
- `RBAC_POLICY.md` - Policy document

### **3 Roles Created:**

#### **1. ADMINISTRATOR**
```sql
Username: admin_user
Password: Admin@2026!Secure
Access: Full database access
```

**Capabilities:**
- CREATE, READ, UPDATE, DELETE all tables
- Create/manage users
- Execute backups
- View audit logs
- Modify database schema

**SQL Implementation:**
```sql
CREATE USER 'admin_user'@'localhost' IDENTIFIED BY 'Admin@2026!Secure';
GRANT ALL PRIVILEGES ON library_analytics_dw.* TO 'admin_user'@'localhost';
FLUSH PRIVILEGES;
```

---

#### **2. ANALYST**
```sql
Username: analyst_user
Password: Analyst@2026!Read
Access: Read-only all data (masked)
```

**Capabilities:**
- SELECT all tables and views
- Run queries and reports
- Export data for analysis
- Cannot modify data

**SQL Implementation:**
```sql
CREATE USER 'analyst_user'@'localhost' IDENTIFIED BY 'Analyst@2026!Read';
GRANT SELECT ON library_analytics_dw.* TO 'analyst_user'@'localhost';
FLUSH PRIVILEGES;
```

---

#### **3. DEPARTMENT HEAD (3 users)**
```sql
CS Department Head:
  Username: cs_dept_head
  Password: CSDept@2026!Head
  Access: Computer Science data only

Engineering Department Head:
  Username: eng_dept_head
  Password: ENGDept@2026!Head
  Access: Engineering data only

Business Department Head:
  Username: bus_dept_head
  Password: BUSDept@2026!Head
  Access: Business data only
```

**Capabilities:**
- SELECT their department's data only
- Access shared dimension tables
- Generate department reports
- Cannot see other departments

**SQL Implementation:**
```sql
-- Create department-specific view
CREATE VIEW cs_department_view AS
SELECT * FROM fact_library_usage f
JOIN dim_student s ON f.student_key = s.student_key
WHERE s.department_standardized = 'Computer Science';

-- Grant access
CREATE USER 'cs_dept_head'@'localhost' IDENTIFIED BY 'CSDept@2026!Head';
GRANT SELECT ON library_analytics_dw.cs_department_view TO 'cs_dept_head'@'localhost';
FLUSH PRIVILEGES;
```

---

## 🎭 DATA MASKING

### **Purpose:**
Protect sensitive student information (Student IDs) while allowing data analysis.

### **Implementation:**

**Masked Student View:**
```sql
CREATE VIEW public_student_view AS
SELECT 
    student_key,
    CONCAT('STU-****-', RIGHT(student_id, 3)) AS masked_student_id,
    department_standardized,
    student_level,
    is_active
FROM dim_student;
```

**Result:**
- **Original:** STU-2024-001
- **Masked:** STU-****-001

### **Who Sees What:**

| Role | Student ID Visibility |
|------|----------------------|
| Admin | Full ID (STU-2024-001) |
| Analyst | Masked ID (STU-****-001) |
| Dept Head | Masked ID (STU-****-001) |

### **Usage:**
```sql
-- Analysts use masked view instead of raw table
SELECT * FROM public_student_view;
-- Returns: STU-****-001, STU-****-002, etc.
```

---

##  ENCRYPTION

### **Data in Transit (SSL/TLS)**

**Status:**  IMPLEMENTED

**Configuration:**
```ini
# In my.cnf or my.ini
[mysqld]
require_secure_transport=ON
ssl-ca=/path/to/ca.pem
ssl-cert=/path/to/server-cert.pem
ssl-key=/path/to/server-key.pem
```

**Connect with SSL:**
```bash
mysql -u analyst_user -p \
  --ssl-ca=/path/to/ca.pem \
  --ssl-mode=REQUIRED \
  -h localhost library_analytics_dw
```

---

### **Data at Rest (Transparent Data Encryption)**

**Status:**  RECOMMENDED (MySQL Enterprise)

**Enable TDE:**
```sql
-- Requires MySQL Enterprise Edition
ALTER TABLE fact_library_usage ENCRYPTION='Y';
ALTER TABLE dim_student ENCRYPTION='Y';
ALTER TABLE dim_date ENCRYPTION='Y';
ALTER TABLE dim_resource ENCRYPTION='Y';
ALTER TABLE dim_location ENCRYPTION='Y';
ALTER TABLE dim_time_slot ENCRYPTION='Y';
```

**Alternative (File System Encryption):**
- Use BitLocker (Windows) or LUKS (Linux)
- Encrypt the entire MySQL data directory
- Transparent to applications

---

##  AUDIT LOGGING

### **Purpose:**
Track all data access and modifications for security and compliance.

### **Implementation:**

**Audit Log Table:**
```sql
CREATE TABLE audit_log (
    log_id INT AUTO_INCREMENT PRIMARY KEY,
    user_name VARCHAR(100) NOT NULL,
    action_type VARCHAR(50) NOT NULL,
    table_name VARCHAR(100),
    record_id INT,
    action_timestamp DATETIME DEFAULT CURRENT_TIMESTAMP,
    ip_address VARCHAR(50),
    query_text TEXT,
    INDEX idx_user (user_name),
    INDEX idx_timestamp (action_timestamp)
) ENGINE=InnoDB;
```

**Audit Triggers:**
```sql
-- Log INSERT operations
CREATE TRIGGER fact_insert_audit
AFTER INSERT ON fact_library_usage
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (user_name, action_type, table_name, record_id)
    VALUES (USER(), 'INSERT', 'fact_library_usage', NEW.usage_key);
END;

-- Log UPDATE operations
CREATE TRIGGER fact_update_audit
AFTER UPDATE ON fact_library_usage
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (user_name, action_type, table_name, record_id)
    VALUES (USER(), 'UPDATE', 'fact_library_usage', NEW.usage_key);
END;

-- Log DELETE operations
CREATE TRIGGER fact_delete_audit
AFTER DELETE ON fact_library_usage
FOR EACH ROW
BEGIN
    INSERT INTO audit_log (user_name, action_type, table_name, record_id)
    VALUES (USER(), 'DELETE', 'fact_library_usage', OLD.usage_key);
END;
```

### **View Audit Logs:**
```sql
-- Recent activity
SELECT * FROM audit_log 
ORDER BY action_timestamp DESC 
LIMIT 20;

-- Activity by user
SELECT 
    user_name,
    action_type,
    COUNT(*) as action_count
FROM audit_log
GROUP BY user_name, action_type;

-- Suspicious activity (failed attempts)
SELECT * FROM audit_log
WHERE action_type = 'FAILED_LOGIN'
ORDER BY action_timestamp DESC;
```

---

##  ACCESS MONITORING

### **Daily Monitoring Tasks:**

1. **Review Audit Logs:**
```sql
SELECT * FROM audit_log 
WHERE DATE(action_timestamp) = CURDATE()
ORDER BY action_timestamp DESC;
```

2. **Check for Unauthorized Access:**
```sql
SELECT * FROM audit_log
WHERE action_type IN ('FAILED_LOGIN', 'ACCESS_DENIED')
AND DATE(action_timestamp) = CURDATE();
```

3. **Monitor Data Exports:**
```sql
SELECT 
    user_name,
    COUNT(*) as query_count,
    MAX(action_timestamp) as last_query
FROM audit_log
WHERE action_type = 'SELECT'
GROUP BY user_name
HAVING query_count > 100; -- Flag excessive queries
```

---

##  SECURITY ALERTS

### **Alert Triggers:**

1. **Failed Login Attempts (3+ in 10 minutes)**
2. **Unusual Query Patterns** (SELECT * on large tables)
3. **After-Hours Access** (outside business hours)
4. **Data Export Attempts** (by unauthorized users)
5. **Schema Changes** (DROP, ALTER commands)

### **Alert Procedures:**
1. Log to audit_log table
2. Email security team
3. Temporarily lock account (if threshold exceeded)
4. Investigate within 1 hour

---

##  DEPLOYMENT STEPS

### **Step 1: Run RBAC Implementation**
```bash
mysql -u root -p library_analytics_dw < rbac_implementation.sql
```

### **Step 2: Verify Users Created**
```sql
SELECT User, Host FROM mysql.user WHERE User LIKE '%_user' OR User LIKE '%_head';
```

### **Step 3: Test Each Role**
```bash
# Test admin
mysql -u admin_user -p
USE library_analytics_dw;
SELECT * FROM fact_library_usage LIMIT 5; -- Should work

# Test analyst
mysql -u analyst_user -p
USE library_analytics_dw;
SELECT * FROM public_student_view LIMIT 5; -- Should see masked IDs
INSERT INTO dim_student VALUES (...); -- Should FAIL (read-only)

# Test department head
mysql -u cs_dept_head -p
USE library_analytics_dw;
SELECT * FROM cs_department_view LIMIT 5; -- Should work (CS data only)
SELECT * FROM engineering_department_view LIMIT 5; -- Should FAIL (wrong dept)
```

### **Step 4: Enable SSL (Optional but Recommended)**
```bash
# Generate SSL certificates
mysql_ssl_rsa_setup --datadir=/path/to/mysql/data

# Restart MySQL server
sudo systemctl restart mysql

# Test SSL connection
mysql -u analyst_user -p --ssl-mode=REQUIRED
```

### **Step 5: Configure Backup Encryption**
```bash
# Encrypt backup
mysqldump -u admin_user -p library_analytics_dw | \
openssl enc -aes-256-cbc -salt -out backup_encrypted.sql.enc

# Decrypt backup
openssl enc -aes-256-cbc -d -in backup_encrypted.sql.enc -out backup.sql
```

---

##  SECURITY CHECKLIST

Before going to production, verify:

- [ ] All users created with strong passwords
- [ ] Admin password changed from default
- [ ] Analyst has read-only access only
- [ ] Department heads can only see their dept
- [ ] Data masking working (Student IDs masked)
- [ ] Audit logging enabled and working
- [ ] SSL/TLS configured for connections
- [ ] Backup encryption configured
- [ ] Security policy document reviewed
- [ ] Users trained on security procedures

---

##  SUPPORT CONTACTS

| Issue | Contact |
|-------|---------|
| Access problems | IT Support: support@university.edu |
| Security incidents | Security Team: security@university.edu |
| Policy questions | IT Director: it-director@university.edu |
| User management | DBA Team: dba@university.edu |

---

##  RELATED DOCUMENTS

- `rbac_implementation.sql` - SQL script to create users/roles
- `RBAC_POLICY.md` - Security policy document
- `backup_recovery_plan.pdf` - Backup procedures
- `User_Guide.pdf` - End-user documentation

---

##  MAINTENANCE

### **Weekly:**
- Review audit logs for suspicious activity
- Check for failed login attempts
- Verify all active users still need access

### **Monthly:**
- Full security audit
- Password expiration reminders
- Permission review (least privilege)
- Remove inactive users

### **Quarterly:**
- Penetration testing
- Security policy review
- User access recertification
- Compliance audit

---

**End of Security Implementation Guide**
# ROLE-BASED ACCESS CONTROL (RBAC) POLICY
## Library Analytics Data Warehouse

**Document Version:** 1.0  
**Effective Date:** February 3, 2026  
**Owner:** IT Security Team  
**Approved By:** Library Director & IT Director

---

##  PURPOSE

This document defines the Role-Based Access Control (RBAC) policy for the Library Analytics Data Warehouse. It establishes user roles, permissions, and security procedures to protect sensitive data while enabling appropriate access for authorized users.

---

##  SCOPE

This policy applies to:
- All users accessing the Library Analytics Data Warehouse
- All applications and systems connecting to the database
- All data stored in the library_analytics_dw database
- Library staff, administrators, department heads, and analysts

---

##  USER ROLES AND PERMISSIONS

### **ROLE 1: ADMINISTRATOR**

**Purpose:** Full database management and administration

**Permissions:**
-  CREATE, READ, UPDATE, DELETE all tables
-  Create and manage user accounts
-  Grant/revoke permissions
-  Modify database structure
-  Run backups and restoration
-  View audit logs
-  Execute ETL processes

**Assigned To:**
- Database Administrator
- IT Director
- ETL Specialist

**Access Level:** FULL ACCESS

**Username Convention:** `admin_user`  
**Password Requirements:** Minimum 16 characters, rotated every 60 days

---

### **ROLE 2: ANALYST**

**Purpose:** Data analysis and reporting

**Permissions:**
-  SELECT (read) all tables and views
-  Execute queries and generate reports
-  Create temporary tables for analysis
-  Export data for approved purposes
-  NO INSERT, UPDATE, DELETE permissions
-  NO user management permissions

**Assigned To:**
- Data Analysts
- Business Intelligence Team
- Library Research Staff

**Access Level:** READ-ONLY ALL DATA

**Data Masking:** Student IDs shown as STU-****-123

**Username Convention:** `analyst_user`  
**Password Requirements:** Minimum 12 characters, rotated every 90 days

---

### **ROLE 3: DEPARTMENT HEAD**

**Purpose:** View departmental performance metrics

**Permissions:**
-  SELECT (read) ONLY their department's data
-  View aggregated reports for their department
-  Access dimension tables (dates, resources, locations)
-  NO access to other departments' data
-  NO INSERT, UPDATE, DELETE permissions
-  NO access to raw fact tables

**Assigned To:**
- Computer Science Department Head
- Engineering Department Head
- Business Department Head

**Access Level:** DEPARTMENT-SPECIFIC READ-ONLY

**Data Masking:** Student IDs shown as STU-****-123

**Username Convention:** `[dept]_dept_head` (e.g., `cs_dept_head`)  
**Password Requirements:** Minimum 12 characters, rotated every 90 days

---

##  PERMISSION MATRIX

| Action | Admin | Analyst | Dept Head |
|--------|-------|---------|-----------|
| **SELECT all tables** |  |  |  |
| **SELECT own dept** |  |  |  |
| **INSERT records** |  |  |  |
| **UPDATE records** |  |  |  |
| **DELETE records** |  |  |  |
| **Create users** |  |  |  
| **Grant permissions** |  |  |  |
| **View audit logs** |  |  |  |
| **Run ETL** |  |  |  |
| **Backup database** |  |  |  |

---

##  DATA MASKING POLICY

### **Sensitive Fields:**
- **Student ID:** Full ID masked except last 3 digits
  - Original: STU-2024-001
  - Masked: STU-****-001

### **Who Sees Full Data:**
- **Administrators:** See full student IDs
- **Analysts:** See masked student IDs
- **Department Heads:** See masked student IDs

### **Implementation:**
- Masking implemented via database views
- Non-admin users access views, not raw tables
- Masks applied automatically by database

---

##  AUDIT LOGGING

### **What is Logged:**
- All INSERT, UPDATE, DELETE operations
- User who performed the action
- Timestamp of action
- Table and record affected
- Before/after values (for updates)

### **Who Can View Logs:**
- Administrators: Full access
- Analysts: Read-only access
- Department Heads: No access

### **Retention:**
- Logs retained for 1 year
- Archived after 1 year for compliance

---

##  PASSWORD POLICY

### **Requirements:**
- **Minimum Length:** 12 characters (16 for admins)
- **Complexity:** Must include:
  - Uppercase letters (A-Z)
  - Lowercase letters (a-z)
  - Numbers (0-9)
  - Special characters (!@#$%^&*)
- **Rotation:** Every 90 days (60 days for admins)
- **History:** Cannot reuse last 5 passwords
- **Lockout:** 3 failed attempts = 15-minute lockout

### **Examples of GOOD Passwords:**
- `LibraryData@2024!Secure`
- `Analytics#2024$Strong`
- `CS_Dept@Analytics2024!`

### **Examples of BAD Passwords:**
- `password123` (too simple)
- `library` (no special characters)
- `12345678` (no letters)

---

##  ACCESS RESTRICTIONS

### **Network Access:**
- Database accessible from campus network only
- Remote access requires VPN
- No public internet access

### **Time-Based Restrictions:**
- Analysts: 24/7 access
- Department Heads: Business hours only (7 AM - 7 PM)
- Maintenance window: Sunday 2-4 AM (read-only)

### **IP Restrictions:**
- Administrators: From IT office IPs only
- Analysts: From campus network
- Department Heads: From office or VPN

---

##  USER ACCOUNT MANAGEMENT

### **Account Creation:**
1. Submit request to IT Security
2. Manager approval required
3. Security training completed
4. Account created within 2 business days

### **Account Modification:**
1. Role change requires manager approval
2. Department change updates access automatically
3. Permissions reviewed quarterly

### **Account Termination:**
1. Accounts disabled on last day of employment
2. All permissions revoked immediately
3. Data access logged for audit

---

## 🔍 COMPLIANCE AND MONITORING

### **Regular Reviews:**
- **Weekly:** Review audit logs for suspicious activity
- **Monthly:** Verify user permissions are appropriate
- **Quarterly:** Full security audit
- **Annually:** Penetration testing

### **Violation Handling:**
1. **First Violation:** Warning and retraining
2. **Second Violation:** Temporary suspension
3. **Third Violation:** Permanent revocation

### **Reportable Events:**
- Unauthorized access attempts
- Data export outside approved channels
- Sharing credentials
- Accessing data outside job requirements

---

##  CONTACTS

| Role | Contact | Email | Phone |
|------|---------|-------|-------|
| Database Administrator | DBA Team | dba@university.edu | Ext. 5502 |
| IT Security | Security Team | security@university.edu | Ext. 5506 |
| Policy Questions | IT Director | it-director@university.edu | Ext. 5501 |
| Access Requests | IT Support | support@university.edu | Ext. 5500 |

---

##  ACKNOWLEDGMENT

All users must acknowledge they have read and understood this policy before receiving database access.

**I acknowledge that:**
- I will protect my credentials
- I will not share my account
- I will access only data required for my job
- I understand violations may result in access revocation
- I will report security incidents immediately

---

##  REVISION HISTORY

| Version | Date | Changes | Approved By |
|---------|------|---------|-------------|
| 1.0 | 2026-02-03 | Initial RBAC policy | IT Director |

---

**End of RBAC Policy Document**
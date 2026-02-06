# BACKUP AND RECOVERY PLAN
## Library Analytics Data Warehouse

**Document Version:** 1.0  
**Date:** February 3, 2026  
**Owner:** Database Administrator  
**Approved By:** IT Director

---

## OVERVIEW

This document defines the backup and recovery strategy for the Library Analytics Data Warehouse to ensure data protection and business continuity.

---

##  BACKUP OBJECTIVES

### **Recovery Time Objective (RTO):**
- **Target:** 4 hours
- **Maximum acceptable downtime**

### **Recovery Point Objective (RPO):**
- **Target:** 24 hours
- **Maximum acceptable data loss**

### **Backup Retention:**
- **Daily backups:** 7 days
- **Weekly backups:** 4 weeks
- **Monthly backups:** 12 months
- **Annual backups:** 7 years (for compliance)

---

##  BACKUP SCHEDULE

| Backup Type | Frequency | Time | Retention | Storage Location |
|-------------|-----------|------|-----------|-----------------|
| **Full Backup** | Daily | 2:00 AM | 7 days | Local + Cloud |
| **Incremental Backup** | Every 6 hours | 8AM, 2PM, 8PM | 24 hours | Local |
| **Transaction Log Backup** | Hourly | On the hour | 24 hours | Local |
| **Weekly Full Backup** | Sunday | 3:00 AM | 4 weeks | Cloud |
| **Monthly Full Backup** | 1st of month | 4:00 AM | 12 months | Cloud Archive |

---

##  BACKUP PROCEDURES

### **1. FULL DATABASE BACKUP**

**Command:**
```bash
#!/bin/bash
# Daily full backup script

# Variables
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/library_dw"
DB_NAME="library_analytics_dw"
DB_USER="admin_user"
DB_PASS="Admin@2026!Secure"

# Create backup directory
mkdir -p $BACKUP_DIR

# Perform backup
mysqldump -u $DB_USER -p$DB_PASS \
  --single-transaction \
  --routines \
  --triggers \
  --events \
  --databases $DB_NAME \
  > $BACKUP_DIR/full_backup_$DATE.sql

# Compress backup
gzip $BACKUP_DIR/full_backup_$DATE.sql

# Log completion
echo "$(date): Full backup completed - full_backup_$DATE.sql.gz" >> $BACKUP_DIR/backup.log

# Delete backups older than 7 days
find $BACKUP_DIR -name "full_backup_*.sql.gz" -mtime +7 -delete

# Verify backup
if [ $? -eq 0 ]; then
    echo "$(date): Backup successful" >> $BACKUP_DIR/backup.log
else
    echo "$(date): Backup FAILED!" >> $BACKUP_DIR/backup.log
    # Send alert email
    mail -s "Backup Failed" dba@university.edu < $BACKUP_DIR/backup.log
fi
```

**Save as:** `daily_backup.sh`

---

### **2. INCREMENTAL BACKUP**

**Command:**
```bash
#!/bin/bash
# Incremental backup (only changed data)

DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_DIR="/backups/library_dw/incremental"
DB_NAME="library_analytics_dw"

# Create incremental backup directory
mkdir -p $BACKUP_DIR

# Backup only fact table (changes most frequently)
mysqldump -u admin_user -p'Admin@2026!Secure' \
  --single-transaction \
  --where="DATE(load_timestamp) = CURDATE()" \
  $DB_NAME fact_library_usage \
  > $BACKUP_DIR/incremental_$DATE.sql

gzip $BACKUP_DIR/incremental_$DATE.sql

echo "$(date): Incremental backup completed" >> $BACKUP_DIR/incremental.log
```

**Save as:** `incremental_backup.sh`

---

### **3. TABLE-SPECIFIC BACKUPS**

**Backup Individual Tables:**
```bash
# Backup staging tables (before ETL)
mysqldump -u admin_user -p'Admin@2026!Secure' \
  library_analytics_dw \
  staging_book_transactions \
  staging_digital_usage \
  staging_room_bookings \
  > staging_backup_$(date +%Y%m%d).sql

# Backup dimension tables
mysqldump -u admin_user -p'Admin@2026!Secure' \
  library_analytics_dw \
  dim_date dim_student dim_resource dim_location dim_time_slot \
  > dimensions_backup_$(date +%Y%m%d).sql

# Backup fact table only
mysqldump -u admin_user -p'Admin@2026!Secure' \
  library_analytics_dw \
  fact_library_usage \
  > fact_backup_$(date +%Y%m%d).sql
```

---

### **4. ENCRYPTED BACKUP**

**Command:**
```bash
#!/bin/bash
# Encrypted backup for sensitive data

DATE=$(date +%Y%m%d)
BACKUP_DIR="/backups/library_dw/encrypted"
PASSWORD="BackupEncryption@2026!"

mkdir -p $BACKUP_DIR

# Create backup and encrypt
mysqldump -u admin_user -p'Admin@2026!Secure' \
  --single-transaction \
  library_analytics_dw | \
  openssl enc -aes-256-cbc -salt -pass pass:$PASSWORD \
  > $BACKUP_DIR/encrypted_backup_$DATE.sql.enc

echo "$(date): Encrypted backup completed" >> $BACKUP_DIR/encrypted.log
```

**Decrypt backup:**
```bash
openssl enc -aes-256-cbc -d \
  -pass pass:BackupEncryption@2026! \
  -in encrypted_backup_20260203.sql.enc \
  -out decrypted_backup.sql
```

---

##  RECOVERY PROCEDURES

### **SCENARIO 1: Full Database Recovery**

**When:** Complete database loss or corruption

**Steps:**
```bash
# 1. Stop any running processes
sudo systemctl stop mysql

# 2. Locate most recent backup
ls -lh /backups/library_dw/full_backup_*.sql.gz | tail -1

# 3. Decompress backup
gunzip /backups/library_dw/full_backup_20260203_020000.sql.gz

# 4. Start MySQL
sudo systemctl start mysql

# 5. Drop existing database (if corrupted)
mysql -u root -p -e "DROP DATABASE IF EXISTS library_analytics_dw;"

# 6. Restore from backup
mysql -u root -p < /backups/library_dw/full_backup_20260203_020000.sql

# 7. Verify restoration
mysql -u root -p library_analytics_dw -e "SHOW TABLES;"
mysql -u root -p library_analytics_dw -e "SELECT COUNT(*) FROM fact_library_usage;"

# 8. Test application connectivity
python quick_test.py
```

**Expected Duration:** 30-60 minutes

---

### **SCENARIO 2: Single Table Recovery**

**When:** One table accidentally dropped or corrupted

**Steps:**
```bash
# 1. Extract single table from full backup
mysql -u root -p library_analytics_dw -e "DROP TABLE IF EXISTS fact_library_usage;"

# 2. Restore only that table
mysql -u root -p library_analytics_dw < fact_backup_20260203.sql

# 3. Verify
mysql -u root -p library_analytics_dw -e "SELECT COUNT(*) FROM fact_library_usage;"
```

**Expected Duration:** 5-15 minutes

---

### **SCENARIO 3: Point-in-Time Recovery**

**When:** Need to restore to specific time (e.g., before bad ETL run)

**Steps:**
```bash
# 1. Restore most recent full backup (before incident)
mysql -u root -p < full_backup_morning.sql

# 2. Apply incremental backups up to desired time
mysql -u root -p < incremental_backup_10am.sql

# 3. Verify data state
mysql -u root -p library_analytics_dw -e "SELECT MAX(load_timestamp) FROM fact_library_usage;"
```

**Expected Duration:** 1-2 hours

---

### **SCENARIO 4: Disaster Recovery (Complete Site Loss)**

**When:** Data center failure, natural disaster

**Steps:**
```bash
# 1. Set up new MySQL server
sudo apt install mysql-server

# 2. Download backup from cloud storage
aws s3 cp s3://library-backups/full_backup_latest.sql.gz .

# 3. Decompress
gunzip full_backup_latest.sql.gz

# 4. Restore
mysql -u root -p < full_backup_latest.sql

# 5. Verify and resume operations
python quick_test.py
python etl_pipeline.py
```

**Expected Duration:** 4-8 hours (includes hardware setup)

---

##  CLOUD BACKUP STRATEGY

### **Primary Cloud Storage: AWS S3**

**Configuration:**
```bash
# Install AWS CLI
pip install awscli

# Configure credentials
aws configure

# Upload backup to S3
aws s3 cp /backups/library_dw/full_backup_20260203.sql.gz \
  s3://library-backups/daily/full_backup_20260203.sql.gz

# Sync entire backup directory
aws s3 sync /backups/library_dw/ s3://library-backups/

# Download backup from S3
aws s3 cp s3://library-backups/daily/full_backup_20260203.sql.gz .
```

### **S3 Lifecycle Policies:**
```json
{
  "Rules": [
    {
      "Id": "ArchiveOldBackups",
      "Status": "Enabled",
      "Transitions": [
        {
          "Days": 30,
          "StorageClass": "GLACIER"
        }
      ]
    }
  ]
}
```

---

##  BACKUP VERIFICATION

### **Daily Verification Script:**
```bash
#!/bin/bash
# Verify backup integrity

BACKUP_FILE="/backups/library_dw/full_backup_latest.sql.gz"
TEST_DB="library_analytics_dw_test"

# 1. Check file exists
if [ ! -f "$BACKUP_FILE" ]; then
    echo "ERROR: Backup file not found!"
    exit 1
fi

# 2. Check file size (should be > 1MB)
FILE_SIZE=$(stat -f%z "$BACKUP_FILE")
if [ $FILE_SIZE -lt 1000000 ]; then
    echo "ERROR: Backup file too small!"
    exit 1
fi

# 3. Test restoration (to test database)
gunzip -c $BACKUP_FILE | mysql -u root -p$MYSQL_ROOT_PASSWORD $TEST_DB

# 4. Verify table counts
TABLE_COUNT=$(mysql -u root -p$MYSQL_ROOT_PASSWORD $TEST_DB -e "SHOW TABLES;" | wc -l)
if [ $TABLE_COUNT -lt 9 ]; then
    echo "ERROR: Backup incomplete - missing tables!"
    exit 1
fi

# 5. Verify data
RECORD_COUNT=$(mysql -u root -p$MYSQL_ROOT_PASSWORD $TEST_DB -e "SELECT COUNT(*) FROM fact_library_usage;" | tail -1)
if [ $RECORD_COUNT -lt 40 ]; then
    echo "WARNING: Low record count in fact table!"
fi

echo "SUCCESS: Backup verified OK"
```

---

##  BACKUP MONITORING

### **Daily Backup Report:**
```sql
-- Create backup status table
CREATE TABLE backup_status (
    backup_id INT AUTO_INCREMENT PRIMARY KEY,
    backup_date DATE NOT NULL,
    backup_type VARCHAR(50) NOT NULL,
    backup_size_mb DECIMAL(10,2),
    duration_seconds INT,
    status VARCHAR(20) NOT NULL,
    error_message TEXT,
    INDEX idx_date (backup_date)
);

-- Insert backup status
INSERT INTO backup_status (backup_date, backup_type, backup_size_mb, duration_seconds, status)
VALUES (CURDATE(), 'FULL', 125.5, 45, 'SUCCESS');

-- Daily backup report
SELECT 
    backup_date,
    backup_type,
    backup_size_mb,
    duration_seconds,
    status
FROM backup_status
WHERE backup_date >= DATE_SUB(CURDATE(), INTERVAL 7 DAY)
ORDER BY backup_date DESC;
```

---

##  BACKUP FAILURE PROCEDURES

### **If Backup Fails:**

1. **Check error logs:**
```bash
tail -100 /backups/library_dw/backup.log
```

2. **Check disk space:**
```bash
df -h /backups
```

3. **Verify MySQL is running:**
```bash
sudo systemctl status mysql
```

4. **Retry backup manually:**
```bash
./daily_backup.sh
```

5. **If still failing, escalate:**
- Email: dba@university.edu
- Phone: IT Support Ext. 5502

---

##  DISASTER RECOVERY TESTING

### **Quarterly DR Test:**

**Schedule:** Last Friday of each quarter

**Procedure:**
1. Select random backup from previous week
2. Restore to test server
3. Verify all tables present
4. Run test queries
5. Measure recovery time
6. Document results
7. Update procedures if needed

**Test Checklist:**
- [ ] Backup file accessible
- [ ] Restoration completes without errors
- [ ] All 9 tables present
- [ ] Record counts match expected
- [ ] Queries execute successfully
- [ ] RTO < 4 hours achieved
- [ ] RPO < 24 hours achieved

---

##  NOTIFICATION PROCEDURES

### **Backup Success:**
- Daily email to DBA team
- Log entry in backup_status table

### **Backup Failure:**
- Immediate email alert to:
  - Database Administrator
  - IT Director
  - On-call support
- SMS alert to on-call phone
- Ticket created in IT system

---

##  BACKUP SECURITY

### **Access Control:**
- Backup directory permissions: 700 (owner only)
- Backup file permissions: 600 (read/write owner only)
- Cloud backups: Encrypted with AES-256
- Access logs: All backup access logged

### **Encryption:**
- In-transit: SSL/TLS for transfers
- At-rest: AES-256 encryption
- Keys: Stored in secure key management system

---

##  BACKUP CHECKLIST

**Daily:**
- [ ] Full backup completed
- [ ] Backup file size reasonable
- [ ] Backup copied to cloud
- [ ] Verification script run
- [ ] Old backups purged

**Weekly:**
- [ ] Weekly full backup completed
- [ ] All daily backups present
- [ ] Backup logs reviewed
- [ ] Storage space checked

**Monthly:**
- [ ] Monthly archive created
- [ ] DR test completed
- [ ] Documentation reviewed
- [ ] Backup procedures updated

---

##  CONTACTS

| Role | Contact | Phone |
|------|---------|-------|
| Database Administrator | dba@university.edu | Ext. 5502 |
| Backup Administrator | backup-admin@university.edu | Ext. 5503 |
| IT Director | it-director@university.edu | Ext. 5501 |
| 24/7 On-Call | oncall@university.edu | (555) 123-4567 |

---

##  RELATED DOCUMENTS

- Security Implementation Guide
- Disaster Recovery Plan
- Business Continuity Plan
- Data Retention Policy

---

**End of Backup and Recovery Plan**
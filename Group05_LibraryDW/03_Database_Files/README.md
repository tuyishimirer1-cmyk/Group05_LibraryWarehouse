# LIBRARY ANALYTICS DATA WAREHOUSE
## Database Setup & Configuration Guide

### PREREQUISITES
- MySQL 5.7+ or MariaDB 10.3+
- XAMPP/WAMP/MAMP (recommended for local development)
- 500MB free disk space

### INSTALLATION STEPS

1. **Create Database:**
   ```bash
   mysql -u root -p < 01_create_database.sql

   Create Staging Tables:
   mysql -u root -p library_analytics_dw < 02_create_staging_tables.sql

   Create Dimension Tables:
   mysql -u root -p library_analytics_dw < 03_create_dimension_tables.sql

   Create Fact Tables:
   mysql -u root -p library_analytics_dw < 04_create_fact_tables.sql

   Create Indexes:
   mysql -u root -p library_analytics_dw < 05_create_indexes.sql

   Load Sample Data (Optional):
   mysql -u root -p library_analytics_dw < 06_insert_sample_data.sql
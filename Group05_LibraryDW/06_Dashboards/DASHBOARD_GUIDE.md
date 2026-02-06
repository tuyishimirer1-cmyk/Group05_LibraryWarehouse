# DASHBOARD USER GUIDE
## Library Analytics Data Warehouse

**Document Purpose:** Instructions for using the 3 interactive dashboards  
**Author:** Team Member 3 - Analytics, Reporting & Security Lead  
**Date:** February 3, 2026  
**Version:** 1.0

---

##  TABLE OF CONTENTS

1. [Overview](#overview)
2. [Dashboard 1: Executive Dashboard](#dashboard-1-executive-dashboard)
3. [Dashboard 2: Department Dashboard](#dashboard-2-department-dashboard)
4. [Dashboard 3: Operational Dashboard](#dashboard-3-operational-dashboard)
5. [How to Refresh Data](#how-to-refresh-data)
6. [Troubleshooting](#troubleshooting)
7. [FAQ](#faq)

---

##  OVERVIEW

### What Are These Dashboards?
The Library Analytics Data Warehouse includes **3 interactive Excel dashboards** that visualize library usage data:

1. **Executive Dashboard** - For library directors and senior management
2. **Department Dashboard** - For department heads and academic administrators
3. **Operational Dashboard** - For library staff and day-to-day operations

### Who Should Use Each Dashboard?

| Dashboard | Primary Users | Purpose |
|-----------|--------------|---------|
| **Executive** | Library Director, Senior Management | Strategic planning, high-level KPIs |
| **Department** | Department Heads, Academic Deans | Departmental performance, resource needs |
| **Operational** | Library Staff, Front Desk | Daily operations, real-time monitoring |

### System Requirements
- Microsoft Excel 2016 or newer (or Excel Online)
- OR Google Sheets (import .xlsx files)
- OR Power BI Desktop (optional, for advanced users)

---

##  DASHBOARD 1: EXECUTIVE DASHBOARD

### Purpose
High-level overview of library performance for strategic decision-making.

### Key Metrics (KPI Cards)

#### **Top Row - Summary Cards:**
```
┌──────────────┬──────────────┬──────────────┬──────────────┐
│   Active     │  Book Loans  │   Digital    │    Room      │
│  Students    │              │  Downloads   │  Bookings    │
│     14       │      15      │      14      │      17      │
└──────────────┴──────────────┴──────────────┴──────────────┘
```

**What These Mean:**
- **Active Students:** Unique students who used library services
- **Book Loans:** Total physical books checked out
- **Digital Downloads:** Total digital resources accessed
- **Room Bookings:** Total study room reservations

---

### Visualizations

#### **Chart 1: Monthly Activity Trend (Line Chart)**
**Purpose:** Shows how library usage changes over time

**How to Read:**
- **X-Axis:** Months (January, February, March...)
- **Y-Axis:** Number of activities
- **Lines:** 
  - Blue = Book Loans
  - Orange = Digital Downloads
  - Green = Room Bookings

**Insights to Look For:**
-  **Increasing trend** = Growing engagement
-  **Decreasing trend** = May indicate issues (Spring Break, exams)
-  **Seasonal patterns** = Plan resources accordingly

**Example:**
```
Activities
    │
 20 │     ●────●────●  Book Loans
    │    ╱      ╲    
 15 │   ●        ●───●  Digital
    │  ╱             
 10 │ ●──────────────●  Rooms
    │
    └─────────────────────────
     Jan  Feb  Mar  Apr
```

---

#### **Chart 2: Activity Distribution (Pie Chart)**
**Purpose:** Shows proportion of each activity type

**How to Read:**
- Each slice represents percentage of total activities
- **Expected proportions:**
  - Books: ~33%
  - Digital: ~30%
  - Rooms: ~37%

**Insights to Look For:**
- **Imbalance:** One type dominates (may indicate resource shortage)
- **Shifts over time:** Track month-to-month to see trends

**Example:**
```
      Books
      33% ▓▓▓▓
         ▓▓▓▓▓
   Rooms ░░░░░ Digital
   37%   ░░░░  30%
         ░░░░
```

---

#### **Chart 3: Department Comparison (Horizontal Bar Chart)**
**Purpose:** Compare activity across departments

**How to Read:**
- Longer bars = More activity
- Percentages show share of total usage

**Insights to Look For:**
- **Top performers:** Computer Science, Engineering
- **Underutilizers:** May need targeted outreach
- **Fair distribution:** Ensure resources allocated equitably

**Example:**
```
Computer Science  ████████████████░ 41%
Engineering       ███████████░░░░░░ 33%
Business          ████████░░░░░░░░░ 26%
                  0   10   20   30   40   50
```

---

#### **Chart 4: Weekday vs Weekend (Comparison Bars)**
**Purpose:** Compare usage patterns

**How to Read:**
- Side-by-side bars show weekday vs weekend
- **Expected:** Weekday usage much higher

**Insights to Look For:**
- **Low weekend usage:** Consider weekend hours/staffing
- **High weekend usage:** May need more weekend resources

---

### How to Use This Dashboard

#### **Step 1: Open the File**
```
File location: 06_Dashboards/executive_dashboard.xlsx
Double-click to open in Excel
```

#### **Step 2: Review KPI Cards**
- Look at the top 4 numbers
- Compare to previous month/quarter
- Note any significant changes

#### **Step 3: Analyze Trends**
- Examine the monthly trend line
- Look for upward/downward patterns
- Identify seasonality

#### **Step 4: Check Distribution**
- Review pie chart proportions
- Ensure balanced resource usage
- Note any shifts

#### **Step 5: Compare Departments**
- Review bar chart
- Identify high/low performing departments
- Plan resource allocation

#### **Step 6: Make Decisions**
Based on insights:
-  **Increase book budget** if loans trending up
-  **Add digital resources** if downloads high
-  **Build more study rooms** if bookings at capacity
-  **Target low-usage departments** with marketing

---

### Filters Available
- **Month:** Select specific month to view
- **Department:** Filter by department (optional)

---

##  DASHBOARD 2: DEPARTMENT DASHBOARD

### Purpose
Department-specific performance metrics for academic administrators.

### Key Sections

#### **Section 1: Department Summary Table**
Shows all departments side-by-side:

| Department | Students | Books | Digital | Rooms | Total | Avg/Student |
|-----------|----------|-------|---------|-------|-------|-------------|
| Computer Science | 7 | 6 | 5 | 8 | 19 | 2.7 |
| Engineering | 4 | 5 | 5 | 5 | 15 | 3.8 |
| Business | 3 | 4 | 4 | 4 | 12 | 4.0 |

**How to Read:**
- **Students:** Active students in department
- **Books, Digital, Rooms:** Activity counts by type
- **Total:** Sum of all activities
- **Avg/Student:** Activities per student (engagement metric)

**Insights to Look For:**
- **High Avg/Student:** High engagement
- **Low Avg/Student:** May need intervention

---

#### **Section 2: Monthly Trend (Multi-Line Chart)**
Shows each department's trend over time

**How to Read:**
- Each line represents one department
- Compare slopes to see which departments are growing

**Example:**
```
Activities
    │
 10 │     ●────CS (growing)
    │    ╱  
  8 │   ●────ENG (stable)
    │  ╱═════
  6 │ ●──────BUS (declining)
    │╲      
    └─────────────────
     Jan  Feb  Mar
```

---

#### **Section 3: Resource Preference (Stacked Bar)**
Shows which resources each department prefers

**How to Read:**
- Each bar = one department
- Colors = resource types (Books, Digital, Rooms)

**Insights:**
- **CS:** May prefer digital resources
- **Engineering:** May prefer books
- **All:** Need study rooms

**Example:**
```
CS        ▓▓▓▓░░░░████
          Books Digital Rooms

ENG       ▓▓▓▓▓▓░░░████
          
BUS       ▓▓▓░░░░░████
```

---

#### **Section 4: Top Students Table**
Lists most active students per department

**How to Use:**
- Recognize high performers
- Identify students for library ambassador program
- Track student engagement

---

#### **Section 5: Peak Usage Times (Heat Map)**
Shows when each department uses library most

**How to Read:**
- **Rows:** Departments
- **Columns:** Days of week
- **Colors:** Darker = More activity

**Example:**
```
           Mon Tue Wed Thu Fri Sat Sun
CS         ███ ███ ███ ███ ██  ░   ░
ENG        ██  ███ ██  ███ ███ ░   ░
BUS        ██  ██  ███ ██  ██  █   ░
```

**Insights:**
- **CS:** Heavy Mon-Fri usage
- **BUS:** Some Saturday usage
- **All:** Low Sunday usage

---

### How to Use This Dashboard

#### **Department Head View:**
```
1. Select YOUR department from dropdown
2. View your department's specific metrics
3. Compare to other departments
4. Identify trends in YOUR students' usage
5. Plan resource requests based on data
```

#### **Dean/Administrator View:**
```
1. Leave "All Departments" selected
2. Compare across all departments
3. Identify high/low performers
4. Allocate resources fairly
5. Set departmental goals
```

---

### Filters Available
- **Department:** Select specific department
- **Month:** Select time period
- **Student Level:** Filter by Undergraduate/Graduate

---

##  DASHBOARD 3: OPERATIONAL DASHBOARD

### Purpose
Real-time operational metrics for daily library management.

### Key Sections

#### **Section 1: Today's Activity (KPI Cards)**
Real-time numbers for current day:

```
┌─────────────┬─────────────┬─────────────┬─────────────┐
│   Today's   │   Today's   │   Today's   │   Total     │
│   Books     │   Digital   │   Rooms     │  Students   │
│     3       │      2      │      4      │      6      │
└─────────────┴─────────────┴─────────────┴─────────────┘
```

**How to Use:**
- Check at start of day
- Monitor throughout day
- Compare to yesterday
- Identify unusually high/low activity

---

#### **Section 2: Current Checkouts Table**
Books currently checked out:

| Book Title | Student | Checkout Date | Days Out | Status |
|-----------|---------|---------------|----------|--------|
| Algorithms | STU-001 | 2024-01-15 | 0 | Not Returned |
| Python Programming | STU-003 | 2024-01-10 | 5 | Checked Out |
| Data Structures | STU-005 | 2023-12-15 | 51 | **OVERDUE** |

**Color Coding:**
-  **Green:** Returned on time
-  **Yellow:** Checked out (0-30 days)
-  **Red:** Overdue (>30 days)

**How to Use:**
- **Follow up on overdue books**
- **Send reminder emails**
- **Track which books are out**
- **Plan for returns**

---

#### **Section 3: Room Occupancy Heat Map**
Shows which rooms are busiest at which times:

```
           Morning  Afternoon  Evening  Night
R101         ███       ██        █       ░
R102         ██        ███       ██      ░
R201         █         ██        ███     █
R202         ██        █         ██      ░

Legend: ███ = High  ██ = Medium  █ = Low  ░ = None
```

**How to Use:**
- **Schedule cleaning:** During low-occupancy times
- **Manage conflicts:** Know when rooms are full
- **Plan staffing:** More staff during peak times
- **Capacity planning:** Identify if need more rooms

---

#### **Section 4: Hourly Activity Pattern (Line Chart)**
Shows activity levels throughout the day

**How to Read:**
- **X-Axis:** Time of day (Morning, Afternoon, Evening)
- **Y-Axis:** Number of activities
- **Peak hours:** Usually mid-afternoon

**How to Use:**
- **Staff scheduling:** More staff during peaks
- **Maintenance:** During quiet hours
- **Break scheduling:** Staff breaks during low periods

---

#### **Section 5: Popular Resources This Week**
Top 10 most-used resources this week

**How to Use:**
- **Purchase additional copies** of popular books
- **Feature popular resources** in displays
- **Track trends** over time
- **Marketing:** Promote similar resources

---

#### **Section 6: 7-Day Activity Comparison**
Bar chart comparing last 7 days

**How to Use:**
- **Spot anomalies:** Unusual high/low days
- **Plan ahead:** Predict tomorrow's activity
- **Track trends:** Week-over-week comparison

---

### How to Use This Dashboard

#### **Morning Routine:**
```
1. Open dashboard at start of day
2. Review "Today's Activity" - should start at 0
3. Check "Current Checkouts" for overdues
4. Review "Room Occupancy" for today's bookings
5. Plan staffing based on predicted activity
```

#### **Throughout the Day:**
```
1. Refresh data every hour
2. Monitor "Hourly Activity" to track real-time
3. Address any issues (overdues, room conflicts)
4. Adjust staffing if needed
```

#### **End of Day:**
```
1. Review final numbers
2. Compare to yesterday
3. Note any anomalies
4. Plan for tomorrow
```

---

##  HOW TO REFRESH DATA

### Option 1: Manual Refresh (Excel)

**Step 1: Run Data Extraction Queries**
```sql
-- Open: dashboard_data_extraction.sql in MySQL Workbench
-- Run queries for the dashboard you want to update
-- Export each result to CSV
```

**Step 2: Import New Data**
```
1. Open dashboard Excel file
2. Go to "Data" tab
3. Click "Refresh All" button
4. OR: Click "From Text/CSV" and select new CSV files
5. Replace existing data
6. Click "Close & Load"
```

**Step 3: Verify**
```
- Check that numbers updated
- Verify dates are current
- Ensure charts refreshed
```

---

### Option 2: Automated Refresh (Advanced)

**For IT Staff:**
```bash
# Create scheduled task (Windows) or cron job (Linux)
# to run daily at 2:00 AM

1. Run ETL: python etl_pipeline.py
2. Run dashboard queries: mysql -u root < dashboard_data_extraction.sql
3. Export to CSV: Use MySQL script
4. Auto-import to Excel: Use VBA macro or Python script
```

---

### Refresh Schedule Recommendations

| Dashboard | Refresh Frequency | Why |
|-----------|------------------|-----|
| Executive | Weekly | Strategic decisions don't need daily data |
| Department | Weekly | Departmental trends emerge over weeks |
| Operational | Daily | Operations need current data |

---

##  TROUBLESHOOTING

### Problem 1: Data Not Updating
**Symptoms:** Numbers stay the same after refresh

**Solutions:**
1.  Check if new data loaded to warehouse (run ETL)
2.  Verify query results in MySQL (run extraction queries)
3.  Re-import CSV files manually
4.  Clear Excel cache: Data → Queries & Connections → Delete

---

### Problem 2: Charts Look Wrong
**Symptoms:** Charts show incorrect data or formatting

**Solutions:**
1.  Right-click chart → Select Data → Verify series
2.  Check data range includes new rows
3.  Recreate chart if necessary
4.  Verify CSV import mapped columns correctly

---

### Problem 3: "Cannot Find Data Source"
**Symptoms:** Excel can't find linked CSV files

**Solutions:**
1.  Check CSV files are in correct folder
2.  Update data connections: Data → Edit Links
3.  Browse to new CSV location
4.  OR: Copy CSV contents and paste directly into Excel

---

### Problem 4: Numbers Don't Make Sense
**Symptoms:** KPIs show strange values

**Solutions:**
1.  Verify ETL completed successfully (check etl_log.txt)
2.  Run quick_test.py to verify data warehouse
3.  Check date filters in queries (are you looking at right period?)
4.  Verify calculations in Excel cells (formulas correct?)

---

##  FAQ

### Q1: How often should I refresh the dashboards?
**A:** 
- **Executive:** Weekly (Monday morning)
- **Department:** Weekly (Friday afternoon for weekly review)
- **Operational:** Daily (every morning before library opens)

---

### Q2: Can I add my own charts?
**A:** Yes! Excel dashboards are fully customizable:
1. Run additional queries from business_queries.sql
2. Export to CSV
3. Import to Excel
4. Create new charts
5. Add to dashboard

---

### Q3: Can I filter by date range?
**A:** Yes, two ways:
1. **In SQL:** Modify queries to include WHERE clause for specific dates
2. **In Excel:** Add slicers for date filtering

---

### Q4: How do I share dashboards with others?
**A:**
- **Option 1:** Email Excel file (they can open in Excel or Google Sheets)
- **Option 2:** Upload to SharePoint/Google Drive for collaboration
- **Option 3:** Export to PDF for static sharing
- **Option 4:** Publish to Power BI Service (requires Power BI)

---

### Q5: What if I need a custom dashboard?
**A:** Contact IT or Data Analytics team:
- Email: data-analytics@university.edu
- Provide: What metrics you need and who will use it
- Timeline: Custom dashboards take 1-2 weeks

---

### Q6: Can I access dashboards on mobile?
**A:**
- **Excel:** Use Excel mobile app (iOS/Android)
- **Power BI:** Power BI mobile app has better mobile experience
- **Google Sheets:** Works in mobile browser

---

##  SUPPORT CONTACTS

| Issue Type | Contact | Email | Phone |
|-----------|---------|-------|-------|
| Dashboard bugs/errors | Data Analytics Team | analytics@university.edu | Ext. 5504 |
| Data accuracy questions | Database Administrator | dba@university.edu | Ext. 5502 |
| Access/permissions | IT Support Desk | support@university.edu | Ext. 5500 |
| Feature requests | Data Analytics Lead | lead-analytics@university.edu | Ext. 5505 |

---

##  ADDITIONAL RESOURCES

- **Data Dictionary:** See `/03_Database_Files/README.md`
- **SQL Query Guide:** See `/05_Analytics_Package/business_queries.sql`
- **OLAP Operations:** See `/05_Analytics_Package/olap_operations_demo.pdf`
- **Video Tutorials:** [Internal Wiki - Library Dashboards]

---

##  CHANGELOG
| Version | Date | Changes |
|---------|------|---------|
| 1.0 | 2026-02-03 | Initial dashboard guide |

---

**End of Dashboard User Guide**

import pandas as pd
from sqlalchemy import create_engine
import os

# --------------------------
# Database config
# --------------------------
DB_CONFIG = {
    'user': 'root',
    'password': '',  # Your MySQL password
    'host': '127.0.0.1',
    'database': 'library_analytics_dw',
    'port': 3306
}

# --------------------------
# Output folder
# --------------------------
OUTPUT_FOLDER = os.path.expanduser(r"~\Documents\LibraryDW_Reports")
os.makedirs(OUTPUT_FOLDER, exist_ok=True)

# --------------------------
# Create database engine
# --------------------------
engine = create_engine(
    f"mysql+pymysql://{DB_CONFIG['user']}:{DB_CONFIG['password']}@"
    f"{DB_CONFIG['host']}:{DB_CONFIG['port']}/{DB_CONFIG['database']}"
)

# --------------------------
# Test database connection
# --------------------------
try:
    with engine.connect() as conn:
        print("[OK] Connected to database")
except Exception as e:
    print("[ERROR] Database connection failed:", e)
    exit(1)

# --------------------------
# OLAP Queries
# --------------------------
queries = {

  # Q1: Drill-Down (Year → Quarter → Month → Day)
"Q1_DrillDown_Year_Quarter_Month_Day": """
    SELECT
        d.year,
        d.quarter,
        d.month_name,
        DAY(d.full_date) AS day,           -- Added day column
        d.full_date,
        COALESCE(SUM(f.loan_count + f.download_count + f.booking_count), 0) AS total_usage
    FROM dim_date d
    LEFT JOIN fact_library_usage f 
        ON f.date_key = d.date_key
    GROUP BY 
        d.year, d.quarter, d.month_name, d.full_date
    ORDER BY 
        d.year, d.quarter, MONTH(d.full_date), DAY(d.full_date);
""",
   # Q2: Roll-Up (Day-level detail)
"Q2_RollUp_Day_Week_Month": """
    SELECT
        d.year,
        d.month_name,
        DAY(d.full_date) AS day,             -- Added day column
        COALESCE(SUM(f.loan_count + f.download_count + f.booking_count), 0) AS total_usage
    FROM dim_date d
    LEFT JOIN fact_library_usage f 
        ON f.date_key = d.date_key
    GROUP BY 
        d.year, d.month_name, d.full_date
    ORDER BY 
        d.year, MONTH(d.full_date), DAY(d.full_date);
""",


    # Q3: Slice (Engineering – March 2024)
    "Q3_Slice_Engineering_March2024": """
        SELECT
            s.department_standardized AS department,
            d.month_name,
            COALESCE(SUM(f.loan_count),0) AS total_loans,
            COALESCE(SUM(f.download_count),0) AS total_downloads
        FROM dim_date d
        LEFT JOIN fact_library_usage f 
            ON f.date_key = d.date_key
        LEFT JOIN dim_student s 
            ON f.student_key = s.student_key
        WHERE 
            s.department_standardized = 'Engineering'
            AND d.month = 3 
            AND d.year = 2024
        GROUP BY 
            s.department_standardized, d.month_name;
    """,

    # Q4: Dice (Engineering & CS – All Resource Types – March)
    "Q4_Dice_Engineering_CS_Digital_March": """
        WITH depts AS (
            SELECT DISTINCT department_standardized
            FROM dim_student
            WHERE department_standardized IN ('Engineering','Computer Science')
        ),
        res AS (
            SELECT DISTINCT resource_type
            FROM dim_resource
        ),
        dates AS (
            SELECT DISTINCT month_name
            FROM dim_date
            WHERE month = 3 AND year = 2024
        ),
        combos AS (
            SELECT 
                d.month_name, 
                dept.department_standardized AS department, 
                r.resource_type
            FROM depts dept
            CROSS JOIN res r
            CROSS JOIN dates d
        )
        SELECT
            c.department,
            c.resource_type,
            c.month_name,
            COALESCE(SUM(f.download_count),0) AS total_downloads
        FROM combos c
        LEFT JOIN fact_library_usage f
            ON f.student_key IN (
                SELECT student_key 
                FROM dim_student 
                WHERE department_standardized = c.department
            )
            AND f.resource_key IN (
                SELECT resource_key 
                FROM dim_resource 
                WHERE resource_type = c.resource_type
            )
            AND f.date_key IN (
                SELECT date_key 
                FROM dim_date 
                WHERE month = 3 AND year = 2024
            )
        GROUP BY 
            c.department, c.resource_type, c.month_name
        ORDER BY 
            c.department, c.resource_type;
    """,

    # Q5: Pivot (Resource Type by Department)
    "Q5_Pivot_Resource_Department": """
        SELECT
            s.department_standardized AS department,
            r.resource_type,
            COALESCE(SUM(f.loan_count),0) AS total_loans
        FROM dim_student s
        LEFT JOIN fact_library_usage f 
            ON f.student_key = s.student_key
        LEFT JOIN dim_resource r 
            ON f.resource_key = r.resource_key
        GROUP BY 
            s.department_standardized, r.resource_type
        ORDER BY 
            s.department_standardized;
    """,

    # Q6: Monthly Loan Summary
    "Q6_Total_Loans_Per_Month": """
        SELECT
            d.year,
            d.month_name,
            COALESCE(SUM(f.loan_count),0) AS total_loans,
            COALESCE(COUNT(DISTINCT f.student_key),0) AS unique_borrowers
        FROM dim_date d
        LEFT JOIN fact_library_usage f 
            ON f.date_key = d.date_key
        GROUP BY 
            d.year, d.month_name
        ORDER BY 
            d.year, MONTH(d.full_date);
    """,

    # Q7: Top 10 Borrowed Books
    "Q7_Top_10_Books": """
        SELECT
            r.resource_id AS isbn,
            r.title AS book_title,
            r.category,
            COALESCE(SUM(f.loan_count),0) AS total_borrows,
            COALESCE(AVG(f.loan_duration_days),0) AS avg_loan_days
        FROM dim_resource r
        LEFT JOIN fact_library_usage f 
            ON f.resource_key = r.resource_key
        GROUP BY 
            r.resource_key, r.title, r.category
        ORDER BY 
            total_borrows DESC
        LIMIT 10;
    """,

    # Q8: Department Usage Summary
    "Q8_Department_Usage": """
        SELECT
            s.department_standardized AS department,
            COALESCE(SUM(f.loan_count),0) AS total_loans,
            COALESCE(SUM(f.download_count),0) AS total_downloads,
            COALESCE(SUM(f.booking_count),0) AS total_bookings,
            COALESCE(COUNT(DISTINCT s.student_key),0) AS active_students
        FROM dim_student s
        LEFT JOIN fact_library_usage f 
            ON f.student_key = s.student_key
        GROUP BY 
            s.department_standardized
        ORDER BY 
            total_loans DESC;
    """,

    # Q9: Weekly Digital Trend
    "Q9_Digital_Weekly_Trend": """
        SELECT
            d.year,
            WEEK(d.full_date,1) AS week_number,
            COALESCE(r.resource_type,'Unknown') AS resource_type,
            COALESCE(SUM(f.download_count),0) AS total_downloads,
            COALESCE(AVG(f.download_duration_minutes),0) AS avg_session_min
        FROM dim_date d
        LEFT JOIN fact_library_usage f 
            ON f.date_key = d.date_key
        LEFT JOIN dim_resource r 
            ON f.resource_key = r.resource_key
        WHERE 
            f.source_system = 'DIGITAL' OR f.source_system IS NULL
        GROUP BY 
            d.year, WEEK(d.full_date,1), r.resource_type
        ORDER BY 
            d.year, week_number;
    """
    
}

# --------------------------
# Execute Queries & Save Files
# --------------------------
for name, sql in queries.items():
    print(f"\nRunning {name}...")

    try:
        df = pd.read_sql(sql, engine)
        print(df.head(5))

        file_path = os.path.join(OUTPUT_FOLDER, f"{name}.xlsx")
        df.to_excel(file_path, index=False)

        print(f"[OK] {name} saved to {file_path}")

    except Exception as e:
        print(f"[ERROR] {name} failed:", e)

print("\nAll queries executed successfully!")


"""
Library Analytics DW - COMPLETE ETL Pipeline
FINAL WORKING VERSION

This ETL loads data from staging tables into the data warehouse.
It handles multiple date formats and ensures data quality.

Usage:
    python etl_pipeline.py

Output:
    - Loads all dimension tables
    - Loads fact_library_usage table
    - Creates etl_log.txt with detailed logs
"""

import pandas as pd
import pymysql
from pymysql import Error
import numpy as np
from datetime import datetime, timedelta
import logging
import os
import sys
import time

# ==============================
# CONFIGURATION
# ==============================
class Config:
    DB_CONFIG = {
        'host': '127.0.0.1',
        'user': 'root',
        'password': '',
        'database': 'library_analytics_dw',
        'connect_timeout': 10
    }
    
    SOURCE_FILES = {
        'book_transactions': '../09_Source_Data/book_transactions.csv',
        'digital_usage': '../09_Source_Data/digital_usage.xlsx',
        'room_bookings': '../09_Source_Data/room_bookings.csv'
    }
    
    LOG_FILE = 'etl_log.txt'

# ==============================
# LOGGING SETUP
# ==============================
def setup_logging():
    """Setup logging with UTF-8 encoding"""
    # Clear existing handlers
    for handler in logging.root.handlers[:]:
        logging.root.removeHandler(handler)
    
    file_handler = logging.FileHandler(Config.LOG_FILE, encoding='utf-8', mode='w')
    file_handler.setLevel(logging.INFO)
    
    console_handler = logging.StreamHandler(sys.stdout)
    console_handler.setLevel(logging.INFO)
    
    formatter = logging.Formatter('%(asctime)s - %(levelname)s - %(message)s')
    file_handler.setFormatter(formatter)
    console_handler.setFormatter(formatter)
    
    logger = logging.getLogger(__name__)
    logger.setLevel(logging.INFO)
    logger.addHandler(file_handler)
    logger.addHandler(console_handler)
    
    return logger

logger = setup_logging()

# ==============================
# UTILITY FUNCTIONS
# ==============================
def get_db_connection():
    """Create database connection"""
    try:
        conn = pymysql.connect(**Config.DB_CONFIG)
        return conn
    except Error as e:
        logger.error(f"Database connection failed: {e}")
        raise

def safe_delete(conn, table_name):
    """Delete all records from table (safer than truncate with foreign keys)"""
    cursor = conn.cursor()
    try:
        cursor.execute(f"DELETE FROM {table_name}")
        conn.commit()
        logger.info(f"  Cleared {table_name}")
    except Exception as e:
        logger.warning(f"  Failed to clear {table_name}: {e}")
    finally:
        cursor.close()

def parse_date(date_str):
    """Parse date string using Python (handles multiple formats)"""
    if not date_str or str(date_str).strip() == '' or str(date_str) == 'None':
        return None
    
    date_formats = [
        '%Y-%m-%d',      # 2024-01-15
        '%m/%d/%Y',      # 01/16/2024
        '%b %d, %Y',     # Jan 15, 2024
        '%d-%b-%Y',      # 15-Mar-2024
    ]
    
    for fmt in date_formats:
        try:
            return datetime.strptime(str(date_str), fmt).date()
        except:
            continue
    
    logger.warning(f"Could not parse date: {date_str}")
    return None

# ==============================
# DIMENSION TABLE LOADING
# ==============================
def load_dim_date(conn):
    """Load date dimension using Python date parsing"""
    logger.info("Loading dim_date...")
    
    cursor = conn.cursor()
    safe_delete(conn, 'dim_date')
    
    # Read all date strings from staging tables
    all_dates = set()
    
    # From book transactions
    cursor.execute("SELECT CheckoutDate, ReturnDate FROM staging_book_transactions WHERE CheckoutDate IS NOT NULL")
    for checkout, return_date in cursor.fetchall():
        parsed = parse_date(checkout)
        if parsed:
            all_dates.add(parsed)
        if return_date:
            parsed = parse_date(return_date)
            if parsed:
                all_dates.add(parsed)
    
    # From digital usage
    cursor.execute("SELECT Date FROM staging_digital_usage WHERE Date IS NOT NULL")
    for (date_str,) in cursor.fetchall():
        parsed = parse_date(date_str)
        if parsed:
            all_dates.add(parsed)
    
    # From room bookings
    cursor.execute("SELECT BookingDate FROM staging_room_bookings WHERE BookingDate IS NOT NULL")
    for (date_str,) in cursor.fetchall():
        parsed = parse_date(date_str)
        if parsed:
            all_dates.add(parsed)
    
    if not all_dates:
        logger.warning("No valid dates found in staging tables")
        cursor.close()
        return 0
    
    min_date = min(all_dates)
    max_date = max(all_dates)
    logger.info(f"  Date range: {min_date} to {max_date}")
    
    # Insert all dates in range
    insert_query = """
    INSERT INTO dim_date 
    (date_key, full_date, day, month, month_name, quarter, quarter_name, 
     year, day_of_week, is_weekend, is_holiday)
    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """
    
    current_date = min_date
    rows_inserted = 0
    
    while current_date <= max_date:
        date_key = int(current_date.strftime('%Y%m%d'))
        day = current_date.day
        month = current_date.month
        year = current_date.year
        quarter = (month - 1) // 3 + 1
        day_of_week = current_date.strftime('%A')
        is_weekend = 1 if current_date.weekday() >= 5 else 0
        month_name = current_date.strftime('%B')
        quarter_name = f"Q{quarter}"
        
        try:
            cursor.execute(insert_query, (
                date_key, current_date, day, month, month_name,
                quarter, quarter_name, year, day_of_week, is_weekend, 0
            ))
            rows_inserted += 1
        except Exception as e:
            logger.warning(f"  Failed to insert date {current_date}: {e}")
        
        current_date = current_date + timedelta(days=1)
    
    conn.commit()
    cursor.close()
    logger.info(f"[OK] Loaded {rows_inserted} dates")
    return rows_inserted

def load_dim_student(conn):
    """Load student dimension with department name standardization"""
    logger.info("Loading dim_student...")
    
    cursor = conn.cursor()
    safe_delete(conn, 'dim_student')
    
    # Department name standardization mapping
    dept_mapping = {
        'CS': 'Computer Science',
        'CompSci': 'Computer Science',
        'Computer Science': 'Computer Science',
        'ENG': 'Engineering',
        'Engineering': 'Engineering',
        'BUS': 'Business',
        'Business': 'Business',
        'Unknown': 'Unknown'
    }
    
    # Get unique students with their departments
    insert_query = """
    INSERT INTO dim_student 
    (student_id, department_standardized, student_level, is_active)
    SELECT 
        StudentID,
        COALESCE(MAX(Department), 'Unknown') as department_standardized,
        'Undergraduate' as student_level,
        1 as is_active
    FROM (
        SELECT StudentID, Department FROM staging_book_transactions WHERE StudentID IS NOT NULL
        UNION ALL
        SELECT StudentID, NULL as Department FROM staging_room_bookings WHERE StudentID IS NOT NULL
    ) AS all_students
    WHERE StudentID IS NOT NULL AND StudentID != ''
    GROUP BY StudentID
    """
    
    try:
        cursor.execute(insert_query)
        conn.commit()
        
        # Now standardize department names
        logger.info("  Standardizing department names...")
        
        # Get all students with their current departments
        cursor.execute("SELECT student_key, department_standardized FROM dim_student")
        students = cursor.fetchall()
        
        standardized_count = 0
        for student_key, dept in students:
            # Standardize department name
            standardized_dept = dept_mapping.get(dept, dept)
            
            if standardized_dept != dept:
                cursor.execute(
                    "UPDATE dim_student SET department_standardized = %s WHERE student_key = %s",
                    (standardized_dept, student_key)
                )
                standardized_count += 1
        
        conn.commit()
        
        if standardized_count > 0:
            logger.info(f"  Standardized {standardized_count} department names")
        
        cursor.execute("SELECT COUNT(*) FROM dim_student")
        count = cursor.fetchone()[0]
        
        cursor.close()
        logger.info(f"[OK] Loaded {count} students")
        return count
    except Exception as e:
        logger.error(f"Failed to load dim_student: {e}")
        cursor.close()
        raise

def load_dim_resource(conn):
    """Load resource dimension"""
    logger.info("Loading dim_resource...")
    
    cursor = conn.cursor()
    safe_delete(conn, 'dim_resource')
    
    insert_query = """
    INSERT INTO dim_resource 
    (resource_id, resource_type, category, title, is_digital)
    VALUES (%s, %s, %s, %s, %s)
    """
    
    rows_inserted = 0
    
    # Insert dummy "Unknown" resource first
    cursor.execute(insert_query, ('UNKNOWN', 'Unknown', 'Unknown', 'Unknown Resource', 0))
    rows_inserted += 1
    
    # Add books from book_transactions
    cursor.execute("""
        SELECT DISTINCT BookISBN, BookCategory
        FROM staging_book_transactions
        WHERE BookISBN IS NOT NULL AND BookISBN != ''
    """)
    books = cursor.fetchall()
    
    for isbn, category in books:
        try:
            cursor.execute(insert_query, (
                isbn, 'Physical Book', category if category else 'General',
                f"Book {isbn}", 0
            ))
            rows_inserted += 1
        except Exception as e:
            logger.warning(f"  Failed to insert book {isbn}: {e}")
    
    # Add digital resources
    cursor.execute("""
        SELECT DISTINCT ResourceType
        FROM staging_digital_usage
        WHERE ResourceType IS NOT NULL AND ResourceType != ''
    """)
    resources = cursor.fetchall()
    
    for idx, (res_type,) in enumerate(resources, 1):
        try:
            cursor.execute(insert_query, (
                f"DIG-{idx:03d}", res_type, 'Digital',
                f"{res_type} Resource", 1
            ))
            rows_inserted += 1
        except Exception as e:
            logger.warning(f"  Failed to insert resource {res_type}: {e}")
    
    conn.commit()
    cursor.close()
    logger.info(f"[OK] Loaded {rows_inserted} resources")
    return rows_inserted

def load_dim_location(conn):
    """Load location dimension with room number standardization"""
    logger.info("Loading dim_location...")
    
    cursor = conn.cursor()
    safe_delete(conn, 'dim_location')
    
    insert_query = """
    INSERT INTO dim_location 
    (room_number_standardized, room_type, building, capacity)
    VALUES (%s, %s, %s, %s)
    """
    
    def standardize_room_number(room_num):
        """Standardize room number format to R### (e.g., R101, R102)"""
        import re
        
        # Remove spaces and convert to uppercase
        room_num = str(room_num).strip().upper()
        
        # Extract numbers from room string
        numbers = re.findall(r'\d+', room_num)
        
        if numbers:
            # Get first number found
            room_id = numbers[0]
            # Pad to 3 digits (101 -> 101, 1 -> 001)
            room_id = room_id.zfill(3)
            # Return as R###
            return f"R{room_id}"
        
        # If no numbers found, return as-is
        return room_num
    
    rows_inserted = 0
    
    # Insert dummy "Unknown" location first
    cursor.execute(insert_query, ('UNKNOWN', 'Unknown', 'Unknown', 0))
    rows_inserted += 1
    
    cursor.execute("""
        SELECT DISTINCT RoomNumber 
        FROM staging_room_bookings
        WHERE RoomNumber IS NOT NULL AND RoomNumber != ''
    """)
    rooms = cursor.fetchall()
    
    logger.info("  Standardizing room numbers...")
    standardized_count = 0
    
    for (room_num,) in rooms:
        try:
            standardized = standardize_room_number(room_num)
            
            if standardized != room_num:
                logger.info(f"  Standardized: '{room_num}' → '{standardized}'")
                standardized_count += 1
            
            cursor.execute(insert_query, (
                standardized, 'Study Room', 'Main Library', 10
            ))
            rows_inserted += 1
        except Exception as e:
            logger.warning(f"  Failed to insert room {room_num}: {e}")
    
    if standardized_count > 0:
        logger.info(f"  Standardized {standardized_count} room numbers")
    
    conn.commit()
    cursor.close()
    logger.info(f"[OK] Loaded {rows_inserted} locations")
    return rows_inserted

def load_dim_time_slot(conn):
    """Load time slot dimension with standardization"""
    logger.info("Loading dim_time_slot...")
    
    cursor = conn.cursor()
    safe_delete(conn, 'dim_time_slot')
    
    insert_query = """
    INSERT INTO dim_time_slot 
    (time_slot_standardized, start_time, end_time)
    VALUES (%s, %s, %s)
    """
    
    def standardize_time_slot(slot):
        """Standardize time slot format"""
        import re
        
        slot_str = str(slot).strip()
        
        # Mapping for text-based time slots
        text_mapping = {
            'MORNING': ('Morning', '08:00:00', '12:00:00'),
            'AFTERNOON': ('Afternoon', '12:00:00', '17:00:00'),
            'EVENING': ('Evening', '17:00:00', '21:00:00'),
            'NIGHT': ('Night', '21:00:00', '23:00:00'),
        }
        
        # Check if it's a text-based slot
        slot_upper = slot_str.upper()
        if slot_upper in text_mapping:
            return text_mapping[slot_upper]
        
        # Parse time ranges with dash (e.g., "8AM-10AM" or "09:00-10:00")
        if '-' in slot_str:
            parts = slot_str.split('-')
            if len(parts) == 2:
                start = parts[0].strip()
                end = parts[1].strip()
                
                # Convert 12-hour format to 24-hour
                start_24 = convert_to_24hour(start)
                end_24 = convert_to_24hour(end)
                
                # Create standardized label
                if 'AM' in slot_str.upper() or 'PM' in slot_str.upper():
                    # Keep original format for display
                    standardized_label = slot_str
                else:
                    # Already 24-hour format
                    standardized_label = f"{start_24[:5]}-{end_24[:5]}"
                
                return (standardized_label, start_24, end_24)
        
        # If can't parse, return as-is with default times
        return (slot_str, '00:00:00', '00:00:00')
    
    def convert_to_24hour(time_str):
        """Convert 12-hour time to 24-hour format"""
        import re
        
        time_str = time_str.strip().upper()
        
        # Already in 24-hour format (HH:MM or HH:MM:SS)
        if ':' in time_str and 'AM' not in time_str and 'PM' not in time_str:
            if len(time_str.split(':')) == 2:
                return time_str + ':00'  # Add seconds
            return time_str
        
        # Extract hour and determine AM/PM
        match = re.match(r'(\d+)\s*(AM|PM)', time_str)
        if match:
            hour = int(match.group(1))
            period = match.group(2)
            
            if period == 'PM' and hour != 12:
                hour += 12
            elif period == 'AM' and hour == 12:
                hour = 0
            
            return f"{hour:02d}:00:00"
        
        # Default if can't parse
        return '00:00:00'
    
    rows_inserted = 0
    
    # Insert dummy "Unknown" time slot first
    cursor.execute(insert_query, ('UNKNOWN', '00:00:00', '00:00:00'))
    rows_inserted += 1
    
    cursor.execute("""
        SELECT DISTINCT TimeSlot
        FROM staging_room_bookings
        WHERE TimeSlot IS NOT NULL AND TimeSlot != ''
    """)
    slots = cursor.fetchall()
    
    logger.info("  Standardizing time slots...")
    standardized_count = 0
    
    for (slot,) in slots:
        try:
            standardized_label, start_time, end_time = standardize_time_slot(slot)
            
            if str(slot) != standardized_label or start_time != '00:00:00':
                logger.info(f"  Standardized: '{slot}' → '{standardized_label}' ({start_time} - {end_time})")
                standardized_count += 1
            
            cursor.execute(insert_query, (standardized_label, start_time, end_time))
            rows_inserted += 1
        except Exception as e:
            logger.warning(f"  Failed to insert time slot {slot}: {e}")
    
    if standardized_count > 0:
        logger.info(f"  Standardized {standardized_count} time slots")
    
    conn.commit()
    cursor.close()
    logger.info(f"[OK] Loaded {rows_inserted} time slots")
    return rows_inserted

# ==============================
# FACT TABLE LOADING
# ==============================
def load_fact_library_usage(conn):
    """Load fact table using Python date parsing"""
    logger.info("Loading fact_library_usage...")
    
    cursor = conn.cursor()
    safe_delete(conn, 'fact_library_usage')
    
    # Get unknown keys
    cursor.execute("SELECT location_key FROM dim_location WHERE room_number_standardized = 'UNKNOWN'")
    unknown_location = cursor.fetchone()[0]
    
    cursor.execute("SELECT resource_key FROM dim_resource WHERE resource_id = 'UNKNOWN'")
    unknown_resource = cursor.fetchone()[0]
    
    cursor.execute("SELECT time_slot_key FROM dim_time_slot WHERE time_slot_standardized = 'UNKNOWN'")
    unknown_timeslot = cursor.fetchone()[0]
    
    total_inserted = 0
    
    insert_query = """
    INSERT INTO fact_library_usage 
    (date_key, student_key, resource_key, location_key, time_slot_key,
     loan_count, download_count, booking_count, loan_duration_days, 
     download_duration_minutes, booking_duration_hours, 
     source_system, original_transaction_id)
    VALUES (%s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s, %s)
    """
    
    # 1. Load book transactions
    logger.info("  Loading book transactions...")
    cursor.execute("""
        SELECT bt.TransactionID, bt.StudentID, bt.BookISBN, bt.CheckoutDate, bt.ReturnDate,
               s.student_key, r.resource_key
        FROM staging_book_transactions bt
        INNER JOIN dim_student s ON bt.StudentID = s.student_id
        INNER JOIN dim_resource r ON bt.BookISBN = r.resource_id
        WHERE bt.StudentID IS NOT NULL 
          AND bt.CheckoutDate IS NOT NULL
          AND bt.BookISBN IS NOT NULL
    """)
    
    book_count = 0
    for row in cursor.fetchall():
        trans_id, student_id, isbn, checkout_date, return_date, student_key, resource_key = row
        
        checkout_parsed = parse_date(checkout_date)
        if not checkout_parsed:
            continue
        
        date_key = int(checkout_parsed.strftime('%Y%m%d'))
        
        # Calculate duration
        duration = 0
        if return_date:
            return_parsed = parse_date(return_date)
            if return_parsed:
                duration = (return_parsed - checkout_parsed).days
        
        try:
            cursor.execute(insert_query, (
                date_key, student_key, resource_key, unknown_location, unknown_timeslot,
                1, 0, 0, duration, None, None, 'BOOK', str(trans_id)
            ))
            book_count += 1
        except Exception as e:
            logger.warning(f"  Failed to insert book transaction {trans_id}: {e}")
    
    conn.commit()
    total_inserted += book_count
    logger.info(f"  [OK] Loaded {book_count} book records")
    
    # 2. Load digital usage
    logger.info("  Loading digital usage...")
    cursor.execute("""
        SELECT du.Date, du.UserType, du.ResourceType, du.DownloadCount, du.Duration_Minutes,
               r.resource_key
        FROM staging_digital_usage du
        INNER JOIN dim_resource r ON du.ResourceType = r.resource_type AND r.is_digital = 1
        WHERE du.Date IS NOT NULL 
          AND du.ResourceType IS NOT NULL
    """)
    
    digital_count = 0
    for row in cursor.fetchall():
        date_str, user_type, resource_type, download_count, duration_min, resource_key = row
        
        date_parsed = parse_date(date_str)
        if not date_parsed:
            continue
        
        date_key = int(date_parsed.strftime('%Y%m%d'))
        
        try:
            cursor.execute(insert_query, (
                date_key, None, resource_key, unknown_location, unknown_timeslot,
                0, download_count or 0, 0, None, duration_min, None, 
                'DIGITAL', f"{date_str}-{resource_type}-{user_type}"
            ))
            digital_count += 1
        except Exception as e:
            logger.warning(f"  Failed to insert digital usage: {e}")
    
    conn.commit()
    total_inserted += digital_count
    logger.info(f"  [OK] Loaded {digital_count} digital records")
    
    # 3. Load room bookings
    logger.info("  Loading room bookings...")
    cursor.execute("""
        SELECT rb.BookingID, rb.StudentID, rb.BookingDate, rb.RoomNumber, rb.TimeSlot, rb.DurationHours,
               s.student_key, l.location_key, t.time_slot_key
        FROM staging_room_bookings rb
        INNER JOIN dim_student s ON rb.StudentID = s.student_id
        INNER JOIN dim_location l ON rb.RoomNumber = l.room_number_standardized
        INNER JOIN dim_time_slot t ON rb.TimeSlot = t.time_slot_standardized
        WHERE rb.StudentID IS NOT NULL 
          AND rb.BookingDate IS NOT NULL
          AND rb.RoomNumber IS NOT NULL
          AND rb.TimeSlot IS NOT NULL
    """)
    
    room_count = 0
    for row in cursor.fetchall():
        booking_id, student_id, booking_date, room_num, time_slot, duration_hrs, \
            student_key, location_key, timeslot_key = row
        
        date_parsed = parse_date(booking_date)
        if not date_parsed:
            continue
        
        date_key = int(date_parsed.strftime('%Y%m%d'))
        
        try:
            cursor.execute(insert_query, (
                date_key, student_key, unknown_resource, location_key, timeslot_key,
                0, 0, 1, None, None, duration_hrs, 'ROOM', str(booking_id)
            ))
            room_count += 1
        except Exception as e:
            logger.warning(f"  Failed to insert room booking {booking_id}: {e}")
    
    conn.commit()
    total_inserted += room_count
    logger.info(f"  [OK] Loaded {room_count} room records")
    
    cursor.close()
    logger.info(f"[OK] Total fact records: {total_inserted}")
    return total_inserted

# ==============================
# MAIN ETL PIPELINE
# ==============================
def run_full_etl():
    """Run complete ETL pipeline"""
    start_time = time.time()
    
    print("="*60)
    print("LIBRARY ANALYTICS DW - FULL ETL PIPELINE")
    print("="*60)
    
    try:
        # Connect
        logger.info("Connecting to database...")
        conn = get_db_connection()
        logger.info("[OK] Connected")
        
        # Verify staging data exists
        logger.info("\nVerifying staging data...")
        cursor = conn.cursor()
        cursor.execute("SELECT COUNT(*) FROM staging_book_transactions")
        bt_count = cursor.fetchone()[0]
        cursor.execute("SELECT COUNT(*) FROM staging_digital_usage")
        du_count = cursor.fetchone()[0]
        cursor.execute("SELECT COUNT(*) FROM staging_room_bookings")
        rb_count = cursor.fetchone()[0]
        cursor.close()
        
        logger.info(f"  staging_book_transactions: {bt_count} rows")
        logger.info(f"  staging_digital_usage: {du_count} rows")
        logger.info(f"  staging_room_bookings: {rb_count} rows")
        
        if bt_count == 0 and du_count == 0 and rb_count == 0:
            logger.error("No data in staging tables!")
            logger.info("Load data into staging tables first")
            return False
        
        # Clear existing data (fact first due to foreign keys)
        logger.info("\nClearing existing data...")
        safe_delete(conn, 'fact_library_usage')
        
        # Load dimensions (order matters for foreign keys in fact table)
        logger.info("\nLoading dimension tables...")
        load_dim_date(conn)          # Must load first (date_key needed)
        load_dim_student(conn)       # Must load before fact
        load_dim_resource(conn)      # Must load before fact
        load_dim_location(conn)      # Must load before fact
        load_dim_time_slot(conn)     # Must load before fact
        
        # Load fact table
        logger.info("\nLoading fact table...")
        load_fact_library_usage(conn)
        
        conn.close()
        
        elapsed = time.time() - start_time
        logger.info("\n" + "="*60)
        logger.info(f"[SUCCESS] ETL completed in {elapsed:.2f} seconds")
        logger.info("="*60)
        
        return True
        
    except Exception as e:
        logger.error(f"\n[FAILED] ETL error: {e}")
        import traceback
        traceback.print_exc()
        return False

# ==============================
# MAIN
# ==============================
if __name__ == "__main__":
    print("\nLibrary Analytics DW - ETL Pipeline")
    print("Starting ETL process...\n")
    
    success = run_full_etl()
    
    if success:
        print("\n" + "="*60)
        print("ETL COMPLETED SUCCESSFULLY!")
        print("="*60)
        print("\nRun 'python quick_test.py' to verify the results")
        print("Check 'etl_log.txt' for detailed logs")
    else:
        print("\n" + "="*60)
        print("ETL FAILED - Check logs above for details")
        print("="*60)
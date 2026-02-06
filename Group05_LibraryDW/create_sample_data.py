#!/usr/bin/env python3
"""
Create sample source data files for Library Analytics Project
"""

import pandas as pd
import os

def create_book_transactions():
    """Create book_transactions.csv with data quality issues"""
    data = [
        # TransactionID, StudentID, BookISBN, CheckoutDate, ReturnDate, Department, BookCategory
        [1001, 'STU-2024-001', '978-0134685991', '2024-01-15', '2024-01-29', 'CS', 'Textbook'],
        [1002, 'STU-2024-002', '978-0133970777', '2024-01-15', '', 'Computer Science', 'Textbook'],
        [1003, 'STU-2024-003', '978-0262033848', '01/16/2024', '02/06/2024', 'CompSci', 'Textbook'],
        [1004, 'STU-2024-004', '978-1982100551', '2024-02-01', '2024-02-10', 'ENG', 'Fiction'],
        [1005, 'STU-2024-005', '978-1234567890', '2024-02-05', '2024-02-12', 'Engineering', 'Reference'],
        [1006, 'STU-2024-006', '978-0451524935', '2024-02-10', '2024-02-20', 'BUS', 'Fiction'],
        [1007, 'STU-2024-007', '978-0141439518', '2024-02-15', '', 'Business', 'Literature'],
        [1008, 'STU-2024-001', '978-0134685991', '2024-03-01', '2024-03-15', 'CS', 'Textbook'],
        [1009, 'STU-2024-008', '978-0590353403', '2024-03-05', '2024-03-12', 'CS', 'Fiction'],
        [1010, 'STU-2024-009', '978-0439064873', '2024-03-10', '', 'CompSci', 'Fiction'],
        [1011, 'FAC-2024-001', '978-0133970777', '2024-01-04', '2024-02-03', 'CS', 'Textbook'],
        [1012, 'FAC-2024-002', '978-0262033848', '2024-02-01', '2024-03-01', 'ENG', 'Textbook'],
        [1013, 'STU-2024-010', '978-0743273565', '2024-03-15', '2024-03-22', 'BUS', 'Biography'],
        [1014, 'STU-2024-011', '978-0316769174', '2024-03-20', '', 'ENG', 'Literature'],
        [1015, 'STU-2024-012', '978-0451524935', '2024-03-25', '2024-04-01', 'Business', 'Fiction']
    ]
    
    df = pd.DataFrame(data, columns=[
        'TransactionID', 'StudentID', 'BookISBN', 'CheckoutDate', 
        'ReturnDate', 'Department', 'BookCategory'
    ])
    
    os.makedirs('09_Source_Data', exist_ok=True)
    df.to_csv('09_Source_Data/book_transactions.csv', index=False)
    print(f"Created book_transactions.csv with {len(df)} records")
    
    # Show data quality issues
    print("\nData Quality Issues in Book Transactions:")
    print("1. Inconsistent department names: CS, Computer Science, CompSci")
    print("2. Multiple date formats: 2024-01-15, 01/16/2024")
    print("3. Missing ReturnDate values (books not returned)")
    print("4. Duplicate ISBN for same student (STU-2024-001 borrowed same book twice)")
    
    return df

def create_digital_usage():
    """Create digital_usage.xlsx with data quality issues"""
    data = {
        'Date': [
            '2024-01-15', '2024-01-16', '2024-02-01', 'Jan 15, 2024',
            '02/10/2024', '2024-15-02', '2024-02-20', 'Feb 25, 2024',
            '03/01/2024', '2024-03-05', '2024-03-10', 'Mar 15, 2024',
            '2024-03-20', '2024-03-25'
        ],
        'UserType': [
            'Student', 'Graduate Student', 'Student', 'Faculty',
            'Student', 'Student', 'Staff', 'Graduate Student',
            'Student', 'Faculty', 'Student', 'Student',
            'Graduate Student', 'Staff'
        ],
        'ResourceType': [
            'E-book', 'e-Book', 'Journal', 'Journal',
            'E-book', 'Article', 'E-book', 'Journal',
            'e-Book', 'Article', 'Journal', 'E-book',
            'e-Book', 'Journal'
        ],
        'Faculty': [
            'ENG', 'Engineering', 'Engr', 'CS',
            'CS', 'BUS', 'CS', 'Engineering',
            'BUS', 'ENG', 'Business', 'CS',
            'ENG', 'CS'
        ],
        'DownloadCount': [1, 1, 3, 1, 1, 2, 1, 2, 1, 1, 2, 1, 1, 1],
        'Duration_Minutes': [45, 90, 120, 30, None, 60, 45, 90, 30, 45, None, 60, 90, 45]
    }
    
    df = pd.DataFrame(data)
    
    os.makedirs('09_Source_Data', exist_ok=True)
    df.to_excel('09_Source_Data/digital_usage.xlsx', index=False)
    print(f"\nCreated digital_usage.xlsx with {len(df)} records")
    
    print("\nData Quality Issues in Digital Usage:")
    print("1. Three different date formats: 2024-01-15, 01/16/2024, Jan 15, 2024")
    print("2. Inconsistent capitalization: E-book vs e-Book")
    print("3. Faculty codes vary: ENG, Engineering, Engr")
    print("4. Missing Duration_Minutes values")
    
    return df

def create_room_bookings():
    """Create room_bookings.csv with data quality issues"""
    data = [
        # BookingID, RoomNumber, BookingDate, TimeSlot, StudentID, DurationHours, Purpose
        [5001, 'R101', '2024-03-15', 'Morning', 'STU-2024-001', 2.0, 'Study'],
        [5002, 'R-102', '2024-03-15', '8AM-10AM', 'STU-2024-002', 2.0, 'Group Project'],
        [5003, 'Room201', '2024-03-20', 'Evening', 'STU-2024-006', 4.0, 'Meeting'],
        [5004, 'R101', '2024-02-12', '12PM-2PM', 'STU-2024-001', 2.0, 'Study'],
        [5005, 'R101', '15-Mar-2024', 'Night', '', 1.5, 'Study'],
        [5006, 'R101', '2024-03-15', 'Morning', 'STU-2024-001', 2.0, 'Study'],
        [5007, 'R-102', '2024-03-16', 'Afternoon', 'STU-2024-003', 3.0, 'Research'],
        [5008, 'Room101', '2024-03-17', 'Evening', 'STU-2024-004', 2.5, 'Group Study'],
        [5009, 'R201', '2024-03-18', 'Morning', 'STU-2024-005', 1.0, 'Interview Prep'],
        [5010, 'R-201', '2024-03-19', 'Afternoon', 'STU-2024-007', 4.0, 'Thesis Writing'],
        [5011, 'R102', '2024-03-20', 'Evening', 'STU-2024-008', 3.0, 'Study Group'],
        [5012, 'R-101', '2024-03-21', 'Night', '', 2.0, 'Study'],
        [5013, 'Room102', '2024-03-22', 'Morning', 'STU-2024-009', 1.5, 'Presentation Practice'],
        [5014, 'R201', '2024-03-23', 'Afternoon', 'STU-2024-010', 3.0, 'Project Meeting'],
        [5015, 'R-202', '2024-03-24', 'Evening', 'STU-2024-011', 2.0, 'Study']
    ]
    
    df = pd.DataFrame(data, columns=[
        'BookingID', 'RoomNumber', 'BookingDate', 'TimeSlot',
        'StudentID', 'DurationHours', 'Purpose'
    ])
    
    os.makedirs('09_Source_Data', exist_ok=True)
    df.to_csv('09_Source_Data/room_bookings.csv', index=False)
    print(f"\nCreated room_bookings.csv with {len(df)} records")
    
    print("\nData Quality Issues in Room Bookings:")
    print("1. Room number formats vary: R101, R-101, Room101")
    print("2. TimeSlot not standardized: Morning, 8AM-10AM, AM")
    print("3. Missing StudentID (walk-ins)")
    print("4. Duplicate entries (BookingID 5001 and 5006 similar)")
    
    return df

def create_sample_etl_config():
    """Create a configuration file for ETL testing"""
    config_content = """# ETL Configuration File
# Library Analytics Data Warehouse

[SOURCE_FILES]
book_transactions = 09_Source_Data/book_transactions.csv
digital_usage = 09_Source_Data/digital_usage.xlsx
room_bookings = 09_Source_Data/room_bookings.csv

[DATABASE]
host = localhost
user = root
password = 
database = library_analytics_dw

[TRANSFORMATIONS]
# Department standardization
CS = Computer Science
CompSci = Computer Science
ENG = Engineering
Engr = Engineering
BUS = Business

# Time slot standardization
8AM-10AM = Morning
12PM-2PM = Afternoon
5PM-7PM = Evening
AM = Morning
PM = Afternoon

[ETL_SETTINGS]
log_level = INFO
batch_size = 1000
error_threshold = 0.05  # 5% errors allowed
"""
    
    with open('etl_config.ini', 'w') as f:
        f.write(config_content)
    print("\nCreated etl_config.ini for ETL configuration")

def main():
    """Create all sample data files"""
    print("=" * 60)
    print("CREATING SAMPLE SOURCE DATA FILES")
    print("=" * 60)
    
    # Create directory
    os.makedirs('09_Source_Data', exist_ok=True)
    
    # Create files
    create_book_transactions()
    create_digital_usage()
    create_room_bookings()
    create_sample_etl_config()
    
    print("\n" + "=" * 60)
    print("ALL SAMPLE FILES CREATED SUCCESSFULLY!")
    print("=" * 60)
    print("\nFiles created in 09_Source_Data/ directory:")
    print("1. book_transactions.csv - 15 records")
    print("2. digital_usage.xlsx - 14 records")
    print("3. room_bookings.csv - 15 records")
    print("4. etl_config.ini - Configuration file")
    
    print("\nData Quality Issues Included:")
    print("• Inconsistent department names")
    print("• Multiple date formats")
    print("• Missing values")
    print("• Inconsistent capitalization")
    print("• Duplicate records")
    print("• Varying naming conventions")

if __name__ == "__main__":
    main()
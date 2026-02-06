
#Clear All Dimension and Fact Tables

import pymysql

DB_CONFIG = {
    'host': '127.0.0.1',
    'user': 'root',
    'password': '',
    'database': 'library_analytics_dw'
}

print("="*60)
print("CLEARING ALL DIMENSION AND FACT TABLES")
print("="*60)
print("\nWARNING: This will delete all data from dimension and fact tables")
print("Staging tables will NOT be affected")

# Ask for confirmation
response = input("\nAre you sure you want to continue? (yes/no): ")
if response.lower() != 'yes':
    print("\nOperation cancelled.")
    exit(0)

try:
    conn = pymysql.connect(**DB_CONFIG)
    cursor = conn.cursor()
    
    # Disable foreign key checks
    print("\n1. Disabling foreign key checks...")
    cursor.execute("SET FOREIGN_KEY_CHECKS = 0")
    print("   [OK]")
    
    # Clear all tables (fact first, then dimensions)
    tables = [
        'fact_library_usage',
        'dim_student',
        'dim_date',
        'dim_resource',
        'dim_location',
        'dim_time_slot'
    ]
    
    print("\n2. Clearing tables...")
    for table in tables:
        try:
            cursor.execute(f"DELETE FROM {table}")
            print(f"   [OK] Cleared {table}")
        except Exception as e:
            print(f"   [FAILED] {table}: {e}")
    
    conn.commit()
    
    # Re-enable foreign key checks
    print("\n3. Re-enabling foreign key checks...")
    cursor.execute("SET FOREIGN_KEY_CHECKS = 1")
    print("   [OK]")
    
    # Verify all empty
    print("\n4. Verifying tables are empty...")
    all_empty = True
    for table in tables:
        cursor.execute(f"SELECT COUNT(*) FROM {table}")
        count = cursor.fetchone()[0]
        status = "" if count == 0 else ""
        print(f"   {status} {table}: {count} rows")
        if count > 0:
            all_empty = False
    
    # Check staging tables still have data
    print("\n5. Verifying staging tables still have data...")
    staging_tables = [
        'staging_book_transactions',
        'staging_digital_usage',
        'staging_room_bookings'
    ]
    
    for table in staging_tables:
        cursor.execute(f"SELECT COUNT(*) FROM {table}")
        count = cursor.fetchone()[0]
        status = "" if count > 0 else ""
        print(f"   {status} {table}: {count} rows")
    
    cursor.close()
    conn.close()
    
    print("\n" + "="*60)
    if all_empty:
        print(" ALL DIMENSION AND FACT TABLES CLEARED SUCCESSFULLY!")
    else:
        print("  SOME TABLES STILL HAVE DATA - CHECK ABOVE")
    print("="*60)
    print("\nYou can now run: python etl_pipeline.py")
    
except Exception as e:
    print(f"\n[ERROR] Failed: {e}")
    import traceback
    traceback.print_exc()
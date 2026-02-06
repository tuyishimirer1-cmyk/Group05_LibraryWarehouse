
import pymysql
from pymysql import Error

print("Testing with PyMySQL...")
print("-" * 50)

try:
    conn = pymysql.connect(
        host='127.0.0.1',
        user='root',
        password='',
        database='library_analytics_dw',
        connect_timeout=5
    )
    
    print("Connected!")
    print("-" * 50)
    
    cursor = conn.cursor()
    
    cursor.execute("SELECT DATABASE()")
    db = cursor.fetchone()
    print(f"Database: {db[0]}")
    
    cursor.execute("SELECT VERSION()")
    version = cursor.fetchone()
    print(f"Version: {version[0]}")
    
    print("-" * 50)
    
    cursor.execute("SHOW TABLES")
    tables = cursor.fetchall()
    
    if tables:
        print(f"Found {len(tables)} table(s):\n")
        for table in tables:
            cursor.execute(f"SELECT COUNT(*) FROM {table[0]}")
            count = cursor.fetchone()
            print(f"   {table[0]}: {count[0]:,} rows")
    else:
        print("  No tables - run ETL script")
    
    print("-" * 50)
    print(" Success!")
    
    cursor.close()
    conn.close()

except Error as e:
    print(f" Error: {e}")
except Exception as e:
    print(f" Error: {e}")
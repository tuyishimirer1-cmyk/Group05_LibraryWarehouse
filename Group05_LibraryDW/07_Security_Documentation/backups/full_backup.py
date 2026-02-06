import os
from datetime import datetime

DB_NAME = "library_analytics_dw"
USER = "root"
PASSWORD = ""

backup_dir = "backups/full"
os.makedirs(backup_dir, exist_ok=True)

date = datetime.now().strftime("%Y%m%d_%H%M")
backup_file = f"{backup_dir}/full_backup_{date}.sql"

command = f"mysqldump -u {USER} {DB_NAME} > {backup_file}"

os.system(command)

print("FULL BACKUP COMPLETED")
print("Saved at:", backup_file)

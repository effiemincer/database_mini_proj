#!/bin/bash

# Database configuration
DB_NAME="your_database_name"
DB_USER="your_username"
DB_HOST="localhost"
DB_PORT="5432"

# Filenames
BACKUP_SQL="backupSQL.sql"
BACKUP_SQL_LOG="backupSQL.log"
BACKUP_PSQL="backupPSQL.sql"
BACKUP_PSQL_LOG="backupPSQL.log"

# Create a text-based SQL dump with pg_dump
echo "Creating text-based SQL dump..."
pg_dump -U $DB_USER -h $DB_HOST -p $DB_PORT --inserts --clean --file=$BACKUP_SQL $DB_NAME &> $BACKUP_SQL_LOG
echo "SQL dump created and logged to $BACKUP_SQL_LOG."

# Create a binary backup with pg_dump
echo "Creating binary backup..."
pg_dump -U $DB_USER -h $DB_HOST -p $DB_PORT -Fc -f $BACKUP_PSQL $DB_NAME &> $BACKUP_PSQL_LOG
echo "Binary backup created and logged to $BACKUP_PSQL_LOG."

# Clear and restore the database
echo "Clearing and restoring the database..."
psql -U $DB_USER -h $DB_HOST -p $DB_PORT -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;" $DB_NAME &>> $BACKUP_PSQL_LOG
pg_restore -U $DB_USER -h $DB_HOST -p $DB_PORT -d $DB_NAME $BACKUP_PSQL &>> $BACKUP_PSQL_LOG
echo "Database restored and logged to $BACKUP_PSQL_LOG."

# Time an SQL query
echo "Timing SQL queries..."
psql -U $DB_USER -h $DB_HOST -p $DB_PORT -d $DB_NAME -c "\timing on" -c "SELECT COUNT(*) FROM some_table;" &>> $BACKUP_SQL_LOG

# Add files to git
echo "Staging files in git..."
git add $BACKUP_SQL $BACKUP_SQL_LOG $BACKUP_PSQL $BACKUP_PSQL_LOG backup_script.sh

# Configure Git-LFS for backup files
echo "Configuring Git-LFS for backup files..."
git lfs track "*.sql"
git add .gitattributes

# Commit changes
git commit -m "Added database backup script and logs"

echo "Task complete. Don't forget to push the repository!"

#!/bin/bash

# Basic configuration: datestamp e.g. YYYYMMDD
DATE=$(date +"%Y%m%d")

# Location of your backups (create the directory first!)
BACKUP_DIR="/backups/mysql"

# MySQL login details
DATABASE="<MYSQL CONTAINER>"
MYSQL_USER="root"
MYSQL_PASSWORD="<MYSQL ROOT PASSWORD>"

# MySQL executable locations (no need to change this)
MYSQL=/usr/bin/mysql
MYSQLDUMP=/usr/bin/mysqldump

# MySQL databases you wish to skip
SKIPDATABASES="Database|information_schema|performance_schema|mysql"

# Number of days to keep the directories (older than X days will be removed)
RETENTION=14

# Create a new directory into backup directory location for this date
mkdir -p $BACKUP_DIR/$DATE

# Retrieve a list of all databases
databases=`docker exec -i $DATABASE $MYSQL -u$MYSQL_USER -p$MYSQL_PASSWORD -e "SHOW DATABASES;" | grep -Ev "($SKIPDATABASES)"`

# Dumb the databases in seperate names and gzip the .sql file
for db in $databases; do
echo $db
docker exec $DATABASE $MYSQLDUMP --force --opt --user=$MYSQL_USER --password=$MYSQL_PASSWORD --skip-lock-tables --events --databases $db | gzip >
 "$BACKUP_DIR/$DATE/$db.sql.gz"
done

# Remove files older than X days
#
find $BACKUP_DIR/* -mtime +$RETENTION -delete

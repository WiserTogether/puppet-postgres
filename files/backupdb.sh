#!/bin/sh

if [ "" == "$1" ]; then
	echo "Usage: $0 <databasename>"
	exit 1
fi
db=$1
year=`date +"%Y"`
month=`date +"%m"`
backupdir="/var/lib/pgsql/backups/$year/$month"
mkdir -p $backupdir
datestamp=`date +"%Y-%m-%dT%H%M"`
backupfile="backups/$year/$month/$db-$datestamp.pgd"

echo "$backupfile"
pg_dump -Fc -Z5 --file="$backupfile" "$db"

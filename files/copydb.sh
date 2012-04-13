#!/bin/sh
if [[ "" == "$1" || "" == "$2" || "" == "$3" ]]; then
	echo "Usage: copydb.sh <sourcedb> <targetdb> <targetowner>"
	exit 1
fi

SOURCE_DATABASE=$1
TARGET_DATABASE=$2
TARGET_DATABASE_USER=$3

SOURCE_BACKUP_FILE=`sh ./backupdb.sh $SOURCE_DATABASE`
sh ./backupdb.sh $TARGET_DATABASE

echo "Copying $SOURCE_DATABASE to $TARGET_DATABASE owned by $TARGET_DATABASE_USER"

psql -c "create database \"${TARGET_DATABASE}_temp\";" 
pg_restore --dbname "${TARGET_DATABASE}_temp" $SOURCE_BACKUP_FILE
psql -c "alter schema public owner to \"$TARGET_DATABASE_USER\";" ${TARGET_DATABASE}_temp
for tbl in `psql -qAt -c "select tablename from pg_tables where schemaname = 'public';" ${TARGET_DATABASE}_temp` ; do
    psql -c "alter table $tbl owner to \"$TARGET_DATABASE_USER\"" ${TARGET_DATABASE}_temp; 
done

for tbl in `psql -qAt -c "select sequence_name from information_schema.sequences where sequence_schema = 'public';" ${TARGET_DATABASE}_temp` ; do
    psql -c "alter table $tbl owner to \"$TARGET_DATABASE_USER\"" ${TARGET_DATABASE}_temp; 
done

for tbl in `psql -qAt -c "select table_name from information_schema.views where table_schema = 'public';" ${TARGET_DATABASE}_temp` ; do
    psql -c "alter table $tbl owner to \"$TARGET_DATABASE_USER\"" ${TARGET_DATABASE}_temp; 
done

psql -c "drop database \"${TARGET_DATABASE}\";" 
psql -c "alter database \"${TARGET_DATABASE}_temp\" rename to \"${TARGET_DATABASE}\";" 

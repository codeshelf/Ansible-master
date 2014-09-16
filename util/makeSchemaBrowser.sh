#!/bin/bash
DBVERSION=`psql -d database -c "select version from test.db_property" -h pgtest -U codeshelf -tA -F ""`
echo Generating Diagram for DB Version $DBVERSION

FOLDER=/home/ansible/roles/www/files/dev/schema/$DBVERSION
rm -rf $FOLDER

java -jar /home/ansible/util/schemaSpy_5.0.0.jar -t pgsql -host pgtest -db database -s test -u codeshelf -p golbwomgkneomqi -o $FOLDER -hq -dp /home/ansible/util/postgresql-9.3-1100.jdbc41.jar

DBVERSIONHTML=`psql -d database -c "select '<a href=',version,'>Version ',version,'</a>' from test.db_property" -h pgtest -U codeshelf -tA -F ""`a
echo HTML: $DBVERSIONHTML 

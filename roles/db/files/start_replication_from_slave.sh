#!/bin/bash
cd /var/lib/pgsql/9.3

echo Stopping PostgreSQL
service postgresql-9.3 stop
 
echo Cleaning up old cluster directory
sudo -u postgres rm -rf data
sudo -u postgres mkdir data
sudo -u postgres chmod 0700 data
 
echo Starting base backup as replicator
sudo -u postgres pg_basebackup -h dbmaster -D data -U replicator -v -P

echo Enable hot standby mode in postgresql.conf
sudo -u postgres bash -c "echo 'hot_standby = on' >> data/postgresql.conf"
 
echo Writing recovery.conf file
sudo -u postgres bash -c "cat > data/recovery.conf <<- _EOF1_
standby_mode = 'on'
primary_conninfo = 'host=dbmaster port=5432 user=replicator password=hrajukipnoldwary'
trigger_file = '/tmp/postgresql.trigger'
_EOF1_
"
 
echo Starting PostgreSQL
service postgresql-9.3 start


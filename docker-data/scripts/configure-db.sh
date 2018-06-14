#!/usr/bin/env bash

debconf-set-selections <<< "mysql-server mysql-server/root_password password $SEABATTLE_DB_PASS"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $SEABATTLE_DB_PASS"
apt-get install -y mysql-server mysql-client

chown -R mysql:mysql /var/lib/mysql
service mysql start

mysql -u"$SEABATTLE_DB_USER" -p"$SEABATTLE_DB_PASS" -e "CREATE DATABASE \`$SEABATTLE_DB_NAME\`;"
mysql -u"$SEABATTLE_DB_USER" -p"$SEABATTLE_DB_PASS" $SEABATTLE_DB_NAME < /srv/backups/install.sql

service mysql stop

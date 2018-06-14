#!/usr/bin/env bash

chown -R mysql:mysql /var/lib/mysql /var/run/mysqld
service mysql restart
#mysqld_safe --skip-grant-tables --datadir=/var/lib/mysql --socket=/var/run/mysqld/mysqld.sock &
mysql --socket=/var/run/mysqld/mysqld.sock -e "CREATE DATABASE $SEABATTLE_DB_NAME;"
mysql --socket=/var/run/mysqld/mysqld.sock $SEABATTLE_DB_NAME < /tmp/seabattle_install.sql

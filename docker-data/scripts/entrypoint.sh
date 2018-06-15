#!/usr/bin/env bash


until nc -z -v -w30 $SEABATTLE_DB_HOST 3306
do
  echo "[`date "+%Y-%m-%d %H:%M:%S"`] Waiting for database connection..."
  # wait for 5 seconds before check again
  sleep 5
done

mysql -u"$SEABATTLE_DB_USER" -p"$SEABATTLE_DB_PASS" -h"$SEABATTLE_DB_HOST" $SEABATTLE_DB_NAME -e "source /srv/backups/install.sql"

if [ -f /srv/eggdrop/data/eggdrop.user ]; then
    echo "[`date "+%Y-%m-%d %H:%M:%S"`] Eggdrop user file already exist."
    EGG_PARAMS="-n"
else
    echo "[`date "+%Y-%m-%d %H:%M:%S"`] Eggdrop user file created."
    EGG_PARAMS="-n -m"
fi

cmd="eggdrop $EGG_PARAMS /etc/eggdrop.conf"
sudo -HEnu eggdrop $cmd

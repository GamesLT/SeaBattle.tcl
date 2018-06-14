#!/usr/bin/env bash

chown -R mysql:mysql /var/lib/mysql
service mysql restart

if [ -f /srv/eggdrop/data/eggdrop.user ]; then
    echo "Eggdrop user file already exist."
    EGG_PARAMS="-n"
else
    echo "Eggdrop user file created."
    EGG_PARAMS="-n -m"
fi

cmd="eggdrop $EGG_PARAMS /etc/eggdrop.conf"
sudo -HEnu eggdrop $cmd

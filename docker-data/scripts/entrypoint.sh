#!/usr/bin/env bash

service mysql start

if [ -f /root/eggdrop.user ]; then
    echo "Eggdrop user file already exist."
    EGG_PARAMS="-n"
else
    echo "Eggdrop user file created."
    EGG_PARAMS="-n -m"
fi

cmd="eggdrop $EGG_PARAMS /etc/eggdrop.conf"
sudo -HEnu eggdrop $cmd

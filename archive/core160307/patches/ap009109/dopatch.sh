#!/bin/bash
# Performs patch
#
# Copyright (C) 2014 Uvea I. S., Kevin Rattai
#
# Useage:
# wget -N -r -nd -l2 -w 3 -P $HOME --limit-rate=50k http://192.168.200.6/files/create-asys.sh; chmod 777 $HOME/create-asys.sh; $HOME/./create-asys.sh; rm $HOME/create-asys.sh
# or
# wget -N -r -nd -l2 -w 3 -P $HOME --limit-rate=50k "https://www.dropbox.com/s/1t3ejk4iyzm07u6/create-asys.sh"; chmod 777 $HOME/create-asys.sh; $HOME/./create-asys.sh; rm $HOME/create-asys.sh


LOCAL_SYS="/home/pi/.local"
NETWORK_SYS="/home/pi/.network"
OFFLINE_SYS="/home/pi/.offline"
AEBL_SYS="/home/pi/.aeblsys"

TEMP_DIR="/home/pi/tempdir"
MP3_DIR="/home/pi/mp3"
MP4_DIR="/home/pi/mp4"
PL_DIR="/home/pi/pl"
CTRL_DIR="/home/pi/ctrl"
BIN_DIR="/home/pi/bin"

USER=`whoami`
CRONLOC=/var/spool/cron/crontabs
# CRONCOMMFILE=/tmp/cron_comm_file.sh
CRONCOMMFILE="${HOME}/testcron.sh"
CRONGREP=$(crontab -l | cat )

IPe0=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f 1)
MACe0=$(ip link show eth0 | awk '/ether/ {print $2}')

# Discover network availability
#

ping -c 1 8.8.8.8

if [ $? -eq 0 ]; then
    touch .network
    echo "Internet available."
else
    rm .network
fi

ping -c 1 192.168.200.6

if [[ $? -eq 0 ]]; then
    touch .local
    echo "Local network available."
else
    rm .local
fi

if [ ! -f "${LOCAL_SYS}" ] && [ ! -f "${NETWORK_SYS}" ]; then
    touch .offline
    echo "No network available."
else
    rm .offline
fi

touch ${AEBL_SYS}

export PATH=$PATH:${BIN_DIR}:$HOME/scripts

if [ -f "/home/pi/.ihdndet" ]; then
    mv det.sh $HOME/.scripts
    chmod 777 $HOME/.scripts/det.sh
    cp $HOME/.scripts/det.sh $HOME/bin
    cp $HOME/.scripts/det.sh $HOME/.backup/scripts
    cp $HOME/.scripts/det.sh /run/shm/scripts

    # wait 5 minutes, then reboot
    sudo shutdown -r +5 &
fi

# mv patch.sh $HOME/.scripts
# chmod 777 $HOME/.scripts/patch.sh
# cp $HOME/.scripts/patch.sh $HOME/.backup/scripts
# cp $HOME/.scripts/patch.sh /run/shm/scripts

sleep 5

GRAB_FILE="pv"
pv=$(cat "${GRAB_FILE}" | head -n1)

if [ ! -f "${OFFLINE_SYS}" ]; then
#     $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic @kratt, ${MACe0} patched to ${pv}." &
    # express that AEBL device being installed
    ext_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
mosquitto_pub -d -t hello/world -m "$(date) : AEBL Pi patched to ${pv}. ${MACe0} IP is $ext_ip" -h "uveais.ca"
fi

exit

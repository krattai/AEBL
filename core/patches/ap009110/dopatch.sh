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
AEBL_TEST="/home/pi/.aebltest"
AEBL_SYS="/home/pi/.aeblsys"
AEBL_VM="/home/pi/.aeblvm"
IHDN_TEST="/home/pi/.ihdntest"
IHDN_SYS="/home/pi/.ihdnsys"
IHDN_DET="/home/pi/.ihdndet"

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

# if not AEBL_SYS and previously set to be, then remove
if [ ! -f "${AEBL_VM}" ] || [ ! -f "${IHDN_TEST}" ] || [ ! -f "${IHDN_SYS}" ] || [ ! -f "${IHDN_DET}" ]; then
    if [ ! -f "${AEBL_SYS}" ]; then
        rm ${AEBL_SYS}
    fi
fi

export PATH=$PATH:${BIN_DIR}:$HOME/scripts

mv startup.sh $HOME/.scripts
chmod 777 $HOME/.scripts/startup.sh
cp $HOME/.scripts/patch.sh $HOME/.backup/scripts
cp $HOME/.scripts/patch.sh /run/shm/scripts

sleep 5

GRAB_FILE="pv"
pv=$(cat "${GRAB_FILE}" | head -n1)

if [ ! -f "${OFFLINE_SYS}" ]; then
    $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic @kratt, ${MACe0} patched to ${pv}." &
fi

exit

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

T_STO="/run/shm"
T_SCR="/run/shm/scripts"

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

# change backup to .backup
mkdir $HOME/.backup
mkdir $HOME/.backup/scripts
mv $HOME/backup/scripts/* $HOME/.backup/scripts
rmdir $HOME/backup/scripts
mkdir $HOME/.backup/bin
mv $HOME/backup/bin/* $HOME/.backup/bin
rmdir $HOME/backup/bin
mkdir $HOME/.backup/pl
mv $HOME/backup/pl/* $HOME/.backup/pl
rmdir $HOME/backup/pl
mkdir $HOME/.backup/ctrl
mv $HOME/backup/ctrl/* $HOME/.backup/ctrl
rmdir $HOME/backup/ctrl
mv $HOME/backup/version $HOME/.backup
rmdir $HOME/backup

sleep 5

mv getupdt.sh $HOME/scripts
chmod 777 $HOME/scripts/getupdt.sh
cp $HOME/scripts/* $HOME/.scripts
cp $HOME/scripts/getupdt.sh $T_SCR

mv update.sh $HOME/scripts
chmod 777 $HOME/scripts/update.sh
cp $HOME/scripts/* $HOME/.scripts
cp $HOME/scripts/update.sh $T_SCR

sleep 5

GRAB_FILE="pv"
pv=$(cat "${GRAB_FILE}" | head -n1)

echo "${pv}" >> $HOME/patch.log

# if [ ! -f "${OFFLINE_SYS}" ]; then
#     $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic @kratt, ${MACe0} patched to ${pv}." &
# fi

exit

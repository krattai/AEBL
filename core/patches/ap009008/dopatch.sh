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
IHDN_TEST="/home/pi/.ihdntest"
IHDN_SYS="/home/pi/.ihdnsys"

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

if [ -f "${IHDN_SYS}" ] || [ -f "${IHDN_TEST}" ] && [ -f "${AEBL_SYS}" ]; then
    rm ${AEBL_SYS}
fi

export PATH=$PATH:${BIN_DIR}:$HOME/scripts

# one time - clear getupdt.sh from system
rm $HOME/scripts/getupdt.sh
rm $HOME/.scripts/getupdt.sh
rm $T_SCR/getupdt.sh

# one time - clear getupdt.sh from system
rm $HOME/scripts/update.sh
rm $HOME/.scripts/update.sh
rm $T_SCR/update.sh

mv ctrlwtch.sh $HOME/.scripts
chmod 777 $HOME/.scripts/ctrlwtch.sh
cp $HOME/.scripts/* $HOME/scripts
cp $HOME/.scripts/ctrlwtch.sh $T_SCR

mv inetup.sh $HOME/.scripts
chmod 777 $HOME/.scripts/inetup.sh
cp $HOME/.scripts/* $HOME/scripts
cp $HOME/.scripts/inetup.sh $T_SCR

mv l-ctrl.sh $HOME/.scripts
chmod 777 $HOME/.scripts/l-ctrl.sh
cp $HOME/.scripts/* $HOME/scripts
cp $HOME/.scripts/l-ctrl.sh $T_SCR

mv synfilz.sh $HOME/.scripts
chmod 777 $HOME/.scripts/synfilz.sh
cp $HOME/.scripts/* $HOME/scripts
cp $HOME/.scripts/synfilz.sh $T_SCR

sleep 5

# one time set to restart ctrlwtch.sh
touch "${HOME}/ctrl/.newctrl"

sleep 5

# leaving as reference example of "proper" add to system
# mv startup.sh $HOME/.scripts
# chmod 777 $HOME/.scripts/startup.sh
# cp $HOME/.scripts/* $HOME/scripts
# cp $HOME/.scripts/startup.sh $T_SCR

GRAB_FILE="pv"
pv=$(cat "${GRAB_FILE}" | head -n1)

echo "${pv}" >> $HOME/patch.log

# if [ ! -f "${OFFLINE_SYS}" ]; then
#     $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic @kratt, ${MACe0} patched to ${pv}." &
# fi

exit

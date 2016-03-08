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

TEMP_DIR="/home/pi/tmp"
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

# .scripts dir not made properly, wrongly set as file
rm $HOME/.scripts
mkdir $HOME/.scripts
cp $HOME/scripts/* $HOME/.scripts

mv startup.sh $HOME/.scripts
chmod 777 $HOME/.scripts/startup.sh
cp $HOME/.scripts/* $HOME/scripts
cp $HOME/.scripts/startup.sh $T_SCR

mv run.sh $HOME/.scripts
chmod 777 $HOME/.scripts/run.sh
cp $HOME/.scripts/* $HOME/scripts
cp $HOME/.scripts/run.sh $T_SCR

mv l-ctrl.sh $HOME/.scripts
chmod 777 $HOME/.scripts/l-ctrl.sh
cp $HOME/.scripts/* $HOME/scripts
cp $HOME/.scripts/l-ctrl.sh $T_SCR

mv ctrlwtch.sh $HOME/.scripts
chmod 777 $HOME/.scripts/ctrlwtch.sh
cp $HOME/.scripts/* $HOME/scripts
cp $HOME/.scripts/ctrlwtch.sh $T_SCR

mv inetup.sh $HOME/.scripts
chmod 777 $HOME/.scripts/inetup.sh
cp $HOME/.scripts/* $HOME/scripts
cp $HOME/.scripts/inetup.sh $T_SCR

mv macip.sh $HOME/.scripts
chmod 777 $HOME/.scripts/macip.sh
cp $HOME/.scripts/* $HOME/scripts
cp $HOME/.scripts/macip.sh $T_SCR

mv mkplay.sh $HOME/.scripts
chmod 777 $HOME/.scripts/mkplay.sh
cp $HOME/.scripts/* $HOME/scripts
cp $HOME/.scripts/mkplay.sh $T_SCR

mv mkuniq.sh $HOME/.scripts
chmod 777 $HOME/.scripts/mkuniq.sh
cp $HOME/.scripts/* $HOME/scripts
cp $HOME/.scripts/mkuniq.sh $T_SCR

mv patch.sh $HOME/.scripts
chmod 777 $HOME/.scripts/patch.sh
cp $HOME/.scripts/* $HOME/scripts
cp $HOME/.scripts/patch.sh $T_SCR

mv playlist.sh $HOME/.scripts
chmod 777 $HOME/.scripts/playlist.sh
cp $HOME/.scripts/* $HOME/scripts
cp $HOME/.scripts/playlist.sh $T_SCR

mv process_playlist.sh $HOME/.scripts
chmod 777 $HOME/.scripts/process_playlist.sh
cp $HOME/.scripts/* $HOME/scripts
cp $HOME/.scripts/process_playlist.sh $T_SCR

mv synfilz.sh $HOME/.scripts
chmod 777 $HOME/.scripts/synfilz.sh
cp $HOME/.scripts/* $HOME/scripts
cp $HOME/.scripts/synfilz.sh $T_SCR

mv upgrade.sh $HOME/.scripts
chmod 777 $HOME/.scripts/upgrade.sh
cp $HOME/.scripts/* $HOME/scripts
cp $HOME/.scripts/upgrade.sh $T_SCR

if [ -f "${IHDN_TEST}" ] || [ -f "${IHDN_SYS}" ]; then
    mv ihdn_play.sh $HOME/.scripts
    chmod 777 $HOME/.scripts/ihdn_play.sh
    cp $HOME/.scripts/* $HOME/scripts
    cp $HOME/.scripts/ihdn_play.sh $T_SCR
    mv ihdn_tests.sh $HOME/.scripts
    chmod 777 $HOME/.scripts/ihdn_tests.sh
    cp $HOME/.scripts/* $HOME/scripts
    cp $HOME/.scripts/ihdn_tests.sh $T_SCR
else
    mv aebl_play.sh $HOME/.scripts
    chmod 777 $HOME/.scripts/aebl_play.sh
    cp $HOME/.scripts/* $HOME/scripts
    cp $HOME/.scripts/aebl_play.sh $T_SCR
fi

sleep 5

# leaving following as reference examples of "proper" add to system
# mv startup.sh $HOME/.scripts
# chmod 777 $HOME/.scripts/startup.sh
# cp $HOME/.scripts/* $HOME/scripts
# cp $HOME/.scripts/startup.sh $T_SCR

# if [ -f "${HOME}/.ihdnfol0" ]; then
#     mv grbchan0.sh $HOME/.scripts
#     chmod 777 $HOME/.scripts/grbchan0.sh
#     cp $HOME/.scripts/* $HOME/scripts
#     cp $HOME/.scripts/grbchan0.sh $T_SCR
# fi

# if [ -f "${IHDN_TEST}" ] || [ -f "${IHDN_SYS}" ]; then
#     mv ihdn_tests.sh $HOME/.scripts
#     chmod 777 $HOME/.scripts/ihdn_tests.sh
#     cp $HOME/.scripts/* $HOME/scripts
#     cp $HOME/.scripts/ihdn_tests.sh $T_SCR
# fi

# one time set to restart ctrlwtch.sh
# touch "${HOME}/ctrl/.newctrl"

GRAB_FILE="pv"
pv=$(cat "${GRAB_FILE}" | head -n1)

echo "${pv}" >> $HOME/patch.log

# if [ ! -f "${OFFLINE_SYS}" ]; then
#     $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic @kratt, ${MACe0} patched to ${pv}." &
# fi

exit

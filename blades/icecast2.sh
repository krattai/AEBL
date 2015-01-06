#!/bin/bash
# Installs icecast2 blade
#
# Copyright (C) 2015 Uvea I. S., Kevin Rattai
#
# Useage:
# no useage


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

mkdir blade

# Get icecast2 package, must wget using ?raw=true
# wget -N -r -nd -l2 -w 3 -O "/home/pi/blade/icecast2.zip" --limit-rate=50k https://github.com/krattai/AEBL/blob/master/blades/icecast2.zip?raw=true

# cd blade
# unzip icecast2.zip
# rm icecast2.zip

# For test purposes, went through above process but will install deb pckg

# icecast2/icecast-setup  boolean true
# icecast2/relaypassword  string  hackme
# icecast2/adminpassword  string  hackme
# icecast2/hostname       string  localhost
# icecast2/sourcepassword string  hackme


sudo apt-get -y install icecast2

# ~~~~~~~~~~~~~ good to this point ~~~~~~~~
# 
# chmod 777 dopatch.sh
# sleep 5
# ./dopatch.sh
# rm *
# cd ..
# touch $HOME/.${cont}
# sleep 30

# mv synfilz.sh $HOME/.scripts
# chmod 777 $HOME/.scripts/synfilz.sh
# cp $HOME/.scripts/synfilz.sh $HOME/.backup/scripts
# cp $HOME/.scripts/synfilz.sh /run/shm/scripts

# mv l-ctrl.sh $HOME/.scripts
# chmod 777 $HOME/.scripts/l-ctrl.sh
# cp $HOME/.scripts/l-ctrl.sh $HOME/.backup/scripts
# cp $HOME/.scripts/l-ctrl.sh /run/shm/scripts

# sleep 5

# GRAB_FILE="pv"
# pv=$(cat "${GRAB_FILE}" | head -n1)

if [ ! -f "${OFFLINE_SYS}" ]; then
    $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic @kratt, ${MACe0} installed webmin blade." &
fi

exit

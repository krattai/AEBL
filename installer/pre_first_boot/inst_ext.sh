#!/bin/bash
#
# This script runs additional functions as desired
#
# Copyright (C) 2017 Uvea I. S., Kevin Rattai
#
# Useage:
# There is no useage, this is a standalone script

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
T_SCR="/run/shm/scripts"

USER=`whoami`
IPe0=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f 1)
MACe0=$(ip link show eth0 | awk '/ether/ {print $2}')

PLAYER_OPTIONS="-o both --vol -2500 -r"

cd $HOME

wait=0

# Discover network availability
#

net_wait=0

# Repeat for 5 minutes, or 10 cycles, until network available or still no network
while [ $net_wait -lt 10 ]; do

    # is google there?
    ping -c 1 8.8.8.8

    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    # use this as reference for future feature to grab install file immediately from net
    if [ $? -eq 0 ]; then

        # get, install, and run entertainment video script
        wget -N -nd -w 3 --limit-rate=50k https://raw.githubusercontent.com/krattai/AEBL/master/installer/pre_first_boot/vident.sh
        chmod 755 vident.sh
        mv vident.sh $T_SCR/vident.sh
        $T_SCR/./vident.sh &
        net_wait=10

    else
        net_wait=net_wait+1
        sleep 30
    fi

done

exit

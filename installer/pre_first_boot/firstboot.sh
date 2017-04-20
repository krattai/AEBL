#!/bin/bash
#
# This script is the first run from a fresh AEBL device
# It gets information from current host of AEBL platform for installation
#
# Yes, this will introduce possible security risk so will need to ensure control
#   of domain and introduce possible auth via challenge/response, or something
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
# Actually, while goal is to be as bare bones as possible, reality is gogoc and
#   proper anon tunnel set up prior to install would most likely be best
# !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
#
# Copyright (C) 2014 - 2016 Uvea I. S., Kevin Rattai
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

USER=`whoami`
CRONLOC=/var/spool/cron/crontabs
# CRONCOMMFILE=/tmp/cron_comm_file.sh
CRONCOMMFILE="${HOME}/testcron.sh"
CRONGREP=$(crontab -l | cat )

IPe0=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f 1)
MACe0=$(ip link show eth0 | awk '/ether/ {print $2}')

cd $HOME

# set wireless first if anticipated, set token and reboot
if [ -f "${HOME}/scripts/interfaces" ]; then
    sudo mv $HOME/scripts/interfaces /etc/network
    sleep 3
    sudo reboot
fi

# Discover network availability
#

net_wait=0

# Repeat for 5 minutes, or 10 cycles, until network available or still no network
while [ ! -f "${NETWORK_SYS}" ] && [ $net_wait < 10 ]; do

    # is github there?
    ping -c 1 github.com

    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    # use this as reference for future feature to grab install file immediately from net
    if [ $? -eq 0 ]; then
        touch $NETWORK_SYS
        echo "Internet available."
        wget -N -nd -w 3 -P scripts --limit-rate=50k https://raw.githubusercontent.com/krattai/AEBL/master/installer/pre_first_boot/create-aebl.sh
    else
        rm $NETWORK_SYS
        net_wait=net_wait+1
        echo "No Internet available - $net_wait of 10"
        sleep 30
    fi

done

if [ ! -f "scripts/create-aebl.sh" ]; then
    setterm -blank 1
    chmod 755 scripts/create-aebl.sh
    scripts/create-aebl.sh &
else
    echo "Internet connection not established, install failed!"
fi

exit

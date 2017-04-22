#!/bin/bash
# This script preps the pi for use on the AEBL framework
#
# Copyright (C) 2015 - 2017 Uvea I. S., Kevin Rattai
#
# Useage:

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
SCRPT_DIR="/home/pi/.scripts"
BKUP_DIR="/home/pi/.backup"
T_SCR="/run/shm/scripts"

USER=`whoami`
CRONLOC=/var/spool/cron/crontabs
# CRONCOMMFILE=/tmp/cron_comm_file.sh
CRONCOMMFILE="${HOME}/testcron.sh"
CRONGREP=$(crontab -l | cat )

IPe0=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f 1)
MACe0=$(ip link show eth0 | awk '/ether/ {print $2}')

cd $HOME

# remount /run/shm and create scripts path with -pi credentials
sudo mount -o exec,remount /run/shm
sudo -u pi mkdir /run/shm/scripts

# Discover network availability
#

net_wait=0

# Repeat for 5 minutes, or 10 cycles, until network available or still no network
while [ ! -f "${NETWORK_SYS}" ] && [ $net_wait -lt 10 ]; do

    # is github there?
    ping -c 1 github.com

    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    # use this as reference for future feature to grab install file immediately from net
    if [ $? -eq 0 ]; then
        touch $NETWORK_SYS
        echo "Internet available."

        # get, install, and run entertainment video script
        wget -N -nd -w 3 --limit-rate=50k https://raw.githubusercontent.com/krattai/AEBL/master/installer/pre_first_boot/inst_ext.sh
        chmod 755 inst_ext.sh
        mv inst_ext.sh $T_SCR/inst_ext.sh
        $T_SCR/./inst_ext.sh &

    else
        rm $NETWORK_SYS
        net_wait=net_wait+1
        sleep 30
    fi

done

rm .local

if [ ! -f "${LOCAL_SYS}" ] && [ ! -f "${NETWORK_SYS}" ]; then
    touch .offline
    echo "No network available."
    exit 1
else
    rm .offline
fi

# set sys type scripts
if [ -f "$HOME/aeblsys" ]; then
    systype="casys0092.sh"
    sysloc="AEBL/master/installer/aeblv0092"
    rm $HOME/aeblsys
fi

if [ -f "$HOME/aeblvm" ]; then
    systype="casys0092.sh"
    sysloc="AEBL/master/installer/aeblv0092"
# do not remove until casys started
#    rm $HOME/aeblvm
fi

if [ -f "$HOME/idetsys" ]; then
    systype="cidet0092.sh"
    sysloc="detrot/master/src"
    rm $HOME/idetsys
fi

if [ -f "$HOME/irotsys" ]; then
    systype="cirot0092.sh"
    sysloc="detrot/master/src"
    rm $HOME/irotsys
fi

# prep file directories
mkdir ${BKUP_DIR}
mkdir ${SCRPT_DIR}
mkdir ${BIN_DIR}
mkdir /home/pi/tmp

export PATH=$PATH:${BIN_DIR}:$HOME/scripts:${SCRPT_DIR}

sudo mount -o exec,remount /run/shm
sudo mount -o remount,size=128M /dev/shm
mkdir /run/shm/scripts

# Get necessary AEBL files
# this should also be used if there's anything else that was missed
# in the initial AEBL fw setup, inclding packages or config
# where the subsequent scripts should only setup unique types
#

if [ ! -f "${OFFLINE_SYS}" ]; then

    if [ -f "${LOCAL_SYS}" ]; then

        wget -N -nd -w 3 -P ${SCRPT_DIR} --limit-rate=50k http://192.168.200.6/files/${systype}

    else

        wget -N -nd -w 3 -P ${SCRPT_DIR} --limit-rate=50k "https://raw.githubusercontent.com/krattai/${sysloc}/${systype}"

    fi

fi

chmod 755 ${SCRPT_DIR}/${systype}

# grab all new sys files prior to installing AEBL type
sudo apt-get -y install gogoc dos2unix apache2

# set up type and end gracefully
${SCRPT_DIR}/./${systype} &

rm $HOME/scripts/create-aebl.sh
rm $HOME/scripts/create-atyp.sh

exit

#!/bin/bash
# This script preps the pi for use on the AEBL framework
#
# Copyright (C) 2015 Uvea I. S., Kevin Rattai
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

USER=`whoami`
CRONLOC=/var/spool/cron/crontabs
# CRONCOMMFILE=/tmp/cron_comm_file.sh
CRONCOMMFILE="${HOME}/testcron.sh"
CRONGREP=$(crontab -l | cat )

IPe0=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f 1)
MACe0=$(ip link show eth0 | awk '/ether/ {print $2}')

cd $HOME

# Discover network availability
#

ping -c 1 8.8.8.8

if [ $? -eq 0 ]; then
    touch .network
    echo "Internet available."
else
    rm .network
fi

# ping -c 1 192.168.200.6

# if [[ $? -eq 0 ]]; then
#     touch .local
#     echo "Local network available."
# else
#     rm .local
# fi

if [ ! -f "${LOCAL_SYS}" ] && [ ! -f "${NETWORK_SYS}" ]; then
    touch .offline
    echo "No network available."
    exit 1
else
    rm .offline
fi

# set sys type scripts
if [ -f "$HOME/aeblsys" ]; then
    systype="casys0091.sh"
    sysloc="71aq3kkcs15dosv"
    rm $HOME/aeblsys
fi

if [ -f "$HOME/aeblvm" ]; then
    systype="casys0091.sh"
    sysloc="71aq3kkcs15dosv"
# do not remove until casys started
#    rm $HOME/aeblvm
fi

if [ -f "$HOME/idetsys" ]; then
    systype="cidet0091.sh"
    sysloc="x1i74qtze2gnqib"
    rm $HOME/idetsys
fi

if [ -f "$HOME/irotsys" ]; then
    systype="cirot0091.sh"
    sysloc="13fvgo3hfa5d449"
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

        wget -N -nd -w 3 -P ${SCRPT_DIR} --limit-rate=50k "https://www.dropbox.com/s/${sysloc}/${systype}"

    fi

fi

chmod 777 ${SCRPT_DIR}/${systype}

# grab all new sys files prior to installing AEBL type
sudo apt-get -y install gogoc dos2unix

# set up type and end gracefully
${SCRPT_DIR}/./${systype} &

rm $HOME/scripts/create-aebl.sh
rm $HOME/scripts/create-atyp.sh

exit

#!/bin/bash
# This script preps the pi for use on the AEBL framework
# The AEBL img is not a pure raspbian image, some unique
# updates were performed to achieve base img
#
# Copyright (C) 2014 Uvea I. S., Kevin Rattai
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

# is google there?
ping -c 1 8.8.8.8

if [ $? -eq 0 ]; then
    touch .network
    echo "Internet available."
else
    rm .network
fi

# is it on test/home network?
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
    exit 1
else
    rm .offline
fi

# change hostname, from:
# http://pricklytech.wordpress.com/2013/04/24/ubuntu-change-hostname-permanently-using-the-command-line/

#Assign existing hostname to $hostn
hostn=$(cat /etc/hostname)

#Display existing hostname
# echo "Existing hostname is $hostn"

# Set new hostname $newhost
# echo "Enter new hostname: "
# read newhost
if [ -f "$HOME/aeblsys" ]; then
    newhost="aeblsys"
fi

if [ -f "$HOME/idetsys" ]; then
    newhost="idetsys"
fi

if [ -f "$HOME/irotsys" ]; then
    newhost="irotsys"
fi

#change hostname in /etc/hosts & /etc/hostname
sudo sed -i "s/${hostn}/${newhost}/g" /etc/hosts
sudo sed -i "s/${hostn}/${newhost}/g" /etc/hostname

sudo hostname ${newhost}

# set IPv6 enabled

sudo chown pi:pi /etc/modules
echo "ipv6" >> /etc/modules
sudo chown root:root /etc/modules

mkdir ${TEMP_DIR}
mkdir ${MP3_DIR}
mkdir ${MP4_DIR}
mkdir ${PL_DIR}
mkdir ${CTRL_DIR}
mkdir ${BIN_DIR}

chmod 777 ${MP3_DIR}
chmod 777 ${MP4_DIR}
chmod 777 ${PL_DIR}
chmod 777 ${CTRL_DIR}

export PATH=$PATH:${BIN_DIR}:$HOME/scripts

# Get necessary AEBL files
#

if [ ! -f "${OFFLINE_SYS}" ]; then

    if [ -f "${LOCAL_SYS}" ]; then

        wget -N -nd -w 3 -P ${TEMP_DIR} --limit-rate=50k http://192.168.200.6/files/aeblcurr

        cur_file=$(cat "${TEMP_DIR}/aeblcurr" | head -n1)

        wget -N -nd -w 3 -P ${TEMP_DIR} --limit-rate=50k http://192.168.200.6/files/${cur_file}

    else

        wget -N -nd -w 3 -P ${TEMP_DIR} --limit-rate=50k "https://www.dropbox.com/s/ee4vepd4kbn84d7/aeblcurr"

        cur_file=$(cat "${TEMP_DIR}/aeblcurr" | head -n1)
        dbox_file=$(cat "${TEMP_DIR}/aeblcurr" | tail -n1)

        wget -N -nd -w 3 -P ${TEMP_DIR} --limit-rate=50k "https://www.dropbox.com/s/${dbox_file}/${cur_file}"
    fi

    cd ${TEMP_DIR}

    unzip ${cur_file}

    rm ${cur_file}

    cd $HOME

    sudo apt-get update

    sudo apt-get -y install fbi samba samba-common-bin libnss-mdns lsof

    sudo rpi-update

    # running rpi-wiggle in background so script has chance to
    # end gracefully
    chmod 777 ${TEMP_DIR}/mk-aebl.sh
    ${TEMP_DIR}/./mk-aebl.sh

    # system should be in timed reboot state, so clean up and exit

    rm ${TEMP_DIR}/*

    rmdir ${TEMP_DIR}

fi

exit

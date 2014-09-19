#!/bin/bash
# This script sets up airtime for AEBL use
# It adds the AEBL controller scripts to airtime installation and sets up
#   zerconf and IPv6 capacity.  The VM will be pre-created, so env known.
#
# Copyright (C) 2014 Uvea I. S., Kevin Rattai
#
# Useage:
# No useage, this is a standalone script

LOCAL_SYS="local"
NETWORK_SYS="network"
OFFLINE_SYS="offline"
# AEBL_SYS="/home/pi/.aeblsys"

# TEMP_DIR="/home/pi/tempdir"
# MP3_DIR="/home/pi/mp3"
# MP4_DIR="/home/pi/mp4"
# PL_DIR="/home/pi/pl"
# CTRL_DIR="/home/pi/ctrl"
# BIN_DIR="/home/pi/bin"
AEBL_DIR="/usr/share/airtime/public/aebl"

cd .

# Discover network availability
#

# is google there?
ping -c 1 8.8.8.8

if [ $? -eq 0 ]; then
    touch network
    echo "Internet available."
else
    rm network
fi

# is it on test/home network?
ping -c 1 192.168.200.6

if [[ $? -eq 0 ]]; then
    touch local
    echo "Local network available."
else
    rm local
fi

if [ ! -f "${LOCAL_SYS}" ] && [ ! -f "${NETWORK_SYS}" ]; then
    touch offline
    echo "No network available."
    exit 1
else
    rm offline
fi

# change hostname, from:
# http://pricklytech.wordpress.com/2013/04/24/ubuntu-change-hostname-permanently-using-the-command-line/

#Assign existing hostname to $hostn
hostn=$(cat /etc/hostname)

#Display existing hostname
echo "Existing hostname is $hostn"

# Set new hostname $newhost
# echo "Enter new hostname: "
# read newhost
newhost="aebl_airtime"

#change hostname in /etc/hosts & /etc/hostname
sudo sed -i "s/${hostn}/${newhost}/g" /etc/hosts
sudo sed -i "s/${hostn}/${newhost}/g" /etc/hostname

sudo hostname ${newhost}

echo "hostname set to $newhost"

# set IPv6 enabled
# assume 14.04 server already has IPv6 enabled

# sudo chown pi:pi /etc/modules
# echo "ipv6" >> /etc/modules
# sudo chown root:root /etc/modules

mkdir ${AEBL_DIR}

# Get necessary AEBL files
#

if [ ! -f "${OFFLINE_SYS}" ]; then

#     if [ -f "${LOCAL_SYS}" ]; then

#         wget -N -nd -w 3 -P ${TEMP_DIR} --limit-rate=50k http://192.168.200.6/files/aeblcurr

#         cur_file=$(cat "${TEMP_DIR}/aeblcurr" | head -n1)

#         wget -N -nd -w 3 -P ${TEMP_DIR} --limit-rate=50k http://192.168.200.6/files/${cur_file}

#     else

#         wget -N -nd -w 3 -P ${TEMP_DIR} --limit-rate=50k "https://www.dropbox.com/s/ee4vepd4kbn84d7/aeblcurr"

#         cur_file=$(cat "${TEMP_DIR}/aeblcurr" | head -n1)
#         dbox_file=$(cat "${TEMP_DIR}/aeblcurr" | tail -n1)

#         wget -N -nd -w 3 -P ${TEMP_DIR} --limit-rate=50k "https://www.dropbox.com/s/${dbox_file}/${cur_file}"
#     fi

#     cd ${TEMP_DIR}

#     unzip ${cur_file}

#     rm ${cur_file}

#     cd $HOME

    sudo apt-get update

# install samba avahi/zerconf lsof for smb share checking and gogoc for ipv6 tun
    sudo apt-get -y install samba samba-common-bin avahi-daemon avahi-discover libnss-mdns lsof gogoc

# make ctrl dir and set it to read/write/execute
    mkdir ${CTRL_DIR}
    mkdir ${BIN_DIR}

    chmod 777 ${CTRL_DIR}
    chmod 777 ${BIN_DIR}

# set smb and avahi, need to get files from server
    sudo rm /etc/samba/smb.conf
    sudo mv ${TEMP_DIR}/smb.conf /etc/samba
    sudo mv ${TEMP_DIR}/samba.service  /etc/avahi/services/



    # running rpi-wiggle in background so script has chance to
    # end gracefully
    chmod 777 ${TEMP_DIR}/mk-aebl.sh
    ${TEMP_DIR}/./mk-aebl.sh

    # system should be in timed reboot state, so clean up and exit

    rm ${TEMP_DIR}/*

    rmdir ${TEMP_DIR}

fi

exit

#!/bin/bash
# This script preps the pi for use on the AEBL framework
# The AEBL img is not a pure raspbian image, some unique
# updates were performed to achieve base img
#
# This script should be changed out as secondary installer accessed via internet
#   and the load script should install and configure IPv6 network and also
#   opennic to get files from aebl.oss
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


# May want to look into ensuring base dev tools for make/build/compile available

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

rm $NETWORK_SYS

# Discover network availability
#

net_wait=0

# Repeat for 5 minutes, or 5 cycles, until network available or still no network
while [ ! -f "${NETWORK_SYS}" ] && [ $net_wait -lt 10 ]; do

    # is google there?
    ping -c 1 8.8.8.8

    # !!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!
    # use this as reference for future feature to grab install file immediately from net
    if [ $? -eq 0 ]; then
        touch $NETWORK_SYS
        echo "Internet available."
    else
        rm $NETWORK_SYS
        net_wait=net_wait+1
        sleep 30
    fi

done

# force removal of possible local reference as not being used
rm .local

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
sudo modprobe ipv6
sudo /etc/init.d/networking restart
sleep 15s

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

    wget -N -nd -w 3 -P ${TEMP_DIR} --limit-rate=50k https://raw.githubusercontent.com/krattai/AEBL/master/core/aeblcurr

    cur_file=$(cat "${TEMP_DIR}/aeblcurr" | head -n1)

#     dbox_file=$(cat "${TEMP_DIR}/aeblcurr" | tail -n1)

#     wget -N -nd -w 3 -P ${TEMP_DIR} --limit-rate=50k "https://www.dropbox.com/s/${dbox_file}/${cur_file}"

    wget -N -nd -w 3 -P ${TEMP_DIR} --limit-rate=50k "https://github.com/krattai/AEBL/raw/master/installer/${cur_file}"

    cd ${TEMP_DIR}

    unzip -o ${cur_file}

    rm ${cur_file}

    cd $HOME

    sudo apt-get update

    sudo apt-get -y install fbi samba samba-common-bin libnss-mdns lsof gogoc

    # configure gogoc properly
    wget -N -nd -w 3 -P ${TEMP_DIR} --limit-rate=50k "https://raw.githubusercontent.com/krattai/AEBL/master/core/gogoc.conf"
    wget -N -nd -w 3 -P ${TEMP_DIR} --limit-rate=50k "https://raw.githubusercontent.com/krattai/AEBL/master/core/tsp-broker-list.txt"
    sudo rm /etc/gogoc/gogoc.conf
    sudo mv ${TEMP_DIR}/gogoc.conf /etc/gogoc/gogoc.conf
    sudo chown root:root /etc/gogoc/gogoc.conf
    sudo rm /var/lib/gogoc/tsp-broker-list.txt
    sudo mv ${TEMP_DIR}/tsp-broker-list.txt /var/lib/gogoc/tsp-broker-list.txt
    sudo chown root:root /var/lib/gogoc/tsp-broker-list.txt
    sudo service gogoc restart

    sleep 10s

    sudo SKIP_WARNING=1 rpi-update

    # running rpi-wiggle in background so script has chance to
    # end gracefully
    chmod 777 ${TEMP_DIR}/mk-aebl.sh
    ${TEMP_DIR}/./mk-aebl.sh

    # system should be in timed reboot state, so clean up and exit

    rm ${TEMP_DIR}/*

    rmdir ${TEMP_DIR}

fi

exit

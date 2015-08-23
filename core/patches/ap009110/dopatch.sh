#!/bin/bash
# Performs patch
#
# Copyright (C) 2014 Uvea I. S., Kevin Rattai
#
# Useage:
# wget -N -r -nd -l2 -w 3 -P $HOME --limit-rate=50k http://192.168.200.6/files/create-asys.sh; chmod 777 $HOME/create-asys.sh; $HOME/./create-asys.sh; rm $HOME/create-asys.sh
# or
# wget -N -r -nd -l2 -w 3 -P $HOME --limit-rate=50k "https://www.dropbox.com/s/1t3ejk4iyzm07u6/create-asys.sh"; chmod 777 $HOME/create-asys.sh; $HOME/./create-asys.sh; rm $HOME/create-asys.sh

# patch system now seeking network info in /run/shm
LOCAL_SYS=".local"
NETWORK_SYS=".network"
OFFLINE_SYS=".offline"
AEBL_TEST="/home/pi/.aebltest"
AEBL_SYS="/home/pi/.aeblsys"
AEBL_VM="/home/pi/.aeblvm"
IHDN_TEST="/home/pi/.ihdntest"
IHDN_SYS="/home/pi/.ihdnsys"
IHDN_DET="/home/pi/.ihdndet"

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

# if not AEBL_SYS and previously set to be, then remove
if [ -f "${LOCAL_SYS}" ] && [ ! -f "${NETWORK_SYS}" ]; then
    touch .offline
    echo "No network available."
else
    rm .offline
fi

export PATH=$PATH:${BIN_DIR}:$HOME/scripts

# set system version type

if [ -f "${LOCAL_SYS}" ]; then
    if [ -f "${AEBL_SYS}" ] || [ -f "${AEBL_VM}" ] || [ -f $HOME/.aebltest ]; then
        touch $HOME/.alpha
    fi
    if [ -f "${IHDN_SYS}" ]; then
        touch $HOME/.beta
    fi
    if [ ! -f $HOME/.alpha ] && [ ! -f $HOME/.beta ]; then
        touch $HOME/.production
    fi
else
    if [ -f "${AEBL_SYS}" ] || [ -f "${AEBL_VM}" ]; then
        touch $HOME/.beta
    fi
    if [ ! -f $HOME/.alpha ] && [ ! -f $HOME/.beta ]; then
        touch $HOME/.production
    fi
fi

# create config file
C_FILE="${HOME}/.config"
touch ${C_FILE}

if [ -f $HOME/.alpha ]; then
    echo "ALPHA" >> ${C_FILE}
fi
if [ -f $HOME/.beta ]; then
    echo "BETA" >> ${C_FILE}
fi
if [ -f $HOME/.production ]; then
    echo "PRODUCTION" >> ${C_FILE}
fi

echo "ETHERNET" >> ${C_FILE}
IPe0=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f 1)
echo ${IPe0} >> ${C_FILE}
echo "WIRELESS" >> ${C_FILE}
IPw0=$(ip addr show wlan0 | awk '/inet / {print $2}' | cut -d/ -f 1)
echo ${IPw0} >> ${C_FILE}
echo "PUBLIC" >> ${C_FILE}
echo "this will show public facing IP" >> ${C_FILE}

echo "# hardware type" >> ${C_FILE}
echo "unknown" >> ${C_FILE}

# check if not AEBL VM and if not, should be raspbian and should update
if [ ! -f "${AEBL_VM}" ]; then
    sudo apt-get update
fi

# install apache for core interface
sudo apt-get -y install apache2

# From note on apache2 firstrun page
#  You should replace this file (located at /var/www/html/index.html) before continuing to operate your HTTP server.

# check if not AEBL VM and if not, different apache2 dir used
if [ ! -f "${AEBL_VM}" ]; then
    wget -N -nd -w 3 -P tmp --limit-rate=50k https://raw.githubusercontent.com/krattai/AEBL/master/interfaces/base_iface/index.html
    sudo rm /var/www/index.html
    sudo mv tmp/index.html /var/www/index.html
    sudo mkdir /var/www/images
    wget -N -nd -w 3 -P tmp --limit-rate=50k https://raw.githubusercontent.com/krattai/AEBL/master/interfaces/base_iface/images/AEBL_thumb_00.png
    sudo mv tmp/AEBL_thumb_00.png /var/www/images/AEBL_thumb_00.png
    wget -N -nd -w 3 -P tmp --limit-rate=50k https://raw.githubusercontent.com/krattai/AEBL/master/interfaces/base_iface/images/valid-xhtml10.png
    sudo mv tmp/valid-xhtml10.png /var/www/images/valid-xhtml10.png
else
    wget -N -nd -w 3 -P tmp --limit-rate=50k https://raw.githubusercontent.com/krattai/AEBL/master/interfaces/base_iface/index.html
    sudo rm /var/www/html/index.html
    sudo mv tmp/index.html /var/www/html/index.html
    sudo mkdir /var/www/html/images
    wget -N -nd -w 3 -P tmp --limit-rate=50k https://raw.githubusercontent.com/krattai/AEBL/master/interfaces/base_iface/images/AEBL_thumb_00.png
    sudo mv tmp/AEBL_thumb_00.png /var/www/html/images/AEBL_thumb_00.png
    wget -N -nd -w 3 -P tmp --limit-rate=50k https://raw.githubusercontent.com/krattai/AEBL/master/interfaces/base_iface/images/valid-xhtml10.png
    sudo mv tmp/valid-xhtml10.png /var/www/html/images/valid-xhtml10.png
fi

mv startup.sh $HOME/.scripts
chmod 777 $HOME/.scripts/startup.sh
cp $HOME/.scripts/startup.sh $HOME/.backup/scripts
cp $HOME/.scripts/startup.sh /run/shm/scripts

mv ctrlwtch.sh $HOME/.scripts
chmod 777 $HOME/.scripts/ctrlwtch.sh
cp $HOME/.scripts/ctrlwtch.sh $HOME/.backup/scripts
cp $HOME/.scripts/ctrlwtch.sh /run/shm/scripts

sleep 5

GRAB_FILE="pv"
pv=$(cat "${GRAB_FILE}" | head -n1)

# if [ ! -f "${OFFLINE_SYS}" ]; then
#     $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic @kratt, ${MACe0} patched to ${pv}." &
# fi
if [ ! -f "${OFFLINE_SYS}" ]; then
    if [ -f $HOME/.alpha ]; then
#       $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic @kratt, alpha ${MACe0} patched to ${pv}." &
        # express that AEBL device being installed
        ext_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
mosquitto_pub -d -t hello/world -m "$(date) : AEBL Pi alpha patched to ${pv}. ${MACe0} IP is $ext_ip" -h "uveais.ca"
    fi
    if [ -f $HOME/.beta ]; then
#       $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic @kratt, beta ${MACe0} patched to ${pv}." &
        # express that AEBL device being installed
        ext_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
mosquitto_pub -d -t hello/world -m "$(date) : AEBL Pi beta patched to ${pv}. ${MACe0} IP is $ext_ip" -h "uveais.ca"
    fi
    if [ -f $HOME/.production ]; then
#       $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic @kratt, production ${MACe0} patched to ${pv}." &
        # express that AEBL device being installed
        ext_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
mosquitto_pub -d -t hello/world -m "$(date) : AEBL Pi production patched to ${pv}. ${MACe0} IP is $ext_ip" -h "uveais.ca"
    fi
fi

exit

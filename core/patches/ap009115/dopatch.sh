#!/bin/bash
# Performs patch
#
# Copyright (C) 2015 Uvea I. S., Kevin Rattai
# BSD license https://raw.githubusercontent.com/krattai/AEBL/master/LICENSE
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

if [ -f "${LOCAL_SYS}" ] && [ ! -f "${NETWORK_SYS}" ]; then
    touch .offline
    echo "No network available."
else
    rm .offline
fi

# install on AEBL VM appliances and also enable cgi-mod
# if [ ! -f "${AEBL_VM}" ]; then
#     sudo apt-get install build-essential
#     sudo a2enmod cgi
#     sudo service apache2 restart
# fi

# leave temporarily as reference if eventually install php
# sudo apt-get install php5-common libapache2-mod-php5 php5-cli

# if not AEBL_SYS and previously set to be, then remove
#  this process may not have been done, yet

# Begin main patch application
export PATH=$PATH:${BIN_DIR}:$HOME/scripts

# If not applied in previous patch
# set system version type

# if [ ! -f $HOME/.alpha ] && [ ! -f $HOME/.beta ] && [ ! -f $HOME/.production ]; then
#     if [ -f "${LOCAL_SYS}" ]; then
#         if [ -f "${AEBL_SYS}" ] || [ -f "${AEBL_VM}" ] || [ -f $HOME/.aebltest ]; then
#             touch $HOME/.alpha
#         fi
#         if [ -f "${IHDN_SYS}" ]; then
#             touch $HOME/.beta
#         fi
#         if [ ! -f $HOME/.alpha ] && [ ! -f $HOME/.beta ]; then
#             touch $HOME/.production
#         fi
#     else
#         if [ -f "${AEBL_SYS}" ] || [ -f "${AEBL_VM}" ]; then
#             touch $HOME/.beta
#         fi
#         if [ ! -f $HOME/.alpha ] && [ ! -f $HOME/.beta ]; then
#             touch $HOME/.production
#         fi
#     fi
# fi

# create config file
# C_FILE="${HOME}/.config"
#in case it exists, remove it
# rm ${C_FILE}
# touch ${C_FILE}

# if [ -f $HOME/.alpha ]; then
#     echo "ALPHA" >> ${C_FILE}
# fi
# if [ -f $HOME/.beta ]; then
#     echo "BETA" >> ${C_FILE}
# fi
# if [ -f $HOME/.production ]; then
#     echo "PRODUCTION" >> ${C_FILE}
# fi

# echo "ETHERNET" >> ${C_FILE}
# IPe0=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f 1)
# echo ${IPe0} >> ${C_FILE}
# echo "WIRELESS" >> ${C_FILE}
# IPw0=$(ip addr show wlan0 | awk '/inet / {print $2}' | cut -d/ -f 1)
# echo ${IPw0} >> ${C_FILE}
# echo "PUBLIC" >> ${C_FILE}
# echo "this will show public facing IP" >> ${C_FILE}

# echo "# hardware type" >> ${C_FILE}
# echo "unknown" >> ${C_FILE}

# add new appliance interface content
if [ ! -f "${AEBL_VM}" ]; then
    sudo rm /var/www/index.html
    sudo mv index.html /var/www/index.html
    sudo rm /var/www/config.html
    sudo mv config.html /var/www/config.html
    sudo rm /var/www/blades.html
    sudo mv blades.html /var/www/blades.html
    sudo rm /var/www/system.html
    sudo mv system.html /var/www/system.html
    sudo rm /var/www/about.html
    sudo mv about.html /var/www/about.html
else
    sudo rm /var/www/html/index.html
    sudo mv index.html /var/www/html/index.html
    sudo rm /var/www/html/config.html
    sudo mv config.html /var/www/html/config.html
    sudo rm /var/www/html/blades.html
    sudo mv blades.html /var/www/html/blades.html
    sudo rm /var/www/html/system.html
    sudo mv system.html /var/www/html/system.html
    sudo rm /var/www/html/about.html
    sudo mv about.html /var/www/html/about.html
fi

# reference for proper setting of cgi for http interface
# sudo chown root:root /usr/lib/cgi-bin/sysview_cgi.sh

sudo mv patch_cgi.sh /usr/lib/cgi-bin/
sudo chown root:root /usr/lib/cgi-bin/patch_cgi.sh
sudo chmod 0755 /usr/lib/cgi-bin/patch_cgi.sh
sudo mv reboot_cgi.sh /usr/lib/cgi-bin/
sudo chown root:root /usr/lib/cgi-bin/reboot_cgi.sh
sudo chmod 0755 /usr/lib/cgi-bin/reboot_cgi.sh
sudo mv showcfg_cgi.sh /usr/lib/cgi-bin/
sudo chown root:root /usr/lib/cgi-bin/showcfg_cgi.sh
sudo chmod 0755 /usr/lib/cgi-bin/showcfg_cgi.sh
sudo mv shutdown_cgi.sh /usr/lib/cgi-bin/
sudo chown root:root /usr/lib/cgi-bin/shutdown_cgi.sh
sudo chmod 0755 /usr/lib/cgi-bin/shutdown_cgi.sh
sudo mv sysview_cgi.sh /usr/lib/cgi-bin/
sudo chown root:root /usr/lib/cgi-bin/sysview_cgi.sh
sudo chmod 0755 /usr/lib/cgi-bin/sysview_cgi.sh

# remove uptime.sh if exists, as replaced by sysview_cgi.sh
sudo rm /usr/lib/cgi-bin/uptime.sh

# Add or update general scripts
mv ctrlwtch.sh $HOME/.scripts
chmod 777 $HOME/.scripts/ctrlwtch.sh
cp $HOME/.scripts/ctrlwtch.sh $HOME/.backup/scripts
cp $HOME/.scripts/ctrlwtch.sh /run/shm/scripts

mv prs.sh $HOME/.scripts
chmod 777 $HOME/.scripts/prs.sh
cp $HOME/.scripts/prs.sh $HOME/.backup/scripts
cp $HOME/.scripts/prs.sh /run/shm/scripts

sleep 5

GRAB_FILE="pv"
pv=$(cat "${GRAB_FILE}" | head -n1)

# if [ ! -f "${OFFLINE_SYS}" ]; then
#     $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic @kratt, ${MACe0} patched to ${pv}." &
# fi
if [ ! -f "${OFFLINE_SYS}" ]; then
    if [ -f $HOME/.alpha ]; then
      $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic @kratt, alpha ${MACe0} patched to ${pv}." &
    fi
    if [ -f $HOME/.beta ]; then
      $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic @kratt, beta ${MACe0} patched to ${pv}." &
    fi
    if [ -f $HOME/.production ]; then
      $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic @kratt, production ${MACe0} patched to ${pv}." &
    fi
fi

exit

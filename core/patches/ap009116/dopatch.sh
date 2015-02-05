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
#
# Interesting script to check OS
#
# if [ "$(uname)" == "Darwin" ]; then
    # Do something under Mac OS X platform        
# elif [ "$(expr substr $(uname -s) 1 5)" == "Linux" ]; then
    # Do something under Linux platform
# elif [ "$(expr substr $(uname -s) 1 10)" == "MINGW32_NT" ]; then
    # Do something under Windows NT platform
# fi
#
#
# With sudo apt-get install lsb-release installed on raspbian (ubuntu has)
#
# OS=$(lsb_release -si)        - raspbian shows Debian, ubuntu shows ubuntu
# ARCH=$(uname -m | sed 's/x86_//;s/i[3-6]86/32/')
# VER=$(lsb_release -sr)       - raspbian shows wheezy, ubuntu shows current

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

# Begin main patch application
export PATH=$PATH:${BIN_DIR}:$HOME/scripts

# Add dnsutils to raspbian for future consideration
if [ ! -f "${AEBL_VM}" ]; then
    sudo apt-get update && sudo apt-get -y dist-upgrade
    sudo apt-get -y install dnsutils lsb-release
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
sudo mv system_cgi.sh /usr/lib/cgi-bin/
sudo chown root:root /usr/lib/cgi-bin/system_cgi.sh
sudo chmod 0755 /usr/lib/cgi-bin/system_cgi.sh
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

# set control file to indicate new ctrlwtch.sh file
touch /home/pi/ctrl/.newctrl

# clearing log.txt as some are getting extremely large
#  will address log sizes in a near patch
rm /home/pi/log.txt

GRAB_FILE="pv"
pv=$(cat "${GRAB_FILE}" | head -n1)

# if [ ! -f "${OFFLINE_SYS}" ]; then
#     $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic @kratt, ${MACe0} patched to ${pv}." &
# fi
# if [ ! -f "${OFFLINE_SYS}" ]; then
#     if [ -f $HOME/.alpha ]; then
#       $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic @kratt, alpha ${MACe0} patched to ${pv}." &
#     fi
#     if [ -f $HOME/.beta ]; then
#       $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic @kratt, beta ${MACe0} patched to ${pv}." &
#     fi
#     if [ -f $HOME/.production ]; then
#       $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic @kratt, production ${MACe0} patched to ${pv}." &
#     fi
# fi

exit

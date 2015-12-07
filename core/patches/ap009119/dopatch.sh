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
# if [ ! -f "${AEBL_VM}" ]; then
#     sudo apt-get update && sudo apt-get -y dist-upgrade
#     sudo apt-get -y install dnsutils lsb-release
# fi

# Change default html path from /var/www/html to /var/www for AEBL VM (Ubuntu)
#  includes changing apache default www root
# if [ -f "${AEBL_VM}" ]; then

    # move html
#     sudo mv /var/www/html/about.html /var/www/
#     sudo mv /var/www/html/blades.html /var/www/
#     sudo mv /var/www/html/config.html /var/www/
#     sudo mv /var/www/html/index.html /var/www/
#     sudo mv /var/www/html/system.html /var/www/
    
    # move images
#     sudo mkdir /var/www/images
#     sudo mv /var/www/html/images/AEBL_thumb_00.png /var/www/images/
#     sudo mv /var/www/html/images/valid-xhtml10.png /var/www/images/
#     sudo rmdir /var/www/html/images
#     sudo rmdir /var/www/html

    # Copy new apache2 default config file
    # 600 : Only owner can read/write
    # 644 : Only owner can write, others can read
    # 666 : All uses can read/write.
#    sudo mv default /etc/apache2/sites-available/
#    sudo chown root:root /etc/apache2/sites-available/default
#    sudo chmod 0644 /etc/apache2/sites-available/default

    # Enable and disable sites
    # This may not be enough to change default, may need to dig deeper
    # nope, looks like /etc/apache2/apache2.conf has /var/www as granted
#    sudo a2dissite 000-default.conf
#    sudo mv /etc/apache2/sites-available/default /etc/apache2/sites-available/default.conf
#    sudo a2ensite default
    
    # Of course, apache2 needs to restart
#    sudo service apache2 restart
    
# fi

# reference for proper setting of cgi for http interface
# sudo mv reboot_cgi.sh /usr/lib/cgi-bin/
# sudo chown root:root /usr/lib/cgi-bin/sysview_cgi.sh
# sudo chmod 0755 /usr/lib/cgi-bin/patch_cgi.sh

# previous update changed firmware improperly on detectors.  Need to force revert.
# not sure if already applied, so leaving this for patch 18
#
# if [ -f "/home/pi/.ihdndet" ]; then
#     sudo rm /boot/.firmware_revision
#     sudo rpi-update d9eb023ba98317d81fc53a3f9d6752b127a8dbbf

    # wait 10 minutes, then reboot
#     sudo shutdown -r +10 &
# fi

# dos2unix not installed on some systems
sudo apt-get install dos2unix

# get noo-ebs installer and run it
wget -N -nd -w 3 -P ${TEMP_DIR}/patch --limit-rate=50k "https://raw.githubusercontent.com/krattai/noo-ebs/master/src/install.sh"
chmod 777 ${TEMP_DIR}/patch/install.sh
${TEMP_DIR}/patch/./install.sh
rm ${TEMP_DIR}/patch/install.sh

# get pub.sh as generic, initial message publisher
wget -N -nd -w 3 -P ${TEMP_DIR}/patch --limit-rate=50k "https://raw.githubusercontent.com/krattai/noo-ebs/master/ref_code/mqtt/pub.sh"
mv ${TEMP_DIR}/patch/pub.sh $HOME/.scripts
chmod 777 $HOME/.scripts/pub.sh
cp $HOME/.scripts/pub.sh $HOME/.backup/scripts
cp $HOME/.scripts/pub.sh /run/shm/scripts

# Add or update general scripts
# mv ctrlwtch.sh $HOME/.scripts
# chmod 777 $HOME/.scripts/ctrlwtch.sh
# cp $HOME/.scripts/ctrlwtch.sh $HOME/.backup/scripts
# cp $HOME/.scripts/ctrlwtch.sh /run/shm/scripts

# updated l-ctrl.sh to include new channels
# mv l-ctrl.sh $HOME/.scripts
# chmod 777 $HOME/.scripts/l-ctrl.sh
# cp $HOME/.scripts/l-ctrl.sh $HOME/.backup/scripts
# cp $HOME/.scripts/l-ctrl.sh /run/shm/scripts

sleep 5

# set control file to indicate new ctrlwtch.sh file
# touch /home/pi/ctrl/.newctrl

# clearing log.txt as some are getting extremely large
#  will address log sizes in a near patch
rm /home/pi/log.txt

GRAB_FILE="pv"
pv=$(cat "${GRAB_FILE}" | head -n1)

# Announce patch to MQTT

# if [ ! -f "${OFFLINE_SYS}" ]; then
#     $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic @kratt, ${MACe0} patched to ${pv}." &
# fi
if [ ! -f "${OFFLINE_SYS}" ]; then
    if [ -f $HOME/.alpha ]; then
        # express that AEBL device being installed
        ext_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
        mosquitto_pub -d -t hello/world -m "$(date) : AEBL Pi alpha patched to ${pv}. ${MACe0} IP is $ext_ip" -h "uveais.ca"
    fi
    if [ -f $HOME/.beta ]; then
        # express that AEBL device being installed
        ext_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
        mosquitto_pub -d -t hello/world -m "$(date) : AEBL Pi beta patched to ${pv}. ${MACe0} IP is $ext_ip" -h "uveais.ca"
    fi
    if [ -f $HOME/.production ]; then
        # express that AEBL device being installed
        ext_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
        mosquitto_pub -d -t hello/world -m "$(date) : AEBL Pi production patched to ${pv}. ${MACe0} IP is $ext_ip" -h "uveais.ca"
    fi
fi

exit

#!/bin/bash
# This script makes the AEBL framework
#
# Copyright (C) 2014 - 2016 Uvea I. S., Kevin Rattai
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

USER=`whoami`
CRONLOC=/var/spool/cron/crontabs
# CRONCOMMFILE=/tmp/cron_comm_file.sh
CRONCOMMFILE="${HOME}/testcron.sh"
CRONGREP=$(crontab -l | cat )

IPe0=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f 1)
MACe0=$(ip link show eth0 | awk '/ether/ {print $2}')

cd $HOME

# Check for Pi 2 hardware
cat /proc/cpuinfo | grep a01041
if [ $? -eq 0 ]; then
    touch .p2
    echo "Sony Pi 2."
fi
cat /proc/cpuinfo | grep a21041
if [ $? -eq 0 ]; then
    touch .p2
    echo "Embest Pi 2."
fi

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
    else
        rm $NETWORK_SYS
        net_wait=net_wait+1
        sleep 30
    fi

done

if [ ! -f "${LOCAL_SYS}" ] && [ ! -f "${NETWORK_SYS}" ]; then
    touch .offline
    echo "No network available."
    exit 1
else
    rm .offline
fi

export PATH=$PATH:${BIN_DIR}:$HOME/scripts

# get noo-ebs installer and run it
wget -N -nd -w 3 -P ${TEMP_DIR}/patch --limit-rate=50k "https://raw.githubusercontent.com/krattai/noo-ebs/master/src/install.sh"
chmod 777 ${TEMP_DIR}/patch/install.sh
${TEMP_DIR}/patch/./install.sh
rm ${TEMP_DIR}/patch/install.sh

# express that AEBL device being installed
ext_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
# mosquitto_pub -d -t hello/world -m "$(date) : AEBL being installed. IP is $ext_ip" -h "uveais.ca"
# AEBL MQTT broker 2001:5c0:1100:dd00:240:63ff:fefd:d3f1
# mosquitto_pub -d -t aebl/info -m "$(date) : AEBL being installed. IP is $ext_ip" -h "2001:5c0:1100:dd00:240:63ff:fefd:d3f1"

mosquitto_pub -d -t ihdn/aebl/info -m "$(date) : AEBL being installed. IP is $ext_ip" -h "ihdn.ca"

# Process necessary AEBL files
#

sudo mv ${TEMP_DIR}/AEBL_00.png /etc

sudo mv ${TEMP_DIR}/asplash.sh /etc/init.d

sudo chmod a+x /etc/init.d/asplash.sh

sudo insserv /etc/init.d/asplash.sh

sudo rm /etc/init.d/bootup.sh
sudo mv ${TEMP_DIR}/afwbootup.sh /etc/init.d/bootup.sh
sudo chmod 755 /etc/init.d/bootup.sh
sudo update-rc.d bootup.sh defaults

mv ${TEMP_DIR}/create-atyp.sh scripts
chmod 777 scripts/create-atyp.sh

# express that AEBL device SD card expansion beginning
ext_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
# mosquitto_pub -d -t aebl/info -m "$(date) : AEBL SD card being expanded. IP is $ext_ip" -h "2001:5c0:1100:dd00:240:63ff:fefd:d3f1"

mosquitto_pub -d -t ihdn/aebl/info -m "$(date) : AEBL SD card being expanded. IP is $ext_ip" -h "ihdn.ca"

# rpi-wiggle MUST be last item, as it reboots the system
# not applicable if aeblvm

if [ ! -f "$HOME/aeblvm" ]; then
    cat ${TEMP_DIR}/rpi-wiggle.lic

    chmod 777 ${TEMP_DIR}/rpi-wiggle.sh

    # sleep 5 seconds to ensure system ready for reboot
    echo "Processing files.  Please wait."
    sleep 5

    # running rpi-wiggle in background so script has chance to
    # end gracefully
    sudo ${TEMP_DIR}/./rpi-wiggle.sh
fi

if [ -f "$HOME/aeblvm" ]; then
    sudo shutdown -r +1 &
fi

# announce that first reboot now occuring
ext_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
# mosquitto_pub -d -t aebl/info -m "$(date) : AEBL prepped and rebooting first time. IP is $ext_ip" -h "2001:5c0:1100:dd00:240:63ff:fefd:d3f1"

mosquitto_pub -d -t ihdn/aebl/info -m "$(date) : AEBL prepped and rebooting first time. IP is $ext_ip" -h "ihdn.ca"

# system should be in timed reboot state, so clean up and exit

touch .$(cat "${TEMP_DIR}/version" | head -n1)

mv ${TEMP_DIR}/version $HOME

exit

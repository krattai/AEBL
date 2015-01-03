#!/bin/bash
# This script makes the AEBL framework
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

export PATH=$PATH:${BIN_DIR}:$HOME/scripts

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
# system should be in timed reboot state, so clean up and exit

touch .$(cat "${TEMP_DIR}/version" | head -n1)

mv ${TEMP_DIR}/version $HOME

exit

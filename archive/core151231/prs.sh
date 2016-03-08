#!/bin/bash
#
# Script responds to ping requests
#
# Copyright (C) 2015 Uvea I. S., Kevin Rattai
# BSD license https://raw.githubusercontent.com/krattai/AEBL/master/LICENSE
#

AEBL_TEST="/home/pi/.aebltest"
AEBL_SYS="/home/pi/.aeblsys"
TEMP_DIR="/home/pi/tmp"
IHDN_TEST="/home/pi/.ihdntest"
IHDN_SYS="/home/pi/.ihdnsys"
IHDN_DET="/home/pi/.ihdndet"

T_STO="/run/shm"
T_SCR="/run/shm/scripts"

LOCAL_SYS="${T_STO}/.local"
NETWORK_SYS="${T_STO}/.network"
OFFLINE_SYS="${T_STO}/.offline"

# Check if should respond
# if so:
# + hostname
# + cat chan
# + uptime
# + etc

cd $HOME

# always ping on these
if [ -f "${IHDN_SYS}" ] || [ -f "${IHDN_DET}" ] && [ -f $HOME/.production ]; then
    hostname > ping.txt
    MACe0=$(ip link show eth0 | awk '/ether/ {print $2}')
    IPe0=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f 1)
    echo "$IPe0" >> ping.txt
    echo "$MACe0" >> ping.txt
    echo $(date +"%T") >> ping.txt
    cat chan >> ping.txt
    uptime >> ping.txt
fi

exit

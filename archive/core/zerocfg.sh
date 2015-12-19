#!/bin/bash
#
# provides zeroconfig / avahi functions
#
# Copyright (C) 2015 Uvea I. S., Kevin Rattai
# BSD license https://raw.githubusercontent.com/krattai/AEBL/master/LICENSE
#
# NB: raspbian needs sudo apt-get -y install dnsutils to have dig, nslookup, etc.
#

echo "Content-type: text/html"

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

# possible use of script
# avahi-browse -a --resolve
# avahi-browse
# this next does a terminate after dumping current list of named services
# avahi-browse -a --resolve -t

exit 0

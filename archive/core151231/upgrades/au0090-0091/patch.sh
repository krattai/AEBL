#!/bin/bash
# runs patch scripts
#
# Copyright (C) 2014 Uvea I. S., Kevin Rattai
#
# patches are accumulated, so second patch includes first patch
# and contents of patch will make it into next version / upgrade
# system will patch once a day if available
#
# generally, patches precede upgrades, upgrades supersede patches
#

AEBL_TEST="/home/pi/.aebltest"
AEBL_SYS="/home/pi/.aeblsys"
IHDN_TEST="/home/pi/.ihdntest"
IHDN_SYS="/home/pi/.ihdnsys"
TEMP_DIR="/home/pi/tmp"

T_STO="/run/shm"
T_SCR="/run/shm/scripts"

LOCAL_SYS="${T_STO}/.local"
NETWORK_SYS="${T_STO}/.network"
OFFLINE_SYS="${T_STO}/.offline"

NOTHING_NEW="${T_STO}/.nonew"

MACe0=$(ip link show eth0 | awk '/ether/ {print $2}')

cd $HOME


exit

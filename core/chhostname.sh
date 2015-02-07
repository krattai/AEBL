#!/bin/bash
#
# Script changes hostname
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

cd $HOME

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

exit

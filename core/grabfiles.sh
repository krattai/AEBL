#!/bin/bash
# Shell script to grab video files off server
#
# Copyright (C) 2014 Uvea I. S., Kevin Rattai
#
# This file will likely be superceded by the synfilz.sh script
# as playable content file management.  This script may become
# depricated, although may continue to server future value as
# a method of managing non-playable content on the device.
#
# Get files
#
# as example from old ihdn.ca ftp server
# -N timestamp apparently has problem iwht -O parameter
# so use -nc parameter in place of -N
#
# Eventually, it would be nice to have this script create
# log or file to indicate that it completed successfully
# this would be the last command before a the script exits
# on a success rather than a fail exit

# NB: this should be link to krattai dropbox public folder (not used):
# https://www.dropbox.com/sh/37ntnxfrwz637bk/AAB1CaxMLmNr6l-VwOCcSHUna

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
NEW_PL="${T_STO}/.newpl"
FIRST_RUN_DONE="/home/pi/.firstrundone"

IPe0=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f 1)
MACe0=$(ip link show eth0 | awk '/ether/ {print $2}')

cd $HOME

# check network
#
# this will fail if local network but no internet
# also fails if network was available but drops

if [ ! -f "${OFFLINE_SYS}" ]; then
    if [ -f "${LOCAL_SYS}" ]; then

        wget -N -nd -w 3 -P $HOME/scripts --limit-rate=50k http://192.168.200.6/files/l-ctrl.sh

        chmod 777 $HOME/scripts/l-ctrl.sh

        cp $HOME/scripts/l-ctrl.sh $T_SCR

        wget -N -nd -w 3 -P $HOME/scripts --limit-rate=50k http://192.168.200.6/files/inetup.sh

        chmod 777 $HOME/scripts/inetup.sh

        cp $HOME/scripts/inetup.sh $T_SCR

        wget -N -nd -w 3 -P $HOME/scripts --limit-rate=50k http://192.168.200.6/files/synfilz.sh

        chmod 777 $HOME/scripts/synfilz.sh

        cp $HOME/scripts/synfilz.sh $T_SCR

#        curl -o "$HOME/mp4/Gymkids_00.mp4" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000025/Gymkids_00.mp4" &

# $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic @kratt, #AEBLpi ${MACe0} updated." &

    else

        wget -t 1 -N -nd "https://www.dropbox.com/s/slt6ef1h54k68w4/synfilz.sh" -O $HOME/scripts/synfilz.sh

        chmod 777 $HOME/scripts/synfilz.sh
  
        cp $HOME/scripts/synfilz.sh $T_SCR

        wget -t 1 -N -nd "https://www.dropbox.com/s/k1ifbgmvhjh83na/l-ctrl.sh" -O $HOME/scripts/l-ctrl.sh

        chmod 777 $HOME/scripts/l-ctrl.sh
  
        cp $HOME/scripts/l-ctrl.sh $T_SCR

        wget -t 1 -N -nd "https://www.dropbox.com/s/o86jbuqc81esv83/cronadd.sh" -O $HOME/scripts/cronadd.sh

        chmod 777 $HOME/scripts/cronadd.sh
  
        cp $HOME/scripts/cronadd.sh $T_SCR

        wget -t 1 -N -nd "https://www.dropbox.com/s/4gee63a4fb06zjl/cronrem.sh" -O $HOME/scripts/cronrem.sh

        chmod 777 $HOME/scripts/cronrem.sh

        cp $HOME/scripts/cronrem.sh $T_SCR

        wget -t 1 -N -nd "https://www.dropbox.com/s/4fjx8hiqncpfyto/lctrl.ctab" -O $HOME/scripts/lctrl.ctab

        wget -t 1 -N -nd "https://www.dropbox.com/s/lsf3wyhfymldccu/sync.ctab" -O $HOME/scripts/sync.ctab

        wget -t 1 -N -nd "https://www.dropbox.com/s/sbz7tzlp71hrr8l/bootup.sh" -O $HOME/scripts/bootup.sh

        sudo rm /etc/init.d/bootup.sh
        sudo mv /home/pi/scripts/bootup.sh /etc/init.d
        sudo chmod 755 /etc/init.d/bootup.sh
        sudo update-rc.d bootup.sh defaults

        wget -t 1 -N -nd "https://www.dropbox.com/s/0tponu7z348osrs/inetup.sh" -O $HOME/scripts/inetup.sh

        chmod 777 $HOME/scripts/inetup.sh

        cp $HOME/scripts/inetup.sh $T_SCR

        wget -t 1 -N -nd "https://www.dropbox.com/s/7e2png1lmzzmzxh/getupdt.sh" -O $HOME/scripts/getupdt.sh

        chmod 777 $HOME/scripts/getupdt.sh

        cp $HOME/scripts/getupdt.sh $T_SCR

# curl -o "$HOME/mp4/Gymkids_00.mp4" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000025/Gymkids_00.mp4" &

# curl sftp upload example
#
# curl -T "$HOME/mp4/Vanishing Vegetables.mp4" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000000_uploads/"

# $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic @kratt, #IHDNpi ${MACe0} ${IPe0} updated." &

        # make token for files up to date

        touch $T_STO/.nonew

    fi

    rm index*

fi

# tput clear
exit 0

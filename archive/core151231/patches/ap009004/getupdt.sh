#!/bin/bash
# gets update scripts
#
# Copyright (C) 2014 Uvea I. S., Kevin Rattai
#
# This is the first script from clean bootup.  It should immediately
# put something to screen and audio so that people know it is working,
# and it should then loop that until it get's a .sysready lockfile.
#
# Utilize good bash methodologies as per:
# http://www.davidpashley.com/articles/writing-robust-shell-scripts/#id2382181
#
# This script should probably loop and simply watch for .sysready
# and ! .sysready states.
#
# wget -N -nd http://ihdn.ca/ftp/ads/update.sh -O $HOME/update.sh

# cd $HOME
# ./update.sh

FIRST_RUN_DONE="/home/pi/.firstrundone"
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

cd $HOME

cp -p /home/pi/scripts/* /run/shm/scripts

if [ ! -f "${T_STO}/.optimized" ]; then
#     sudo service dbus stop
    sudo mount -o remount,size=128M /dev/shm
    echo -n performance | sudo tee /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    sudo service triggerhappy stop
    sudo killall console-kit-daemon
    sudo killall polkitd
    killall gvfsd
    killall dbus-daemon
    killall dbus-launch
    touch $T_STO/.optimized

#  Can't do the following, on first run, network not yet established
#     wget -N -r -nd -l2 -w 3 -P ${TEMP_DIR} --limit-rate=50k http://192.168.200.6/files/bootup.sh

#     sudo rm /etc/init.d/bootup.sh
#     sudo mv ${TEMP_DIR}/bootup.sh /etc/init.d
#     sudo chmod 755 /etc/init.d/bootup.sh
#     sudo update-rc.d bootup.sh defaults
#     sudo rm ${TEMP_DIR}/bootup.sh

fi

if [ ! -f "${T_STO}/.mkplayrun" ]; then
    $T_SCR/./mkplay.sh &
fi

if [ ! -f "${FIRST_RUN_DONE}" ]; then
    chmod 777 $HOME/pl
    chmod 777 $HOME/ctrl
    chmod 777 $HOME/mp4
    chmod 777 $HOME/mp3

    rm .id
    rm $HOME/scripts/create-*

    # archive files - eventually, this should be a standalone script
    # assumption made that on first run, all files good
    mkdir $HOME/backup
    cp $HOME/version $HOME/backup
    mkdir $HOME/backup/scripts
    cp $HOME/scripts/*.sh $HOME/backup/scripts
    mkdir $HOME/backup/bin
    cp $HOME/bin/* $HOME/backup/bin
    mkdir $HOME/backup/pl
    cp $HOME/pl/* $HOME/backup/pl
    mkdir $HOME/backup/ctrl
    cp $HOME/ctrl/* $HOME/backup/ctrl

    touch $HOME/.firstrundone
fi

if [ -f "${T_STO}/.omx_playing" ]; then
    rm $T_STO/.omx_playing
fi

if [ -f "${AEBL_TEST}" ] || [ -f "${AEBL_SYS}" ]; then
    echo "~~~~~~~~~~~~~~~~~~~~~~~~" >> log.txt
    echo "Getupdt.sh" >> log.txt
    echo $(date +"%T") >> log.txt
fi

# Discover network availability if not previously tested
if [ ! -f "${LOCAL_SYS}" ] && [ ! -f "${NETWORK_SYS}" ] && [ ! -f "${OFFLINE_SYS}" ]; then

    $T_SCR/./inetup.sh

fi

if [ ! -f "${OFFLINE_SYS}" ]; then
    $T_SCR/./mkuniq.sh &

    ID_FILE="${HOME}/ctrl/ip.txt"
    IPw0=$(ip addr show wlan0 | awk '/inet / {print $2}' | cut -d/ -f 1)
    IPe0=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f 1)

    echo ${IPw0} > ${ID_FILE}
    echo ${IPe0} >> ${ID_FILE}

    ID_FILE="${HOME}/ctrl/ip.txt"
    IPw0=$(ip addr show wlan0 | awk '/inet / {print $2}' | cut -d/ -f 1)
    IPe0=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f 1)

    echo ${IPw0} > ${ID_FILE}
    echo ${IPe0} >> ${ID_FILE}

fi

$T_SCR/./ctrlwtch.sh &

# clear all network check files

rm index*

if [ -f "${AEBL_TEST}" ] || [ -f "${AEBL_SYS}" ]; then
    echo "Going to run update.sh" >> log.txt
    echo $(date +"%T") >> log.txt
fi

$T_SCR/./update.sh &

if [ -f "${AEBL_TEST}" ] || [ -f "${AEBL_SYS}" ]; then
    echo "Ending getupdt.sh" >> log.txt
    echo $(date +"%T") >> log.txt
fi

exit

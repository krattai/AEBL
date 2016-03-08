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
IHDN_DET="/home/pi/.ihdndet"
TEMP_DIR="/home/pi/tmp"

T_STO="/run/shm"
T_SCR="/run/shm/scripts"

LOCAL_SYS="${T_STO}/.local"
NETWORK_SYS="${T_STO}/.network"
OFFLINE_SYS="${T_STO}/.offline"

cd $HOME

cp -p /home/pi/.scripts/* /run/shm/scripts

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

fi

if [ ! -f "${T_STO}/.mkplayrun" ] && [ ! -f "${IHDN_DET}" ]; then
    $T_SCR/./mkplay.sh &
fi

if [ ! -f "${FIRST_RUN_DONE}" ]; then
    chmod 777 $HOME/pl
    chmod 777 $HOME/ctrl
    chmod 777 $HOME/mp4
    chmod 777 $HOME/mp3

    rm .id

    # archive files - eventually, this should be a standalone script
    # assumption made that on first run, all files good
    mkdir $HOME/.backup
    cp $HOME/version $HOME/.backup
    mkdir $HOME/.backup/scripts
    cp $HOME/scripts/*.sh $HOME/.backup/scripts
#     cp $HOME/.scripts/*.sh $HOME/.backup/scripts
    mkdir $HOME/.backup/bin
    cp $HOME/bin/* $HOME/.backup/bin
    mkdir $HOME/.backup/pl
    cp $HOME/pl/* $HOME/.backup/pl
    mkdir $HOME/.backup/ctrl
    cp $HOME/ctrl/* $HOME/.backup/ctrl

    touch $HOME/.firstrundone
fi

if [ -f "${T_STO}/.omx_playing" ]; then
    rm $T_STO/.omx_playing
fi

echo "~~~~~~~~~~~~~~~~~~~~~~~~" >> log.txt
echo $(date +"%T") >> log.txt
echo "Booted up." >> log.txt

# Discover network availability if not previously tested
if [ ! -f "${LOCAL_SYS}" ] && [ ! -f "${NETWORK_SYS}" ] && [ ! -f "${OFFLINE_SYS}" ]; then

    $T_SCR/./inetup.sh

fi

# Always check and perform patching on startup, if internet available
if [ -f "${NETWORK_SYS}" ]; then
    /run/shm/scripts/patch.sh &
fi

if [ ! -f "${OFFLINE_SYS}" ] && [ ! -f "${IHDN_DET}" ]; then
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

if [ ! "$(pgrep ctrlwtch.sh)" ]; then
    $T_SCR/./ctrlwtch.sh &
fi


# clear all network check files
rm index*

$T_SCR/./run.sh &

exit

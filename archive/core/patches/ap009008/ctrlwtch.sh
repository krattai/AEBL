#!/bin/bash
#
# manages ctrl folder content
#
# Copyright (C) 2014 Uvea I. S., Kevin Rattai
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

# NEW_PL="/home/pi/.newpl"
# PLAYLIST="/home/pi/.playlist"

# MACe0=$(ip link show eth0 | awk '/ether/ {print $2}')

cd $HOME

while [ ! -f "${HOME}/ctrl/reboot" ]; do

    # not clean, but useful for now, cron will restart ctrlwtch.sh
    if [ -f "${HOME}/ctrl/.newctrl" ]; then
        rm "${HOME}/ctrl/.newctrl"
        sleep 2
        if [ "$(pgrep ctrlwtch.sh)" ]; then
            kill $(pgrep ctrlwtch.sh)
        fi
    fi

    # manual patch
    if [ -f "${HOME}/ctrl/patch" ]; then
        /run/shm/scripts/patch.sh &
        rm "${HOME}/ctrl/patch"
    fi

    # check channel change present
    # eventually want to put in a channel file which will consist of:
    #     add channel :- +26
    #     remove channel :- -26
    #  or change channel :- =26 (which removes all other channels

    if ls /home/pi/ctrl/cchan* &> /dev/null; then
        echo "files do exist"

        # for now, just emulate channel change, then figue out rest
        cd $HOME/ctrl
        find -depth -name "cchan*" -exec bash -c 'cp "$1" "${1/\cchan/chanid}"' _ {} \;
        rm /home/pi/ctrl/cchan*
        cd $HOME

        # example of adding chanid to ctrl in ihdn_test.sh
#         if ! ls /home/pi/ctrl/chanid* &> /dev/null; then
    #         cp /home/pi/.ihdnfol* /home/pi/ctrl/chanid*
#             cd $HOME
            # this finds .ihdnfol* and copies renamed file it to ctrl fol
#             find -depth -name "chan.ihdnfol*" -exec bash -c 'cp "$1" "ctrl/${1/\.ihdnfol/chanid}"' _ {} \;
#         fi    
#     else
#         echo "files do not exist"
#     fi
    fi

    # put audio and/or video files to proper folders
    if ls /home/pi/ctrl/*.mp4 &> /dev/null; then
        if ! [[ `smbstatus | grep -i mp4` ]]; then
            mv /home/pi/ctrl/*.mp4 /home/pi/pl
        fi
    fi

    if ls /home/pi/ctrl/*.mp3 &> /dev/null; then
        if ! [[ `smbstatus | grep -i mp3` ]]; then
            mv /home/pi/ctrl/*.mp3 /home/pi/pl
        fi
    fi

    if [ -f "${IHDN_SYS}" ] || [ -f "${IHDN_TEST}" ]; then
        if [ ! -f "${HOME}/ctrl/readme.txt" ]; then
            cp "${HOME}/.backup/readme.txt" "${HOME}/ctrl" 
        fi
    fi

    if [ ! -f "${HOME}/ctrl/Welcome.txt" ] && [ ! -f "${IHDN_SYS}" ]; then
        cp "${HOME}/.backup/Welcome.txt" "${HOME}/ctrl" 
    fi

    if [ ! -f "${HOME}/ctrl/admin_guide.txt" ]; then
        cp "${HOME}/.backup/admin_guide.txt" "${HOME}/ctrl" 
    fi

    if [ -f "${HOME}/ctrl/halt" ]; then
        touch "${HOME}/ctrl/reboot"
    fi

    # Do features not part of IHDN systems
    if [ ! -f "${IHDN_SYS}" ]; then

        if [ -f "${HOME}/ctrl/noauto" ]; then
            rm "${HOME}/ctrl/noauto"
            touch "${HOME}/.noauto"
            touch "${HOME}/ctrl/reboot"
        fi

        if [ -f "${HOME}/ctrl/auto" ]; then
            rm "${HOME}/ctrl/auto"
            rm "${HOME}/.noauto"
            touch "${HOME}/ctrl/reboot"
        fi

        if [ -f "${HOME}/ctrl/next" ]; then
            rm "${HOME}/ctrl/next"
            kill $(pgrep omxplayer.bin)
        fi

    fi

    # Do features specific to IHDN
    if [ -f "${IHDN_SYS}" ] && [ -f "${HOME}/ctrl/password" ]; then

        if [ -f "${HOME}/ctrl/noauto" ]; then
            rm "${HOME}/ctrl/noauto"
            touch "${HOME}/.noauto"
            touch "${HOME}/ctrl/reboot"
        fi

        if [ -f "${HOME}/ctrl/auto" ]; then
            rm "${HOME}/ctrl/auto"
            rm "${HOME}/.noauto"
            touch "${HOME}/ctrl/reboot"
        fi

    fi

    sleep 1s

done

rm $HOME/ctrl/reboot

if [  -f "${HOME}/ctrl/halt" ]; then
    rm "${HOME}/ctrl/halt"

    sleep 1s
    sudo halt &
else
    sleep 1s
    sudo reboot &
fi

exit 0

#!/bin/bash
# runs patch scripts
#
# Copyright (C) 2014 Uvea I. S., Kevin Rattai
#
# upgrades are accumulated patches on minor revisions and otherwise
# include major divergence of code or significant changes to core
# code, whether removal, addition, or modification
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

if [ ! -f "${OFFLINE_SYS}" ]; then
    if [ -f "${LOCAL_SYS}" ]; then
        wget -N -nd -w 3 -P ${TEMP_DIR}/upgrade --limit-rate=50k http://192.168.200.6/files/v0091u
    else
        wget -N -nd -w 3 -P ${TEMP_DIR}/upgrade --limit-rate=50k "https://www.dropbox.com/s/4k7y1hyrxvce566/v0091u"
    fi
    cd $TEMP_DIR/upgrade
    GRAB_FILE="v0090p"
    x=1
    while [ $x == 1 ]; do
        # Get the top of the playlist
        cont=$(cat "${GRAB_FILE}" | head -n1)
        # And strip it off the playlist file
        cat "${GRAB_FILE}" | tail -n+2 > "${GRAB_FILE}.new"
        mv "${GRAB_FILE}.new" "${GRAB_FILE}"
        # Skip if this is empty
        if [ -z "${cont}" ]; then
            echo "Playlist empty or bumped into an empty entry for some reason"
            # added by Kevin: exit clean if empty
            x=0
        else
            if [ ! -f "$HOME/.${cont}" ]; then
                wget -N -nd -w 3 -P ${TEMP_DIR}/patch/${cont} --limit-rate=50k "http://192.168.200.6/files/${cont}.zip"
                cd ${TEMP_DIR}/patch/${cont}
                unzip ${cont}.zip
                rm ${cont}.zip
                chmod 777 dopatch.sh
                ./dopatch.sh
                rm *
                cd ..
                touch $HOME/.${cont}
            fi
        fi
    done
    rm ${HOME}/ap0090
else
    echo "system offline, cannot patch"
fi
exit

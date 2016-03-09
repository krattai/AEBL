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

if [ ! -f "${OFFLINE_SYS}" ]; then
    if [ -f "${LOCAL_SYS}" ]; then
        wget -N -nd -w 3 -P ${TEMP_DIR}/patch --limit-rate=50k http://192.168.200.6/files/v0091p
    else
        wget -N -nd -w 3 -P ${TEMP_DIR}/patch --limit-rate=50k "https://www.dropbox.com/s/kgz7tf6eh7dkdz3/v0091p"
    fi
    cd $TEMP_DIR/patch
    GRAB_FILE="v0091p"
    x=1
    while [ $x == 1 ]; do
        # Get the top of the patch list
        cont=$(cat "${GRAB_FILE}" | head -n1)
        # And strip it off the playlist file
        cat "${GRAB_FILE}" | tail -n+2 > "${GRAB_FILE}.new"
        mv "${GRAB_FILE}.new" "${GRAB_FILE}"
        # Skip if this is empty
        if [ -z "${cont}" ]; then
            echo "Patch list empty or bumped into an empty entry for some reason"
            # added by Kevin: exit clean if empty
            x=0
        else
            # Get dropbox companion link
            dbox=$(cat "${GRAB_FILE}" | head -n1)
            # And strip it off the playlist file
            cat "${GRAB_FILE}" | tail -n+2 > "${GRAB_FILE}.new"
            mv "${GRAB_FILE}.new" "${GRAB_FILE}"
            if [ ! -f "$HOME/.${cont}" ]; then
                if [ -f "${LOCAL_SYS}" ]; then
                    wget -N -nd -w 3 -P ${TEMP_DIR}/patch/${cont} --limit-rate=50k "http://192.168.200.6/files/${cont}.zip"
                else
                    wget -N -nd -w 3 -P ${TEMP_DIR}/patch/${cont} --limit-rate=50k "https://www.dropbox.com/s/${dbox}/${cont}.zip"
                fi
                cd ${TEMP_DIR}/patch/${cont}
                unzip ${cont}.zip
                rm ${cont}.zip
                chmod 777 dopatch.sh
                sleep 5
                ./dopatch.sh
                rm *
                cd ..
                touch $HOME/.${cont}
                sleep 30
            fi
        fi
    done
else
    echo "system offline, cannot patch"
fi
exit

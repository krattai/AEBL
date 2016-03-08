#!/bin/bash
# rebuilds system by applying all patches right through current
#
# Copyright (C) 2015 Uvea I. S., Kevin Rattai
# BSD license https://raw.githubusercontent.com/krattai/AEBL/master/LICENSE
#
# Not quite like rollback, this script should re-apply all patches to current
#

AEBL_TEST="/home/pi/.aebltest"
AEBL_SYS="/home/pi/.aeblsys"
AEBL_VM="/home/pi/.aeblvm"
IHDN_TEST="/home/pi/.ihdntest"
IHDN_SYS="/home/pi/.ihdnsys"
IHDN_DET="/home/pi/.ihdndet"

T_STO="/run/shm"
T_SCR="/run/shm/scripts"

TEMP_DIR="${T_STO}/tmp"

mkdir "${TEMP_DIR}"

LOCAL_SYS="${T_STO}/.local"
NETWORK_SYS="${T_STO}/.network"
OFFLINE_SYS="${T_STO}/.offline"

NOTHING_NEW="${T_STO}/.nonew"

MACe0=$(ip link show eth0 | awk '/ether/ {print $2}')

cd $HOME

# Should check for current version and use that as reference to patches.
# Check patch version type now, rather than dropbox location

# use v####p file, second element (previously dropbox field, as version type)

# new logic
# if patch production
#     all do patch
# else
#     if patch beta && not production unit
#         all remaining do patch
#     else
#         alpha do patch
#     fi
# fi

if [ ! -f "${OFFLINE_SYS}" ]; then
# test with no more local_sys patching
#     if [ -f "${LOCAL_SYS}" ]; then
#         wget -N -nd -w 3 -P ${TEMP_DIR}/patch --limit-rate=50k http://192.168.200.6/files/v0091p
#     else
        wget -N -nd -w 3 -P ${TEMP_DIR}/patch --limit-rate=50k "https://raw.githubusercontent.com/krattai/AEBL/master/core/patches/v0091p"
#     fi

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
            # Get version type
            vtype=$(cat "${GRAB_FILE}" | head -n1)
            # And strip it off the playlist file
            cat "${GRAB_FILE}" | tail -n+2 > "${GRAB_FILE}.new"
            mv "${GRAB_FILE}.new" "${GRAB_FILE}"
            if [ ! -f "$HOME/.${cont}" ]; then
#                 if [ -f "${LOCAL_SYS}" ]; then
#                     wget -N -nd -w 3 -P ${TEMP_DIR}/patch/${cont} --limit-rate=50k "http://192.168.200.6/files/${cont}.zip"
#                 else
                    wget -N -nd -w 3 -P ${TEMP_DIR}/patch/${cont} --limit-rate=50k "https://github.com/krattai/AEBL/raw/master/core/patches/${cont}.zip"
#                 fi
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

#!/usr/bin/env bash
#
# sync files
#
# Copyright (C) 2014 Uvea I. S., Kevin Rattai
#
# wget -r -nd -Nc -l2 -w 3 -i file -P $HOME/mp4 http://192.168.200.6/files/
#
# or
#
# wget -r -nd -Nc -l2 -w 3 -A.mp4 -P $HOME/mp4 http://192.168.200.6/files/
#
# or
#
# wget -b -c -q -r -nd -nc -l2 -w3 --limit-rate=50k -A.mp4 -P $HOME/mp4 http://192.168.200.6/files/
#
# -b background
# -c continue if prior broken; not working in some cases do not use
# -q quiet no output log
# -r recursive required if multiple
# -nd no direcotry so not putting paths
# -nc no clobber so not download if exist
# -l2 only 2 levels, important with http as level 2 is files
# -w3 wait 3 seconds so as not to overwhelm server with requests
# --limit-rate to save bandwidth on both client and server
# -A is files of type
# -P sends to path on client
#
# When running Wget with ‘-N’, with or without ‘-r’ or ‘-p’, the
# decision as to whether or not to download a newer copy of a file
# depends on the local and remote timestamp and size of the file (see
# Time-Stamping). ‘-nc’ may not be specified at the same time as ‘-N’. 
#
# Eventually, it would be nice to have this script create
# log or file to indicate that it completed successfully
# this would be the last command before a the script exits
# on a success rather than a fail exit

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

NOTHING_NEW="${T_STO}/.nonew"
NEW_PL="${T_STO}/.newpl"

MACe0=$(ip link show eth0 | awk '/ether/ {print $2}')

cd $HOME

if [ -f "${NETWORK_SYS}" ]; then

    rm $T_STO/test.log

    touch $T_STO/test.log

    echo "${MACe0}" >> $T_STO/test.log
    echo "$(date +"%y-%m-%d")" >> $T_STO/test.log
    echo "$(date +"%T")" >> $T_STO/test.log

fi

if [ "${MACe0}" == 'b8:27:eb:37:07:5a' ] && [ -f "${AEBL_SYS}" ]; then
    rm .aeblsys
    rm .aeblsys_test
fi

#Check network before syncing
if [ -f "${LOCAL_SYS}" ]; then
    rm index*
    echo "Online"

    # Check if not syncing
    # should append syncing to syncing file and dump it to dropbox

    if [ ! -f "${T_STO}/syncing" ]; then

        touch "${T_STO}/syncing"

        if [ ".scripts/ctrlwtch.sh" -nt "/run/shm/scripts/ctrlwtch.sh" ]; then
            touch $HOME/ctrl/.newctrl
            cp $HOME/.scripts/ctrlwtch.sh $T_SCR
        fi

        if [ -f "${AEBL_TEST}" ] || [ -f "${AEBL_SYS}" ]; then
            wget -N -nd -w 3 -P $T_STO --limit-rate=50k http://192.168.200.6/files/aebl.m3u
            rm $T_STO/synfil
            cp $T_STO/aebl.m3u $T_STO/synfil
            rm $T_STO/aebl.m3u
            GRAB_FILE="${T_STO}/synfil"
        fi

        x=1

        if [ ! -d "tmp" ]; then
            mkdir tmp
        fi

        if  [ -f "${AEBL_TEST}" ] || [ -f "${AEBL_SYS}" ]; then
            while [ $x == 1 ]; do
                # Sleep so it's possible to kill this
        #         sleep 1

                # check file doesn't exist
                if [ ! -f "${GRAB_FILE}" ]; then
                    echo "Playlist file ${GRAB_FILE} not found"
                    continue
                fi
    
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

#                    continue

                fi

                # Check that the file exists
        #         if [ ! -f "${cont}" ]; then
        #                 echo "Playlist entry ${cont} not found"
        #                 continue
        #         fi

                clear
                echo
                echo "Getting ${cont} ..."
                echo

                if [ ! -f "$HOME/mp4/${cont}" ]; then
                    wget -N -nd -w 3 -P ${TEMP_DIR} --limit-rate=50k "http://192.168.200.6/files/mp4/${cont}"
                    mv "${TEMP_DIR}/${cont}" $HOME/mp4
                fi

                echo
                echo "File complete, continuing to next item."
                echo

            done
            rm ${GRAB_FILE}
        fi

        rm "${T_STO}/syncing"

    fi

fi

# tput clear
exit 0

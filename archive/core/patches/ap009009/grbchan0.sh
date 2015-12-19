#!/bin/bash
# Shell script to grab channel video files off server
#
# Copyright (C) 2014 IHDN, Uvea I. S., Kevin Rattai
#

FIRST_RUN_DONE="/home/pi/.firstrundone"
AEBL_TEST="/home/pi/.aebltest"
AEBL_SYS="/home/pi/.aeblsys"
IHDN_TEST="/home/pi/.ihdntest"
IHDN_SYS="/home/pi/.ihdnsys"
TEMP_DIR="/home/pi/tmp"

T_STO="/run/shm"
T_SCR="/run/shm/scripts"

LOCAL_SYS="/home/pi/.local"
NETWORK_SYS="/home/pi/.network"
OFFLINE_SYS="/home/pi/.offline"

AEBL_TEST="/home/pi/.aebltest"
AEBL_SYS="/home/pi/.aeblsys"
IHDN_TEST="/home/pi/.ihdntest"
IHDN_SYS="/home/pi/.ihdnsys"
TEMP_DIR="/home/pi/tmp"

T_STO="/run/shm"
T_SCR="/run/shm/scripts"

IPe0=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f 1)
MACe0=$(ip link show eth0 | awk '/ether/ {print $2}')

cd $HOME

touch .getchan0

# check network
#
# this will fail if local network but no internet
# also fails if network was available but drops

if [ ! -f "${OFFLINE_SYS}" ]; then
    if [ -f "${LOCAL_SYS}" ]; then

    #     The following would download and delete file
    #
    #     curl -o "$HOME/chan26.m3u" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000027/chan26.m3u" -Q '-rm /home/videouser/videos/000027/chan26.m3u'

    #     curl -o "$HOME/chan26.m3u" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000027/chan26.m3u"

        wget -N -nd -w 3 -P $HOME --limit-rate=50k http://192.168.200.6/files/chan0.m3u

        rm mychan

        cp chan0.m3u mychan

        rm chan0.m3u

        GRAB_FILE="${HOME}/mychan"

        x=1

        if [ ! -d "tmp" ]; then
            mkdir tmp
        fi

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

    #         "${PLAYER}" ${PLAYER_OPTIONS} "${cont}" > /dev/null
            wget -N -nd -w 3 -P ${TEMP_DIR} --limit-rate=50k "http://192.168.200.6/files/mp4/${cont}"
            mv ${TEMP_DIR}/${cont} $HOME/mp4

            echo
            echo "File complete, continuing to next item."
            echo

        done

        touch .newchan0

        rm ${GRAB_FILE}
    fi

fi

# if [ -f "${HOME}/.newchan0" ]; then
#     $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic #IHDNpi Robert E. Steen channel 26 updated." &
# fi

rm .getchan0

# tput clear
exit 0

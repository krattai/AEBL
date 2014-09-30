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

LOCAL_SYS="${T_STO}/.local"
NETWORK_SYS="${T_STO}/.network"
OFFLINE_SYS="${T_STO}/.offline"

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

touch .getchan

cp /home/pi/chan /home/pi/chtmp

CHAN_LOC="chtmp"

# Get the channel file name
chan=$(cat "${CHAN_LOC}" | head -n1)
# And strip it off the file
cat "${CHAN_LOC}" | tail -n+2 > "${CHAN_LOC}.new"
mv "${CHAN_LOC}.new" "${CHAN_LOC}"
# Get folder location
folder=$(cat "${CHAN_LOC}" | head -n1)

rm /home/pi/chtmp

# check network
#
# this will fail if local network but no internet
# also fails if network was available but drops

if [ ! -f "${OFFLINE_SYS}" ]; then
    if [ -f "${LOCAL_SYS}" ]; then

        # change chan and folder according to known IHDN_TEST sys
        chan="ihdn"
        folder="mp4"
        wget -N -nd -w 3 -P $T_STO --limit-rate=50k "http://192.168.200.6/files/${chan}.m3u"
    else
        curl -o "${T_STO}/${chan}.m3u" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/${folder}/${chan}.m3u"
    fi

    cp "${T_STO}/${chan}.m3u" $T_STO/synfil
    rm "${T_STO}/${chan}.m3u"


    GRAB_FILE="${T_STO}/synfil"
    x=1
    if [ ! -d "/home/pi/tmp" ]; then
        mkdir /home/pi/tmp
    fi

    while [ $x == 1 ]; do
        # Sleep so it's possible to kill this
        #         sleep 1

        # check file doesn't exist
        if [ ! -f "${GRAB_FILE}" ]; then
            echo "Playlist file ${GRAB_FILE} not found"
            x=0
        fi
    
        # Get the top of the playlist
        cont=$(cat "${GRAB_FILE}" | head -n1)
    
        # And strip it off the playlist file
        cat "$GRAB_FILE" | tail -n+2 > "$GRAB_FILE.new"
        mv "$GRAB_FILE.new" "$GRAB_FILE"

        # Skip if this is empty
        if [ -z "${cont}" ]; then
            # added by Kevin: exit clean if empty
            x=0
        fi

        # Check that the file does not exist
        if [ ! -f "$HOME/mp4/${cont}" ]; then

            # if local, do IHDN_TEST else, do IHDN_SYS
            if [ -f "${LOCAL_SYS}" ]; then

                wget -N -nd -w 3 -P ${TEMP_DIR} --limit-rate=50k "http://192.168.200.6/files/${folder}/${cont}"
            else
                curl -o "${TEMP_DIR}/${cont}" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/${folder}/${cont}"
            fi

            mv "${TEMP_DIR}/${cont}" $HOME/mp4
        fi
    done
fi

rm "$GRAB_FILE"

# if [ -f "${HOME}/.newchan0" ]; then
#     $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic #IHDNpi Robert E. Steen channel 26 updated." &

rm /home/pi/.getchan

# tput clear
exit 0

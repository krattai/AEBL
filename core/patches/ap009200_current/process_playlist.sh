#!/bin/bash
#
# Plays videos from playlist
#
# Copyright Â© 2013 Janne Enberg http://lietu.net/
# This work is free. You can redistribute it and/or modify it under the
# terms of the Do What The Fuck You Want To Public License, Version 2,
# as published by Sam Hocevar. See http://www.wtfpl.net/ for more details.
#
# Copyright (C) 2014 Uvea I. S., Kevin Rattai
#
# May 14, 2014 Larry added GPIO 23 to switch on video
#
# Set up GPIO 23 and set to output 1
#
# Eventually, it would be nice to have this script create
# log or file to indicate that it completed successfully
# this would be the last command before a the script exits
# on a success rather than a fail exit

sudo bash /home/pi/scripts/led_on.sh

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

NOTHING_NEW="${T_STO}/.nonew"
NEW_PL="${T_STO}/.newpl"
FIRST_RUN_DONE="/home/pi/.firstrundone"

# If you want to switch omxplayer to something else, or add parameters, use these
PLAYER="omxplayer"
PLAYER_OPTIONS=""

# Where is the playlist
PLAYLIST_FILE="${T_STO}/.playlist"
# Grab IP
ext_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
# Get hostname
hostn=$(cat /etc/hostname)

touch $T_STO/.omx_playing

# Process playlist contents
while [ -f "${T_STO}/.omx_playing" ]; do
        # Sleep a bit so it's possible to kill this
        # sleep 1

        # Do nothing if the playlist doesn't exist
        if [ ! -f "${PLAYLIST_FILE}" ]; then
                echo "Playlist file ${PLAYLIST_FILE} not found"
                continue
        fi

        # Get the top of the playlist
        file=$(cat "${PLAYLIST_FILE}" | head -n1)

        # And strip it off the playlist file
        cat "${PLAYLIST_FILE}" | tail -n+2 > "${PLAYLIST_FILE}.new"
        mv "${PLAYLIST_FILE}.new" "${PLAYLIST_FILE}"

        # Skip if this is empty
        if [ -z "${file}" ]; then
                echo "Playlist empty or bumped into an empty entry for some reason"

                # added by Kevin: exit clean if empty
                rm $T_STO/.omx_playing

                continue

        fi

        # Check that the file exists
        if [ ! -f "${file}" ]; then
                echo "Playlist entry ${file} not found"
                continue
        fi

        clear
        echo
        echo "Playing ${file} ..."
        echo

#         cat ${file}
        "${PLAYER}" ${PLAYER_OPTIONS} "${file}" > /dev/null

        if [ -f "${IHDN_SYS}" ] || [ -f "${IHDN_DET}" ] || [ -f "${IHDN_TEST}" ]; then
            mosquitto_pub -d -t ihdn/play -m "$(date) : $hostn IP $ext_ip played: $file." -h "2001:5c0:1100:dd00:240:63ff:fefd:d3f1"
        fi

        if [ -f "${AEBL_SYS}" ] || [ -f "${AEBL_TEST}" ]; then
            mosquitto_pub -d -t aebl/play -m "$(date) : $hostn IP $ext_ip played: $file." -h "2001:5c0:1100:dd00:240:63ff:fefd:d3f1"
        fi

        echo
        echo "Playback complete, continuing to next item on playlist."
        echo
done

if [ -f "${T_STO}/.omx_playing" ]; then
    rm $T_STO/.omx_playing
fi

exit

#!/bin/bash

i="0"

while [ $i -lt 1 ]
do
# i=$[$i+1]
sleep 300
done




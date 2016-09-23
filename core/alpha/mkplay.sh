#!/bin/bash
#
# grabs and makes playlist
#
# Copyright (C) 2014 - 2016 Uvea I. S., Kevin Rattai
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

NEW_PL="${T_STO}/.newpl"
PLAYLIST="${T_STO}/.playlist"

MACe0=$(ip link show eth0 | awk '/ether/ {print $2}')

cd $HOME

rm "${T_STO}/mynew.pl"

touch $T_STO/.mkplayrun

while [ -f "${T_STO}/.mkplayrun" ]; do

    # Check if not currently making playlist and newpl exists

    if [ ! -f "${T_STO}/mkpl" ] && [ -f "${T_STO}/mynew.pl" ]; then

        touch $T_STO/mkpl

        cp "${T_STO}/mynew.pl" "${T_STO}/pl.part"

        PL_FILE="${T_STO}/pl.part"

        if [ -f "${T_STO}/pl.new" ]; then
            rm $T_STO/pl.new
        fi

        touch $T_STO/pl.new

        PLAY_LIST="${T_STO}/pl.new"

        x=1

        while [ $x == 1 ]; do

            # check file doesn't exist
            if [ ! -f "${PL_FILE}" ]; then
                    echo "Playlist file ${PL_FILE} not found"
                    rm $T_STO/mkpl
                    exit 1
            fi
    
            # Get the top of the playlist
            cont=$(cat "${PL_FILE}" | head -n1)
    
            # Skip if this is empty
            if [ -z "${cont}" ]; then
                echo "Playlist empty or bumped into an empty entry for some reason"

                x=0

            else
                # And strip it off the playlist file
                cat "${PL_FILE}" | tail -n+2 > "${PL_FILE}.new"
                mv "${PL_FILE}.new" "${PL_FILE}"

                # Append file to playlist
                echo "${HOME}/mp4/${cont}" >> "${PLAY_LIST}"
            fi

        done

        rm $T_STO/mkpl

        if [ ! -f "${T_STO}/pl.tmp" ]; then
            cp "${T_STO}/.newpl" "${T_STO}/pl.tmp"
        fi

        if [ -f "${T_STO}/.newpl" ]; then
            rm "${T_STO}/.newpl"
        fi

        cp "${T_STO}/pl.new" "${T_STO}/.newpl"
        rm "${T_STO}/pl.new"
        rm "${T_STO}/mynew.pl"

    else
        if [ -f "${NEW_PL}" ]; then

            if [ -f "${AEBL_TEST}" ] || [ -f "${AEBL_SYS}" ]; then
                echo "Setting up stored playlist."
            fi

            if [ ! -s "${T_STO}/.playlist" ]; then
                while [ -f "$T_STO/.omx_playing" ]; do
                    echo "waiting for player off" > /dev/null
                done
                rm "${T_STO}/.playlist"
                cp "${T_STO}/.newpl" "${T_STO}/.playlist"
#                 rm "${T_STO}/.playlistnew"
            fi
        else
            if [ ! -f "${T_STO}/.playlist" ]; then
            
                # make playlist

                if [ -f "${AEBL_TEST}" ] || [ -f "${AEBL_SYS}" ]; then
                    echo "Creating new playlist."
                fi

                $T_SCR/./playlist.sh $HOME/pl/*.mp4

                $T_SCR/./playlist.sh $HOME/pl/*.mp3

                cp "${T_STO}/.playlist" "${T_STO}/.newpl"
            fi
        fi
            
    fi


done

# tput clear
exit 0

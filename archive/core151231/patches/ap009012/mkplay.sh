#!/bin/bash
#
# grabs and makes playlist
#
# Copyright (C) 2014 Uvea I. S., Kevin Rattai
#
# Eventually, it would be nice to have this script create
# log or file to indicate that it completed successfully
# this would be the last command before a the script exits
# on a success rather than a fail exit

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

# Can't do this yet, network not yet established on first run

# if [ ! -f "${HOME}/scripts/playlist.sh" ]; then
#     wget -N -r -nd -l2 -w 3 -P $HOME/scripts --limit-rate=50k http://192.168.200.6/files/playlist.sh
# 
#     chmod 777 scripts/playlist.sh
# 
# fi

rm "${T_STO}/mynew.pl"

touch $T_STO/.mkplayrun

while [ -f "${T_STO}/.mkplayrun" ]; do

    # Check if not currenlty making playlist and newpl exists

    if [ ! -f "${T_STO}/mkpl" ] && [ -f "${T_STO}/mynew.pl" ]; then
        echo "Currently not making playlist." >> log.txt
        echo "Making running token."  >> log.txt
        echo $(date +"%T") >> log.txt

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
            # Sleep so it's possible to kill this
        #         sleep 1

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

                # added by Kevin: exit clean if empty
                x=0

#                    continue

            else
                # And strip it off the playlist file
                cat "${PL_FILE}" | tail -n+2 > "${PL_FILE}.new"
                mv "${PL_FILE}.new" "${PL_FILE}"

                # Append file to playlist
                echo "${HOME}/mp4/${cont}" >> "${PLAY_LIST}"
            fi

            # Check that the file exists
    #         if [ ! -f "${cont}" ]; then
    #                 echo "Playlist entry ${cont} not found"
    #                 continue
    #         fi

    #             clear
    #             echo
    #             echo "Getting ${cont} ..."
    #             echo

    #         "${PLAYER}" ${PLAYER_OPTIONS} "${cont}" > /dev/null
    #             wget -N -r -nd -l2 -w 3 -P $HOME/tmp --limit-rate=50k "http://192.168.200.6/files/mp4/${cont}"


    #             echo
    #             echo "Playback complete, continuing to next item on playlist."
    #             echo

        done

    # possible method for creating new playlist
    # find "$(pwd)/aud" -maxdepth 1 -type f  >> list.pl

    #         wget -r -nd -nc -l 2 -w 3 -A mp4 -P $HOME/mp4 http://192.168.200.6/files/

    #         wget -r -nd -nc -l 2 -w 3 -A mp3 -P $HOME/aud http://192.168.200.6/files/


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

        # Else do nothing files
        #    else
        #        echo "Already syncing!"
    else
        if [ -f "${NEW_PL}" ]; then
            #    rm .nonew
            #    sudo reboot

            if [ -f "${AEBL_TEST}" ] || [ -f "${AEBL_SYS}" ]; then
                echo "Setting up stored playlist." >> log.txt
                echo $(date +"%T") >> log.txt
            fi

            if [ ! -s "${T_STO}/.playlist" ]; then
                while [ -f "$T_STO/.omx_playing" ]; do
                    echo "waiting for player off"
                done
                rm "${T_STO}/.playlist"
                cp "${T_STO}/.newpl" "${T_STO}/.playlist"
#                 rm "${T_STO}/.playlistnew"
            fi
        else
            if [ ! -f "${T_STO}/.playlist" ]; then
            
                # make playlist

                if [ -f "${AEBL_TEST}" ] || [ -f "${AEBL_SYS}" ]; then
                    echo "Creating new playlist." >> log.txt
                    echo $(date +"%T") >> log.txt
                fi

                $T_SCR/./playlist.sh $HOME/pl/*.mp4

                $T_SCR/./playlist.sh $HOME/pl/*.mp3

                cp "${T_STO}/.playlist" "${T_STO}/.newpl"
            fi
        fi
            
    fi

#     if [ -f "${AEBL_TEST}" ] || [ -f "${AEBL_SYS}" ]; then
#         echo "Done making playlist." >> log.txt
#         echo $(date +"%T") >> log.txt
#     fi


#     else
#             echo "Offline"

done

# tput clear
exit 0

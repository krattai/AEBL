#!/bin/bash
#
# grabs channel .del and removes from AEBL
#
# Copyright (C) 2014 Uvea I. S., Kevin Rattai
#

FIRST_RUN_DONE="/home/pi/.firstrundone"
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

AEBL_TEST="/home/pi/.aebltest"
AEBL_SYS="/home/pi/.aeblsys"
IHDN_TEST="/home/pi/.ihdntest"
IHDN_SYS="/home/pi/.ihdnsys"
IHDN_DET="/home/pi/.ihdndet"
TEMP_DIR="/home/pi/tmp"

T_STO="/run/shm"
T_SCR="/run/shm/scripts"

IPe0=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f 1)
MACe0=$(ip link show eth0 | awk '/ether/ {print $2}')

cd $HOME

touch "${T_STO}/.delfile"

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
    if [ ! -f "${HOME}/ctrl/rmfiles" ]; then
        if [ -f "${LOCAL_SYS}" ]; then
            if [ -f "${IHDN_DET}" ]; then
                # change chan and folder according to known IHDN_DET sys
                chan="idettest"
                folder="mp4"
            else
                # change chan and folder according to known IHDN_TEST sys
                chan="ihdn"
                folder="mp4"
            fi
            wget -N -nd -w 3 -P $T_STO --limit-rate=50k "http://192.168.200.6/files/${chan}.del"
        else
            curl -o "${T_STO}/${chan}.del" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/${folder}/${chan}.del"
        fi

        dos2unix "${T_STO}/${chan}.del"

        cp "${T_STO}/${chan}.del" $T_STO/delfil
        rm "${T_STO}/${chan}.del"

    else
        dos2unix "${HOME}/ctrl/rmfiles"

        cp "${HOME}/ctrl/rmfiles" $T_STO/delfil
        rm "${HOME}/ctrl/rmfiles"
    fi

    RM_FILE="${T_STO}/delfil"
    x=1
    if [ ! -d "/home/pi/tmp" ]; then
        mkdir /home/pi/tmp
    fi

    while [ $x == 1 ]; do
        # Sleep so it's possible to kill this
        #         sleep 1

        # check file doesn't exist
        if [ ! -f "${RM_FILE}" ]; then
            echo "Removelist file ${RM_FILE} not found"
            x=0
        fi
    
        # Get the top of the playlist
        cont=$(cat "${RM_FILE}" | head -n1)
    
        # And strip it off the playlist file
        cat "$RM_FILE" | tail -n+2 > "$RM_FILE.new"
        mv "$RM_FILE.new" "$RM_FILE"

        # Skip if this is empty
        if [ -z "${cont}" ]; then
            # added by Kevin: exit clean if empty
            x=0
        fi

        # Check that the file exist
        if [ -f "$HOME/mp4/${cont}" ]; then
            rm "$HOME/mp4/${cont}"
        fi
    done
fi

rm "$RM_FILE"

# if [ -f "${HOME}/.newchan0" ]; then
#     $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic #IHDNpi Robert E. Steen channel 26 updated." &

rm "${T_STO}/.delfile"

# tput clear
exit 0

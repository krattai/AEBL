#!/bin/bash
# runs updates
#
# Copyright (C) 2014 IHDN, Uvea I. S., Kevin Rattai
#
# This file will be superceded by the l-ctrl file as far as
# control of the system, as l-ctrl will be a cron job.  This
# script may become depricated, although it might continue a
# useful, future function for loose processes that are outside
# the scope of the l-ctrl function.
#
# This is control file that can change from time to time on admin
# desire.  This script is in addition to the getupdt.sh script
# only because the getupdt.sh script is assumed to be static
# where this one could contain a process which could update the
# getupdt.sh script if desired.
#
# Eventually, it would be nice to have this script create
# log or file to indicate that it completed successfully
# this would be the last command before a the script exits
# on a success rather than a fail exit
#
# There should be a control that allows system to be put into a
# live or a test condition.  Should be in at least in a cron job but
# eventually should be a daemon.
#
# This script is the one called from the getupdt.sh script and should
# probably make immediate determination between IHDN and AEBL systems
# and call respective scripts.
#
# This is the first script from clean bootup.  It should immediately
# put something to screen and audio so that people know it is working,
# and it should then loop that until it get's a .sysready lockfile.
#
# Utilize good bash methodologies as per:
# http://www.davidpashley.com/articles/writing-robust-shell-scripts/#id2382181
#
# This script should probably loop and simply watch for .sysready and ! .sysready states.

# this was used to set keyboard LED for detector hardware to know
# not to process

# xset led 3

# set to home directory

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
FIRST_RUN_DONE="/home/pi/.firstrundone"

IPw0=$(ip addr show wlan0 | awk '/inet / {print $2}' | cut -d/ -f 1)
MACw0=$(ip link show wlan0 | awk '/ether/ {print $2}')
IPe0=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f 1)
MACe0=$(ip link show eth0 | awk '/ether/ {print $2}')

CRONCOMMFILE="${T_STO}/.tempcron"
 
 
cd $HOME

if [ -f "${HOME}/.ihdnfol25" ] && [ -f "${HOME}/.newchan25" ] && [ ! -f "${HOME}/.getchan25" ]; then
    rm $T_STO/.newpl
    rm $HOME/.newchan25
fi

if [ -f "${HOME}/.ihdnfol26" ] && [ -f "${HOME}/.newchan26" ] && [ ! -f "${HOME}/.getchan26" ]; then
    rm $T_STO/.newpl
    rm $HOME/.newchan26
fi

if [ -f "${HOME}/.ihdnfol27" ] && [ -f "${HOME}/.newchan27" ] && [ ! -f "${HOME}/.getchan27" ]; then
    rm $T_STO/.newpl
    rm $HOME/.newchan27
fi

if [ -f "${HOME}/.ihdnfol28" ] && [ -f "${HOME}/.newchan28" ] && [ ! -f "${HOME}/.getchan28" ]; then
    rm $T_STO/.newpl
    rm $HOME/.newchan28
fi

if [ -f "${NEW_PL}" ]; then
#    rm .nonew
#    sudo reboot

    while [ -f "${T_STO}/.omx_playing" ]; do
        echo "waiting for player off"
    done
    rm "${T_STO}/.playlist"
    cp "${T_STO}/.newpl" "${T_STO}/.playlist"
    rm "${T_STO}/.playlistnew"
# else
    # make playlist

#     scripts/./playlist.sh ~/pl/*.mp4

    # scripts/./playlist.sh ~/pl/*.mp3

#     cp .playlist .newpl
fi

# play through the playlist
if [ -f "${T_STO}/.playlist" ]; then
    $T_SCR/./process_playlist.sh
fi

exit

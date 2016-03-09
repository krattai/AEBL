#!/bin/bash
# runs updates
#
# Copyright (C) 2014 Uvea I. S., Kevin Rattai
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

IPw0=$(ip addr show wlan0 | awk '/inet / {print $2}' | cut -d/ -f 1)
MACw0=$(ip link show wlan0 | awk '/ether/ {print $2}')
IPe0=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f 1)
MACe0=$(ip link show eth0 | awk '/ether/ {print $2}')

CRONCOMMFILE="${T_STO}/.tempcron"
 
# set to home directory
 
cd $HOME

touch $T_STO/.sysrunning

while [ -f "${T_STO}/.sysrunning" ]; do

    # log .id

    cat .id >> log.txt

    if [ -f "${AEBL_TEST}" ] || [ -f "${AEBL_SYS}" ]; then
        $T_SCR/./aebl_play.sh

        if [ "${MACe0}" == 'b8:27:eb:37:07:5a' ] && [ -f "${AEBL_SYS}" ]; then
            echo "MAC is ending :5a so touching .aeblsys_test." >> log.txt
            echo $(date +"%T") >> log.txt
            touch .aeblsys_test
            touch .aebltest
            rm ${AEBL_SYS}
        fi
    fi

    if [ -f "${IHDN_TEST}" ] || [ -f "${IHDN_SYS}" ]; then
        $T_SCR/./ihdn_play.sh
        if [ ! -f "${T_STO}/.syschecks" ]; then
            $T_SCR/./ihdn_tests.sh &
        fi
    fi

    # Check nothing new
#     if [ -f "${NOTHING_NEW}" ]; then
#         echo "No files to grab."
#     else
# 
#         if [ -f "${AEBL_TEST}" ] || [ -f "${AEBL_SYS}" ]; then
#             echo "Getting grabfiles.sh" >> log.txt
#             echo $(date +"%T") >> log.txt
#         fi
        # check network
        #
        # this will fail if local network but no internet
        # also fails if network was available but drops

#         if [ ! -f "${OFFLINE_SYS}" ]; then
#             if [ -f "${LOCAL_SYS}" ]; then
#                 wget -t 1 -N -nd http://192.168.200.6/files/grabfiles.sh -O $HOME/scripts/grabfiles.sh

#             else
#                 wget -t 1 -N -nd "https://www.dropbox.com/s/c2j6ygj5957wrdh/grabfiles.sh" -O $HOME/scripts/grabfiles.sh

#             fi

#             chmod 777 $HOME/scripts/grabfiles.sh
#             rm index*

#             cp $HOME/scripts/grabfiles.sh $T_SCR

#             $T_SCR/./grabfiles.sh

#         fi

#     fi

    if [ -f "${AEBL_TEST}" ] || [ -f "${AEBL_SYS}" ] && [ ! -f "${NOTHING_NEW}" ]; then
        echo "Setting system to not check updates with .nonew" >> log.txt
        echo $(date +"%T") >> log.txt
        touch $T_STO/.nonew
    fi

done

# if .sysrunning token cleared, loop back to getupdt.sh

$T_SCR/./startup.sh &

exit

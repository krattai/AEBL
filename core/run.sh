#!/bin/bash
# runs updates
#
# Copyright (C) 2014 Uvea I. S., Kevin Rattai
#
# This is the functional, process control script.  It is intended to ensure
# that system functionality and processing is ocurring.  This script does
# all work except that which is part of the control folder system.  The control
# folder system communicates and interacts with the run system.
#
# There should be a control that allows system to be put into a
# live or a test condition.  Should be in at least in a cron job but
# eventually should be a daemon.
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
IHDN_DET="/home/pi/.ihdndet"
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

#    cat .id >> log.txt

    if [ -f "${AEBL_TEST}" ] || [ -f "${AEBL_SYS}" ]; then
        $T_SCR/./aebl_play.sh

        if [ "${MACe0}" == 'b8:27:eb:37:07:5a' ] && [ -f "${AEBL_SYS}" ]; then
#            echo "MAC is ending :5a so touching .aeblsys_test." >> log.txt
#            echo $(date +"%T") >> log.txt
            touch .aeblsys_test
            touch .aebltest
            rm ${AEBL_SYS}
        fi
    fi

    if [ -f "${IHDN_TEST}" ] || [ -f "${IHDN_SYS}" ]; then
        if [ ! -f "${IHDN_DET}" ]; then
            $T_SCR/./ihdn_play.sh
        fi
        if [ ! -f "${T_STO}/.syschecks" ] && [ ! "$(pgrep ihdn_tests.sh)" ]; then
            $T_SCR/./ihdn_tests.sh &
        fi
    fi

    # Check nothing new
    # This section to watch and react to requested or auto change in system


    if [ -f "${AEBL_TEST}" ] || [ -f "${AEBL_SYS}" ] && [ ! -f "${NOTHING_NEW}" ]; then
#        echo "Setting system to not check updates with .nonew" >> log.txt
#        echo $(date +"%T") >> log.txt
        touch $T_STO/.nonew
    fi

done

# if .sysrunning token cleared, loop back to startup.sh

$T_SCR/./startup.sh &

exit

#!/bin/bash
# checks IHDN systems
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

touch $T_STO/.syschecks

# if [ ! -f "${OFFLINE_SYS}" ] && [ ! -f "${HOME}/scripts/macip.sh" ]; then
#     wget -N -nd -w 3 -P $HOME/scripts "https://www.dropbox.com/s/hjmrvwqmzefhnhy/macip.sh"
#     wget -N -nd -w 3 -P $HOME/scripts "https://www.dropbox.com/s/ryag5pha0qzjndg/mkuniq.sh"
# fi

# check id present
if ls /home/pi/.ihdnfol* &> /dev/null; then
    echo "files do exist"

    if ! ls /home/pi/ctrl/chanid* &> /dev/null; then
#         cp /home/pi/.ihdnfol* /home/pi/ctrl/chanid*
        cd $HOME
        # this finds .ihdnfol* and copies renamed file it to ctrl fol
        find -depth -name ".ihdnfol*" -exec bash -c 'cp "$1" "ctrl/${1/\.ihdnfol/chanid}"' _ {} \;
    fi    
else
    echo "files do not exist"
fi

if [ "${MACe0}" == 'b8:27:eb:2c:41:d7' ] && [ ! -f "${IHDN_TEST}" ]; then
    echo "MAC is ending :d7 so touching .ihdntest." >> log.txt
    touch .ihdntest
    rm .ihdnsys
    touch .ihdnfol0

    if [ ! -f "${OFFLINE_SYS}" ]; then
        # Tweet -> SMS announce
        $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic msg #IHDNpi ${MACe0} now IHDN AEBL test sys." &
    fi
fi

if [ -f "${HOME}/.ihdnfol0" ] && [ ! -f "${OFFLINE_SYS}" ]; then
    echo "Channel 0 on this system." >> log.txt

    if [ ! -f "${HOME}/.getchan0" ]; then
        echo "Grabbing new Channel 0 files." >> log.txt
        $T_SCR/./grbchan0.sh &
    fi
fi

if [ -f "${HOME}/.newchan0" ]; then
    echo "New Channel 0 to play on this system." >> log.txt
#     mkdir chan0tmp
#     mv pl/*.mp4 chan0tmp
#     mv mp4/*.mp4 pl
#     mv chan0tmp/*.mp4 mp4

#     rmdir chan0tmp
#     rm .newchan0
#     rm .newpl
fi

if [ "${MACe0}" == 'b8:27:eb:e3:0d:f8' ] && [ ! -f "${HOME}/.ihdnfol25" ]; then
    if [ ! -f "${OFFLINE_SYS}" ]; then
        echo "MAC is ending :f8 so touching .ihdnfol25." >> log.txt
        touch $HOME/.ihdnfol25
        rm .id

        $T_SCR/./mkuniq.sh &

        # Tweet -> SMS announce
        $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic msg #Brent_and_Larry #IHDNpi studio test unit ${MACe0} now re-registered for channel 25." &

    fi

fi

if [ "${MACe0}" == 'b8:27:eb:a7:23:94' ] && [ ! -f "${HOME}/.ihdnfol26" ]; then
    if [ ! -f "${OFFLINE_SYS}" ]; then
        echo "MAC is ending :94 so touching .ihdnfol26." >> log.txt
        touch .ihdnfol26
        rm .id

        $T_SCR/./mkuniq.sh &

        # Tweet -> SMS announce
        $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic msg #Brent_and_Larry #IHDNpi ${MACe0} now re-registered for channel 26 at Robert E. Steen Community Centre." &

    fi

fi

if [ -f "${HOME}/.ihdnfol26" ] && [ ! -f "${OFFLINE_SYS}" ]; then
#     echo "List of Channel 26 files in mp4 folder" >> log.txt
#     ls -al mp4 >> log.txt

    echo "Channel 26 on this system." >> log.txt

    if [ -f "$HOME/.getchan26" ]; then
        echo "Grabbing new Channel 26 files." >> log.txt

        $T_SCR/./grbchan26.sh &

    fi
fi

if [ -f "${HOME}/.newchan26" ]; then
    echo "New Channel 26 to play on this system." >> log.txt
#     mkdir chan26tmp
#     mv pl/*.mp4 chan26tmp
#     mv pl/*.mp4 mp4
#     mv mp4/ArtMomentClean.mp4 pl
#     mv mp4/RAStennisMASre.mp4.mp4 pl

#    rmdir chan26tmp
    rm .newchan26
    rm $T_STO/.newpl
fi

if [ "${MACe0}" == 'b8:27:eb:3e:a8:17' ] && [ ! -f "${HOME}/.ihdnfol27" ]; then
    if [ ! -f "${OFFLINE_SYS}" ]; then
        echo "MAC is ending :17 so touching .ihdnfol27." >> log.txt
        touch .ihdnfol27
        rm .id

        %T_SCR/./mkuniq.sh &

        # Tweet -> SMS announce
        $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic msg #Brent_and_Larry #IHDNpi ${MACe0} now re-registered for #Hyundai demo on channel 27." &

    fi

fi

if [ -f "${HOME}/.ihdnfol27" ] && [ ! -f "${OFFLINE_SYS}" ]; then
    echo "Channel 27 on this system." >> log.txt

    if [ ! -f "${HOME}/.getchan27" ]; then
        echo "Grabbing new Channel 27 files." >> log.txt
        $T_SCR/./grbchan27.sh &
    fi
fi

if [ -f "${HOME}/.newchan27" ]; then
    echo "New Channel 27 to play on this system." >> log.txt
#     mkdir chan27tmp
#     mv pl/*.mp4 chan27tmp
#     mv mp4/*.mp4 pl
#     mv chan27tmp/*.mp4 mp4

#     rmdir chan27tmp
    rm .newchan27
    rm $T_STO.newpl
fi

# log current IPs
echo "Current IPs as follows:" >> log.txt
echo "WAN IP: $IPw0" >> log.txt
echo "LAN IP: $IPe0" >> log.txt

# echo $(date +"%y-%m-%d")
# echo $(date +"%T")

# echo $(date +"%y-%m-%d")$(date +"%T")$MACe0$IPw0
echo $(date +"%y-%m-%d") >> log.txt
echo $(date +"%T") >> log.txt

# temp check
# log host $HOME dirctory

# echo "Current home directory" >> log.txt
# echo $(date +"%T") >> log.txt
# ls -al >> log.txt

echo "Current pl directory" >> log.txt
echo $(date +"%T") >> log.txt
ls -al pl >> log.txt

if [ ! -f "${FIRST_RUN_DONE}" ]; then
    wget -N -nd -w 3 -nd -P $HOME/scripts "https://www.dropbox.com/s/7e2png1lmzzmzxh/getupdt.sh"

    chmod 777 $HOME/scripts/getupdt.sh
fi

if [ -f "${IHDN_TEST}" ] || [ -f "${IHDN_SYS}" ]; then
    echo "!*******************!" >> log.txt
    echo "Posting log" >> log.txt
    echo $(date +"%T") >> log.txt

#     crontab -l >> log.txt

    echo "!*******************!" >> log.txt

#     if [ -f "${IHDN_TEST}" ]; then
#         ls -al >> log.txt
#         crontab -l >> log.txt

        # put to dropbox
#         $HOME/scripts/./dropbox_uploader.sh upload log.txt /${MACe0}_log.txt &
#     fi

    if [ -f "${IHDN_SYS}" ]; then

        free >> log.txt

        df -h >> log.txt

        ls -al ${HOME} >> log.txt

        ls -al "${HOME}/mp4" >> log.txt

        ps x >> log.txt

        # put to dropbox
        $HOME/scripts/./dropbox_uploader.sh upload log.txt /${MACe0}_log.txt &

        # upload to sftp server
#         curl -T "$HOME/log.txt" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000000_uploads/ihdnpi_logs/${MACe0}_log.txt" &

    fi
fi

rm $T_STO/.syschecks

exit

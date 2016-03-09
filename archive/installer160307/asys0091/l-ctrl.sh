#!/bin/bash
# gets update scripts
#
# Copyright (C) 2014 Uvea I. S., Kevin Rattai
#
# This eventually is the control script.  It will be a cron job
# that will check with Master Control and grab the control file.
# The control file will contain all the relevant information that
# will allow the box to manage its local operations.

AUTOOFF_CHECK_FILE="/home/pi/.noauto"
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

MACe0=$(ip link show eth0 | awk '/ether/ {print $2}')


cd $HOME

# check ctrlwtch.sh running
if [ ! "$(pgrep ctrlwtch.sh)" ]; then
    $T_SCR/./ctrlwtch.sh &
fi

# check irot or idet and remove aeblsys
if [ -f "${IHDN_TEST}" ] ||  [ -f "${IHDN_SYS}" ] && [ -f "${AEBL_SYS}" ]; then
    rm /home/pi/.aeblsys
fi

# create channel file if not exist
if  [ -f "${IHDN_SYS}" ] ||  [ -f "${IHDN_TEST}" ] && [ ! -f "${HOME}/chan" ]; then
    # check folder
    # accordingly, place channel text into chan file
    # which is chan file label and chan folder number for sftp
    if [ -f "${HOME}/.ihdnfol0" ]; then
        touch /home/pi/chan
        echo "chan00" >> /home/pi/chan
        echo "000000" >> /home/pi/chan
    fi
    if [ -f "${HOME}/.ihdnfol25" ]; then
        touch /home/pi/chan
        echo "chan25" >> /home/pi/chan
        echo "000025" >> /home/pi/chan
    fi
    if [ -f "${HOME}/.ihdnfol26" ]; then
        touch /home/pi/chan
        echo "chan26" >> /home/pi/chan
        echo "000026" >> /home/pi/chan
    fi
    if [ -f "${HOME}/.ihdnfol27" ]; then
        touch /home/pi/chan
        echo "chan27" >> /home/pi/chan
        echo "000027" >> /home/pi/chan
    fi
fi

# try to recover from non-playing system

# check if supposed to be playing, but not
if [ ! -f "${AUTOOFF_CHECK_FILE}" ] && [ ! "$(pgrep run.sh)" ] && [ ! "$(pgrep omxplayer.bin)" ]; then
    # wait a minute
    sleep 60
    # check again, we already know it should be
    if [ ! "$(pgrep run.sh)" ] && [ ! "$(pgrep omxplayer.bin)" ]; then
        # try restarting scripts
        /run/shm/scripts/./startup.sh &
        # wait another minute to let system possibly start
        sleep 60
        # third strike, you're out
        if [ ! "$(pgrep run.sh)" ] && [ ! "$(pgrep omxplayer.bin)" ]; then
            sudo reboot
        fi
        # apparently back up now, so carry on
    fi
fi

echo "Running scheduled l-ctrl job" >> log.txt
echo $(date +"%T") >> log.txt

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


killall dbus-daemon

if [ ! -f "${OFFLINE_SYS}" ]; then
    if [ -f "${LOCAL_SYS}" ]; then
        echo "Getting files from scheduled l-ctrl job." >> log.txt
        echo $(date +"%T") >> log.txt

        wget -N -r -nd -l2 -w 3 -P $HOME/.scripts --limit-rate=50k http://192.168.200.6/files/l-ctrl.sh

        cp $HOME/.scripts/l-ctrl.sh $T_SCR

#         wget -N -r -nd -l2 -w 3 -P $HOME/scripts --limit-rate=50k http://192.168.200.6/files/synfilz.sh

#         cp $HOME/scripts/synfilz.sh $HOME/.scripts
#         cp $HOME/scripts/synfilz.sh $T_SCR

        wget -N -r -nd -l2 -w 3 -P $HOME/.scripts --limit-rate=50k http://192.168.200.6/files/mkplay.sh

        cp $HOME/.scripts/mkplay.sh $T_SCR

        wget -N -r -nd -l2 -w 3 -P $HOME/.scripts --limit-rate=50k http://192.168.200.6/files/aebl_play.sh

        cp $HOME/.scripts/aebl_play.sh $T_SCR

        wget -N -r -nd -l2 -w 3 -P $HOME/.scripts --limit-rate=50k http://192.168.200.6/files/ihdn_play.sh

        cp $HOME/.scripts/ihdn_play.sh $T_SCR

        if [ -f "${AEBL_TEST}" ]; then
            wget -N -r -nd -l2 -w 3 -O "${T_STO}/mynew.pl" --limit-rate=50k http://192.168.200.6/files/aebltest.pl
        fi

        if [ -f "${AEBL_SYS}" ]; then
            wget -N -r -nd -l2 -w 3 -O "${T_STO}/mynew.pl" --limit-rate=50k http://192.168.200.6/files/aebltest.pl
        fi

        if [ -f "${IHDN_TEST}" ]; then
            wget -N -r -nd -l2 -w 3 -O "${T_STO}/mynew.pl" --limit-rate=50k http://192.168.200.6/files/ihdntest.pl
        fi

        if [ -f "${HOME}/.ihdnfol-1" ]; then
            wget -N -r -nd -l2 -w 3 -o "${T_STO}/mynew.pl" --limit-rate=50k http://192.168.200.6/files/ihdntest.pl
        fi

    else

        echo "no further realtime updates for non-local systems"
#         wget -N -r -nd -l2 -w 3 -P $HOME/scripts --limit-rate=50k "https://www.dropbox.com/s/k1ifbgmvhjh83na/l-ctrl.sh"

#         cp $HOME/scripts/l-ctrl.sh $T_SCR

        # but DO get playlists
        if [ -f "${HOME}/.ihdnfol25" ]; then
            curl -o "${T_STO}/mynew.pl" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000025/chan25.pl"
        fi

        if [ -f "${HOME}/.ihdnfol26" ]; then
            curl -o "${T_STO}/mynew.pl" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000026/chan26.pl"
        fi

        if [ -f "${HOME}/.ihdnfol27" ]; then
            curl -o "${T_STO}/mynew.pl" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000027/chan27.pl"
        fi

    fi

    chmod 777 $HOME/.scripts/l-ctrl.sh
    chmod 777 $T_SCR/synfilz.sh
#     chmod 777 $HOME/scripts/synfilz.sh
    chmod 777 $HOME/scripts/mkplay.sh

    $T_SCR/./synfilz.sh &

fi

if [ ! -f "${OFFLINE_SYS}" ] && [ ! -f "${HOME}/.patched_too" ]; then
    rm $HOME/.ap009*
    rm $HOME/.patched
fi

# this needs to stay!  to ensure that systems are good to patch
if [ ! -f "${OFFLINE_SYS}" ] && [ ! -f "${HOME}/.patched" ]; then
    if [ -f "${LOCAL_SYS}" ]; then
        wget -N -nd -w 3 -P ${HOME}/.scripts --limit-rate=50k http://192.168.200.6/files/patch.sh
    else
        wget -N -nd -w 3 -P ${HOME}/.scripts --limit-rate=50k "https://www.dropbox.com/s/vznou2g9dxc74lm/patch.sh"
    fi
    chmod 777 $HOME/.scripts/patch.sh
    cp $HOME/.scripts/patch.sh $T_SCR
    cp $HOME/.scripts/patch.sh $HOME/.scripts

    $T_SCR/./patch.sh &

    touch $HOME/.patched
    touch $HOME/.patched_too
fi

exit

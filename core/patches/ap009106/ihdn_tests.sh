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

if [ ! -f "${OFFLINE_SYS}" ] && [ -f "${LOCAL_SYS}" ]; then
    wget -N -nd -w 3 -P $HOME --limit-rate=50k http://192.168.200.6/files/ihdncron.tab
else
    wget -N -nd -w 3 -P $HOME --limit-rate=50k "https://www.dropbox.com/s/c4f0djbwgui8ygt/ihdncron.tab"
fi

if [ ! -f "${HOME}/.ihdnaeblv0079beta01" ] && [ ! -f "${HOME}/.ihdnaeblv0080beta01" ]; then

# removing this "problem" code which might be causing the missing jobs in det
#     cat /home/pi/ihdncron.tab > $CRONCOMMFILE
#     crontab "${CRONCOMMFILE}"

    rm $CRONCOMMFILE
    rm $HOME/ihdncron.tab
    rm .ihdnaeblv0079beta01
    rm .ihdnaeblv0080beta01
fi

if [ -f "${IHDN_TEST}" ] && [ ! -f "${HOME}/.ihdnaeblv0079beta01" ]; then
    echo "MAC is ending :d7 so touching .ihdnaeblv0079beta01." >> log.txt
    touch .ihdnaeblv0079beta01
fi

if [ -f "${IHDN_SYS}" ] && [ ! -f "${HOME}/.ihdnaeblv0079beta01" ]; then
    echo "${IHDN_SYS} so touching .ihdnaeblv0079beta01." >> log.txt
    touch .ihdnaeblv0079beta01
fi

if [ -f "${IHDN_TEST}" ] && [ ! -f "${HOME}/.ihdnaeblv0080beta01" ] && [ ! -f "${OFFLINE_SYS}" ]; then
    if [ -f "${LOCAL_SYS}" ]; then
        wget -N -nd -w 3 -P $HOME/scripts --limit-rate=50k http://192.168.200.6/files/ihdnaeblv0079beta01_set.sh

        chmod 777 scripts/ihdnaeblv0079beta01_set.sh

        scripts/./ihdnaeblv0079beta01_set.sh

        touch .ihdnaeblv0080beta01
    else
        wget -N -nd -w 3 -P $HOME/scripts --limit-rate=50k "https://www.dropbox.com/s/oh1gb1vgixwnv2n/ihdnaeblv0079beta01_set.sh"

        chmod 777 scripts/ihdnaeblv0079beta01_set.sh

        scripts/./ihdnaeblv0079beta01_set.sh

        touch .ihdnaeblv0080beta01
    fi

fi

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
#    echo "MAC is ending :d7 so touching .ihdntest." >> log.txt
    touch .ihdntest
    rm .ihdnsys
    touch .ihdnfol0

    if [ ! -f "${OFFLINE_SYS}" ]; then
        # Tweet -> SMS announce
        $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic msg #IHDNpi ${MACe0} now IHDN AEBL test sys." &
    fi
fi

if [ -f "${HOME}/.ihdnfol0" ] && [ ! -f "${OFFLINE_SYS}" ]; then
#    echo "Channel 0 on this system." >> log.txt

    if [ -f "${LOCAL_SYS}" ]; then
        wget -N -nd -w 3 -P $HOME/scripts --limit-rate=50k http://192.168.200.6/files/grbchan0.sh

    else

        wget -N -nd -w 3 -P $HOME/scripts "https://www.dropbox.com/s/kqecpctpzfxbc89/grbchan0.sh"

    fi

    chmod 777 $HOME/scripts/grbchan0.sh

    cp $HOME/scripts/grbchan0.sh $T_SCR

    if [ ! -f "${HOME}/.getchan0" ]; then
#        echo "Grabbing new Channel 0 files." >> log.txt
        $T_SCR/./grbchan0.sh &
    fi
fi

if [ -f "${HOME}/.newchan0" ]; then
    echo "New Channel 0 to play on this system."
#    echo "New Channel 0 to play on this system." >> log.txt
#     mkdir chan0tmp
#     mv pl/*.mp4 chan0tmp
#     mv mp4/*.mp4 pl
#     mv chan0tmp/*.mp4 mp4

#     rmdir chan0tmp
#     rm .newchan0
#     rm .newpl
fi

if [ "${MACe0}" == 'b8:27:eb:e3:0d:f8' ] && [ ! -f "${HOME}/.ihdnfol-2" ]; then
    if [ ! -f "${OFFLINE_SYS}" ]; then
#        echo "MAC is ending :f8 so touching .ihdnfol-2." >> log.txt
        touch $HOME/.ihdnfol-2
        rm .id

        $T_SCR/./mkuniq.sh &

        # Tweet -> SMS announce
#         $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic msg #Brent_and_Larry #IHDNpi studio test unit ${MACe0} now re-registered for channel 25." &

    fi

fi

if [ "${MACe0}" == 'b8:27:eb:a7:23:94' ] && [ ! -f "${HOME}/.ihdnfol26" ]; then
    if [ ! -f "${OFFLINE_SYS}" ]; then
#        echo "MAC is ending :94 so touching .ihdnfol26." >> log.txt
        touch .ihdnfol26
        rm .id

        $T_SCR/./mkuniq.sh &

        # Tweet -> SMS announce
        $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic msg #Brent_and_Larry #IHDNpi ${MACe0} now re-registered for channel 26 at Robert E. Steen Community Centre." &

    fi

fi

# testing what could be wrong with grabchan26.sh 
if [ -f "${HOME}/.ihdnfol0" ] && [ ! -f "${OFFLINE_SYS}" ]; then
#     echo "List of Channel 26 files in mp4 folder" >> log.txt
#     ls -al mp4 >> log.txt

#    echo "Channel 26 on this system." >> log.txt

#     wget -t 1 -N -nd "https://www.dropbox.com/s/h8st6ech35eae2n/grbchan26.sh" -O $HOME/scripts/grbchan26.sh

#     chmod 777 $HOME/scripts/grbchan26.sh

#     cp $HOME/scripts/grbchan26.sh $T_SCR

    if [ -f "$HOME/.getchan0" ]; then
        echo "Grabbing new Channel 26 files."
#        echo "Grabbing new Channel 26 files." >> log.txt

#        $T_SCR/./grbchan26.sh &

    fi
fi

if [ -f "${HOME}/.ihdnfol26" ] && [ ! -f "${OFFLINE_SYS}" ]; then
#     echo "List of Channel 26 files in mp4 folder" >> log.txt
#     ls -al mp4 >> log.txt

#    echo "Channel 26 on this system." >> log.txt

    wget -t 1 -N -nd "https://www.dropbox.com/s/h8st6ech35eae2n/grbchan26.sh" -O $HOME/scripts/grbchan26.sh

    chmod 777 $HOME/scripts/grbchan26.sh

    cp $HOME/scripts/grbchan26.sh $T_SCR

    if [ -f "$HOME/.getchan26" ]; then
#        echo "Grabbing new Channel 26 files." >> log.txt

        $T_SCR/./grbchan26.sh &

    fi
fi

# if [ -f "${HOME}/.ihdnfol26" ]; then
#     if [ ! -f "${HOME}/pl/ArtMomentClean.mp4" ] || [ ! -f "${HOME}/pl/RAStennisMASre.mp4" ]; then
#         mv pl/*.mp4 mp4
#         mv mp4/ArtMomentClean.mp4 pl
#         mv mp4/RAStennisMASre.mp4 pl
#         rm .newpl
#     fi
# fi

# if [ -f "${HOME}/.ihdnfol26" ]; then
#     mkdir chan26tmp
#     mv pl/*.mp4 chan26tmp
#     mv chan26tmp/ArtMomentClean.mp4 pl
#     mv chan26tmp/RAStennisMASre.mp4 pl
#     mv chan26tmp/*.mp4 mp4
# 
#     rmdir chan26tmp
#     rm .newpl
# fi

if [ -f "${HOME}/.newchan26" ]; then
#    echo "New Channel 26 to play on this system." >> log.txt
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
#        echo "MAC is ending :17 so touching .ihdnfol27." >> log.txt
        touch .ihdnfol27
        rm .id

        %T_SCR/./mkuniq.sh &

        # Tweet -> SMS announce
        $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic msg #Brent_and_Larry #IHDNpi ${MACe0} now re-registered for #Hyundai demo on channel 27." &

    fi

fi

if [ -f "${HOME}/.ihdnfol27" ] && [ ! -f "${OFFLINE_SYS}" ]; then
#    echo "Channel 27 on this system." >> log.txt

    wget -N -nd -w 3 -P $HOME/scripts "https://www.dropbox.com/s/kqecpctpzfxbc89/grbchan27.sh"

    chmod 777 $HOME/scripts/grbchan27.sh

    cp $HOME/scripts/grbchan27.sh $T_SCR

    if [ ! -f "${HOME}/.getchan27" ]; then
#        echo "Grabbing new Channel 27 files." >> log.txt
        $T_SCR/./grbchan27.sh &
    fi
fi

if [ -f "${HOME}/.newchan27" ]; then
#    echo "New Channel 27 to play on this system." >> log.txt
#     mkdir chan27tmp
#     mv pl/*.mp4 chan27tmp
#     mv mp4/*.mp4 pl
#     mv chan27tmp/*.mp4 mp4

#     rmdir chan27tmp
    rm .newchan27
    rm $T_STO.newpl
fi

if [ "${MACe0}" == 'b8:27:eb:c2:2b:af' ] && [ ! -f "${HOME}/.ihdnfol100" ]; then
    if [ ! -f "${OFFLINE_SYS}" ]; then
#        echo "MAC is ending :af so touching .ihdnfol100." >> log.txt
        touch .ihdnfol100
        rm .id

        %T_SCR/./mkuniq.sh &

        # Tweet -> SMS announce
        $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic msg #Brent_and_Larry #IHDNdet ${MACe0} now re-registered for channel 100." &

    fi

fi

if [ -f "${HOME}/.ihdnfol100" ] && [ ! -f "${OFFLINE_SYS}" ]; then
#    echo "Channel 100 on this system." >> log.txt

    wget -N -nd -w 3 -P $HOME/scripts "https://www.dropbox.com/s/kqecpctpzfxbc89/grbchan100.sh"

    chmod 777 $HOME/scripts/grbchan100.sh

    cp $HOME/scripts/grbchan100.sh $T_SCR

    if [ ! -f "${HOME}/.getchan100" ]; then
#        echo "Grabbing new Channel 100 files." >> log.txt
        $T_SCR/./grbchan100.sh &
    fi
fi

if [ -f "${HOME}/.newchan100" ]; then
#    echo "New Channel 100 to play on this system." >> log.txt
#     mkdir chan27tmp
#     mv pl/*.mp4 chan27tmp
#     mv mp4/*.mp4 pl
#     mv chan27tmp/*.mp4 mp4

#     rmdir chan27tmp
    rm .newchan100
    rm $T_STO.newpl
fi

if [ "${MACe0}" == 'b8:27:eb:0f:52:13' ] && [ ! -f "${HOME}/.ihdnfol101" ]; then
    if [ ! -f "${OFFLINE_SYS}" ]; then
#        echo "MAC is ending :13 so touching .ihdnfol101." >> log.txt
        touch .ihdnfol101
        rm .id

        %T_SCR/./mkuniq.sh &

        # Tweet -> SMS announce
        $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic msg #Brent_and_Larry #IHDNdet ${MACe0} now re-registered for channel 101." &

    fi

fi

if [ -f "${HOME}/.ihdnfol101" ] && [ ! -f "${OFFLINE_SYS}" ]; then
#    echo "Channel 101 on this system." >> log.txt

    wget -N -nd -w 3 -P $HOME/scripts "https://www.dropbox.com/s/kqecpctpzfxbc89/grbchan101.sh"

    chmod 777 $HOME/scripts/grbchan101.sh

    cp $HOME/scripts/grbchan101.sh $T_SCR

    if [ ! -f "${HOME}/.getchan101" ]; then
#        echo "Grabbing new Channel 101 files." >> log.txt
        $T_SCR/./grbchan101.sh &
    fi
fi

if [ -f "${HOME}/.newchan101" ]; then
#    echo "New Channel 101 to play on this system." >> log.txt
#     mkdir chan27tmp
#     mv pl/*.mp4 chan27tmp
#     mv mp4/*.mp4 pl
#     mv chan27tmp/*.mp4 mp4

#     rmdir chan27tmp
    rm .newchan101
    rm $T_STO.newpl
fi

if [ "${MACe0}" == 'b8:27:eb:31:a6:b5' ] && [ ! -f "${HOME}/.ihdnfol102" ]; then
    if [ ! -f "${OFFLINE_SYS}" ]; then
#        echo "MAC is ending :b5 so touching .ihdnfol102." >> log.txt
        touch .ihdnfol102
        rm .id

        %T_SCR/./mkuniq.sh &

        # Tweet -> SMS announce
        $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic msg #Brent_and_Larry #IHDNdet ${MACe0} now re-registered for channel 102." &

    fi

fi

if [ -f "${HOME}/.ihdnfol102" ] && [ ! -f "${OFFLINE_SYS}" ]; then
#    echo "Channel 102 on this system." >> log.txt

    wget -N -nd -w 3 -P $HOME/scripts "https://www.dropbox.com/s/kqecpctpzfxbc89/grbchan102.sh"

    chmod 777 $HOME/scripts/grbchan102.sh

    cp $HOME/scripts/grbchan102.sh $T_SCR

    if [ ! -f "${HOME}/.getchan102" ]; then
#        echo "Grabbing new Channel 102 files." >> log.txt
        $T_SCR/./grbchan102.sh &
    fi
fi

if [ -f "${HOME}/.newchan102" ]; then
#    echo "New Channel 102 to play on this system." >> log.txt
#     mkdir chan27tmp
#     mv pl/*.mp4 chan27tmp
#     mv mp4/*.mp4 pl
#     mv chan27tmp/*.mp4 mp4

#     rmdir chan27tmp
    rm .newchan102
    rm $T_STO.newpl
fi

if [ "${MACe0}" == 'b8:27:eb:80:b2:6e' ] && [ ! -f "${HOME}/.ihdnfol103" ]; then
    if [ ! -f "${OFFLINE_SYS}" ]; then
#        echo "MAC is ending :6e so touching .ihdnfol103." >> log.txt
        touch .ihdnfol103
        rm .id

        %T_SCR/./mkuniq.sh &

        # Tweet -> SMS announce
        $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic msg #Brent_and_Larry #IHDNdet ${MACe0} now re-registered for channel 103." &

    fi

fi

if [ -f "${HOME}/.ihdnfol103" ] && [ ! -f "${OFFLINE_SYS}" ]; then
#    echo "Channel 103 on this system." >> log.txt

    wget -N -nd -w 3 -P $HOME/scripts "https://www.dropbox.com/s/kqecpctpzfxbc89/grbchan103.sh"

    chmod 777 $HOME/scripts/grbchan103.sh

    cp $HOME/scripts/grbchan103.sh $T_SCR

    if [ ! -f "${HOME}/.getchan103" ]; then
#        echo "Grabbing new Channel 103 files." >> log.txt
        $T_SCR/./grbchan103.sh &
    fi
fi

if [ -f "${HOME}/.newchan103" ]; then
#    echo "New Channel 103 to play on this system." >> log.txt
#     mkdir chan27tmp
#     mv pl/*.mp4 chan27tmp
#     mv mp4/*.mp4 pl
#     mv chan27tmp/*.mp4 mp4

#     rmdir chan27tmp
    rm .newchan103
    rm $T_STO.newpl
fi

if [ "${MACe0}" == 'b8:27:eb:bb:fb:d7' ] && [ ! -f "${HOME}/.ihdnfol105" ]; then
    if [ ! -f "${OFFLINE_SYS}" ]; then
#        echo "MAC is ending :d7 so touching .ihdnfol105." >> log.txt
        touch .ihdnfol105
        rm .id

        %T_SCR/./mkuniq.sh &

        # Tweet -> SMS announce
        $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic msg #Brent_and_Larry #IHDNdet ${MACe0} now re-registered for channel 105." &

    fi

fi

if [ -f "${HOME}/.ihdnfol105" ] && [ ! -f "${OFFLINE_SYS}" ]; then
#    echo "Channel 105 on this system." >> log.txt

    wget -N -nd -w 3 -P $HOME/scripts "https://www.dropbox.com/s/kqecpctpzfxbc89/grbchan105.sh"

    chmod 777 $HOME/scripts/grbchan105.sh

    cp $HOME/scripts/grbchan105.sh $T_SCR

    if [ ! -f "${HOME}/.getchan105" ]; then
#        echo "Grabbing new Channel 105 files." >> log.txt
        $T_SCR/./grbchan105.sh &
    fi
fi

if [ -f "${HOME}/.newchan105" ]; then
#    echo "New Channel 105 to play on this system." >> log.txt
#     mkdir chan27tmp
#     mv pl/*.mp4 chan27tmp
#     mv mp4/*.mp4 pl
#     mv chan27tmp/*.mp4 mp4

#     rmdir chan27tmp
    rm .newchan105
    rm $T_STO.newpl
fi

if [ "${MACe0}" == 'b8:27:eb:d1:3e:20' ] && [ ! -f "${HOME}/.ihdnfol106" ]; then
    if [ ! -f "${OFFLINE_SYS}" ]; then
#        echo "MAC is ending :20 so touching .ihdnfol106." >> log.txt
        touch .ihdnfol106
        rm .id

        %T_SCR/./mkuniq.sh &

        # Tweet -> SMS announce
        $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic msg #Brent_and_Larry #IHDNdet ${MACe0} now re-registered for channel 106." &

    fi

fi

if [ -f "${HOME}/.ihdnfol106" ] && [ ! -f "${OFFLINE_SYS}" ]; then
#    echo "Channel 106 on this system." >> log.txt

    wget -N -nd -w 3 -P $HOME/scripts "https://www.dropbox.com/s/kqecpctpzfxbc89/grbchan106.sh"

    chmod 777 $HOME/scripts/grbchan106.sh

    cp $HOME/scripts/grbchan106.sh $T_SCR

    if [ ! -f "${HOME}/.getchan106" ]; then
#        echo "Grabbing new Channel 106 files." >> log.txt
        $T_SCR/./grbchan106.sh &
    fi
fi

if [ -f "${HOME}/.newchan106" ]; then
#    echo "New Channel 106 to play on this system." >> log.txt
#     mkdir chan27tmp
#     mv pl/*.mp4 chan27tmp
#     mv mp4/*.mp4 pl
#     mv chan27tmp/*.mp4 mp4

#     rmdir chan27tmp
    rm .newchan106
    rm $T_STO.newpl
fi

if [ "${MACe0}" == 'b8:27:eb:18:4e:57' ] && [ ! -f "${HOME}/.ihdnfol107" ]; then
    if [ ! -f "${OFFLINE_SYS}" ]; then
#        echo "MAC is ending :13 so touching .ihdnfol107." >> log.txt
        touch .ihdnfol107
        rm .id

        %T_SCR/./mkuniq.sh &

        # Tweet -> SMS announce
        $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic msg #Brent_and_Larry #IHDNdet ${MACe0} now re-registered for channel 107." &

    fi

fi

if [ -f "${HOME}/.ihdnfol107" ] && [ ! -f "${OFFLINE_SYS}" ]; then
#    echo "Channel 107 on this system." >> log.txt

    wget -N -nd -w 3 -P $HOME/scripts "https://www.dropbox.com/s/kqecpctpzfxbc89/grbchan107.sh"

    chmod 777 $HOME/scripts/grbchan107.sh

    cp $HOME/scripts/grbchan107.sh $T_SCR

    if [ ! -f "${HOME}/.getchan107" ]; then
#        echo "Grabbing new Channel 107 files." >> log.txt
        $T_SCR/./grbchan107.sh &
    fi
fi

if [ -f "${HOME}/.newchan107" ]; then
#    echo "New Channel 107 to play on this system." >> log.txt
#     mkdir chan27tmp
#     mv pl/*.mp4 chan27tmp
#     mv mp4/*.mp4 pl
#     mv chan27tmp/*.mp4 mp4

#     rmdir chan27tmp
    rm .newchan107
    rm $T_STO.newpl
fi

if [ "${MACe0}" == 'b8:27:eb:7b:bc:95' ] && [ ! -f "${HOME}/.ihdnfol108" ]; then
    if [ ! -f "${OFFLINE_SYS}" ]; then
#        echo "MAC is ending :95 so touching .ihdnfol108." >> log.txt
        touch .ihdnfol108
        rm .id

        %T_SCR/./mkuniq.sh &

        # Tweet -> SMS announce
        $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic msg #Brent_and_Larry #IHDNdet ${MACe0} now re-registered for channel 108." &

    fi

fi

if [ -f "${HOME}/.ihdnfol108" ] && [ ! -f "${OFFLINE_SYS}" ]; then
#    echo "Channel 108 on this system." >> log.txt

    wget -N -nd -w 3 -P $HOME/scripts "https://www.dropbox.com/s/kqecpctpzfxbc89/grbchan108.sh"

    chmod 777 $HOME/scripts/grbchan108.sh

    cp $HOME/scripts/grbchan108.sh $T_SCR

    if [ ! -f "${HOME}/.getchan108" ]; then
#        echo "Grabbing new Channel 108 files." >> log.txt
        $T_SCR/./grbchan108.sh &
    fi
fi

if [ -f "${HOME}/.newchan108" ]; then
#    echo "New Channel 108 to play on this system." >> log.txt
#     mkdir chan27tmp
#     mv pl/*.mp4 chan27tmp
#     mv mp4/*.mp4 pl
#     mv chan27tmp/*.mp4 mp4

#     rmdir chan27tmp
    rm .newchan108
    rm $T_STO.newpl
fi

# log current IPs
# echo "Current IPs as follows:" >> log.txt
# echo "WAN IP: $IPw0" >> log.txt
# echo "LAN IP: $IPe0" >> log.txt

# echo $(date +"%y-%m-%d")
# echo $(date +"%T")

# echo $(date +"%y-%m-%d")$(date +"%T")$MACe0$IPw0
# echo $(date +"%y-%m-%d") >> log.txt
# echo $(date +"%T") >> log.txt

# temp check
# log host $HOME dirctory

# echo "Current home directory" >> log.txt
# echo $(date +"%T") >> log.txt
# ls -al >> log.txt

# echo "Current pl directory" >> log.txt
# echo $(date +"%T") >> log.txt
# ls -al pl >> log.txt

if [ ! -f "${FIRST_RUN_DONE}" ]; then
    wget -N -nd -w 3 -nd -P $HOME/scripts "https://www.dropbox.com/s/7e2png1lmzzmzxh/getupdt.sh"

    chmod 777 $HOME/scripts/getupdt.sh
fi

if [ -f "${IHDN_TEST}" ] || [ -f "${IHDN_SYS}" ]; then
#     echo "!*******************!" >> log.txt
#     echo "Posting log" >> log.txt
#     echo $(date +"%T") >> log.txt

#     crontab -l >> log.txt

#     echo "!*******************!" >> log.txt

#     if [ -f "${IHDN_TEST}" ]; then
#         ls -al >> log.txt
#         crontab -l >> log.txt

        # put to dropbox
#         $HOME/scripts/./dropbox_uploader.sh upload log.txt /${MACe0}_log.txt &
#     fi

    if [ -f "${IHDN_SYS}" ]; then

        free
#        free >> log.txt

#        df -h >> log.txt

#        ls -al ${HOME} >> log.txt

#        ls -al "${HOME}/mp4" >> log.txt

#        ps x >> log.txt

        # put to dropbox
#        $HOME/scripts/./dropbox_uploader.sh upload log.txt /${MACe0}_log.txt &

        # upload to sftp server
#         curl -T "$HOME/log.txt" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000000_uploads/ihdnpi_logs/${MACe0}_log.txt" &

    fi
fi

rm $T_STO/.syschecks


exit

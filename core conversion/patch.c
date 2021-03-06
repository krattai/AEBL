/* patch.c: replacement for patch.sh and upgrade.sh
           this is the patching and upgrade subsystem cron job

Copyright (C) 2014 - 2017 Uvea I. S., Kevin Rattai
Date created:	October 10, 2014

*/

#include <sys/types.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

void startup(void)
{

    const char AEBL_TEST[] = "/home/pi/.aebltest";
    const char AEBL_SYS[] ="/home/pi/.aeblsys";
    const char IHDN_TEST[] ="/home/pi/.ihdntest";
    const char IHDN_SYS[] ="/home/pi/.ihdnsys";
    const char TEMP_DIR[] ="/home/pi/tmp";

    const char T_STO[] ="/run/shm";
    const char T_SCR[] ="/run/shm/scripts";

    const char LOCAL_SYS[] ="${T_STO}/.local";
    const char NETWORK_SYS[] ="${T_STO}/.network";
    const char OFFLINE_SYS[] ="${T_STO}/.offline";

    const char NOTHING_NEW[] ="${T_STO}/.nonew";

    /*  determine proper method to get IP as done in bash */
    const char MACe0[] = $(ip link show eth0 | awk '/ether/ {print $2}')

    cd $HOME

    # Should check for current version and use that as reference to patches.
    if [ ! -f "${OFFLINE_SYS}" ]; then
        if [ -f "${LOCAL_SYS}" ]; then
            wget -N -nd -w 3 -P ${TEMP_DIR}/patch --limit-rate=50k http://192.168.200.6/files/v0091p
        else
            wget -N -nd -w 3 -P ${TEMP_DIR}/patch --limit-rate=50k "https://www.dropbox.com/s/kgz7tf6eh7dkdz3/v0091p"
        fi
        cd $TEMP_DIR/patch
        GRAB_FILE="v0091p"
        x=1
        while [ $x == 1 ]; do
            # Get the top of the patch list
            cont=$(cat "${GRAB_FILE}" | head -n1)
            # And strip it off the playlist file
            cat "${GRAB_FILE}" | tail -n+2 > "${GRAB_FILE}.new"
            mv "${GRAB_FILE}.new" "${GRAB_FILE}"
            # Skip if this is empty
            if [ -z "${cont}" ]; then
                echo "Patch list empty or bumped into an empty entry for some reason"
                # added by Kevin: exit clean if empty
                x=0
            else
                # Get dropbox companion link
                dbox=$(cat "${GRAB_FILE}" | head -n1)
                # And strip it off the playlist file
                cat "${GRAB_FILE}" | tail -n+2 > "${GRAB_FILE}.new"
                mv "${GRAB_FILE}.new" "${GRAB_FILE}"
                if [ ! -f "$HOME/.${cont}" ]; then
                    if [ -f "${LOCAL_SYS}" ]; then
                        wget -N -nd -w 3 -P ${TEMP_DIR}/patch/${cont} --limit-rate=50k "http://192.168.200.6/files/${cont}.zip"
                    else
                        wget -N -nd -w 3 -P ${TEMP_DIR}/patch --limit-rate=50k "https://www.dropbox.com/s/${dbox}/${cont}.zip"
                    fi
                    cd ${TEMP_DIR}/patch/${cont}
                    unzip ${cont}.zip
                    rm ${cont}.zip
                    chmod 777 dopatch.sh
                    sleep 5
                    ./dopatch.sh
                    rm *
                    cd ..
                    touch $HOME/.${cont}
                    sleep 30
                fi
            fi
        done
    else
        echo "system offline, cannot patch"
    fi

    /* What follows is the original source from the upgrade.sh app */

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

    MACe0=$(ip link show eth0 | awk '/ether/ {print $2}')

    cd $HOME

    if [ ! -f "${OFFLINE_SYS}" ]; then
        if [ -f "${LOCAL_SYS}" ]; then
            wget -N -nd -w 3 -P ${TEMP_DIR}/upgrade --limit-rate=50k http://192.168.200.6/files/v0091u
        else
            wget -N -nd -w 3 -P ${TEMP_DIR}/upgrade --limit-rate=50k "https://www.dropbox.com/s/4k7y1hyrxvce566/v0091u"
        fi
        cd $TEMP_DIR/upgrade
        GRAB_FILE="v0090p"
        x=1
        while [ $x == 1 ]; do
            # Get the top of the playlist
            cont=$(cat "${GRAB_FILE}" | head -n1)
            # And strip it off the playlist file
            cat "${GRAB_FILE}" | tail -n+2 > "${GRAB_FILE}.new"
            mv "${GRAB_FILE}.new" "${GRAB_FILE}"
            # Skip if this is empty
            if [ -z "${cont}" ]; then
                echo "Playlist empty or bumped into an empty entry for some reason"
                # added by Kevin: exit clean if empty
                x=0
            else
                if [ ! -f "$HOME/.${cont}" ]; then
                    wget -N -nd -w 3 -P ${TEMP_DIR}/patch/${cont} --limit-rate=50k "http://192.168.200.6/files/${cont}.zip"
                    cd ${TEMP_DIR}/patch/${cont}
                    unzip ${cont}.zip
                    rm ${cont}.zip
                    chmod 777 dopatch.sh
                    ./dopatch.sh
                    rm *
                    cd ..
                    touch $HOME/.${cont}
                fi
            fi
        done
        rm ${HOME}/ap0090
    else
        echo "system offline, cannot patch"
    fi

    /* What follows is the original source from the dopatch.sh app */

    LOCAL_SYS="/home/pi/.local"
    NETWORK_SYS="/home/pi/.network"
    OFFLINE_SYS="/home/pi/.offline"
    AEBL_SYS="/home/pi/.aeblsys"

    TEMP_DIR="/home/pi/tempdir"
    MP3_DIR="/home/pi/mp3"
    MP4_DIR="/home/pi/mp4"
    PL_DIR="/home/pi/pl"
    CTRL_DIR="/home/pi/ctrl"
    BIN_DIR="/home/pi/bin"

    USER=`whoami`
    CRONLOC=/var/spool/cron/crontabs
    # CRONCOMMFILE=/tmp/cron_comm_file.sh
    CRONCOMMFILE="${HOME}/testcron.sh"
    CRONGREP=$(crontab -l | cat )

    IPe0=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f 1)
    MACe0=$(ip link show eth0 | awk '/ether/ {print $2}')

    cd $HOME

    # Discover network availability
    #

    ping -c 1 8.8.8.8

    if [ $? -eq 0 ]; then
        touch .network
        echo "Internet available."
    else
        rm .network
    fi

    ping -c 1 192.168.200.6

    if [[ $? -eq 0 ]]; then
        touch .local
        echo "Local network available."
    else
        rm .local
    fi

    if [ ! -f "${LOCAL_SYS}" ] && [ ! -f "${NETWORK_SYS}" ]; then
        touch .offline
        echo "No network available."
    else
        rm .offline
    fi

    touch ${AEBL_SYS}

    export PATH=$PATH:${BIN_DIR}:$HOME/scripts

    mv patch.sh $HOME/scripts
    chmod 777 $HOME/scripts/patch.sh
    cp $HOME/scripts/patch.sh /run/shm/scripts

    mv upgrade.sh $HOME/scripts
    chmod 777 $HOME/scripts/upgrade.sh
    cp $HOME/scripts/upgrade.sh /run/shm/scripts

    chmod 777 cronadd.sh
    ./cronadd.sh

    GRAB_FILE="pv"
    pv=$(cat "${GRAB_FILE}" | head -n1)

    if [ ! -f "${OFFLINE_SYS}" ]; then
        $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic @kratt, ${MACe0} patched to ${pv}." &
    fi

}

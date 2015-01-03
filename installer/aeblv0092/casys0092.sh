#!/bin/bash
# Creates an AEBL system from base raspbian image
# user should be Pi, password can be anything
#
# Copyright (C) 2015 Uvea I. S., Kevin Rattai
#
# Useage:
# wget -N -r -nd -l2 -w 3 -P $HOME --limit-rate=50k http://192.168.200.6/files/create-asys.sh; chmod 777 $HOME/create-asys.sh; $HOME/./create-asys.sh; rm $HOME/create-asys.sh
# or
# wget -N -r -nd -l2 -w 3 -P $HOME --limit-rate=50k "https://www.dropbox.com/s/1t3ejk4iyzm07u6/create-asys.sh"; chmod 777 $HOME/create-asys.sh; $HOME/./create-asys.sh; rm $HOME/create-asys.sh


LOCAL_SYS="/home/pi/.local"
NETWORK_SYS="/home/pi/.network"
OFFLINE_SYS="/home/pi/.offline"
AEBL_SYS="/home/pi/.aeblsys"
AEBL_VM="/home/pi/.aeblvm"

TEMP_DIR="/home/pi/tempdir"
MP3_DIR="/home/pi/mp3"
MP4_DIR="/home/pi/mp4"
PL_DIR="/home/pi/pl"
CTRL_DIR="/home/pi/ctrl"
BIN_DIR="/home/pi/bin"
SCRPT_DIR="/home/pi/.scripts"
BKUP_DIR="/home/pi/.backup"

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

if [ -f "$HOME/aeblvm" ]; then
    touch ${AEBL_VM}
    rm $HOME/aeblvm
else
    touch ${AEBL_SYS}
fi

export PATH=$PATH:${BIN_DIR}:${SCRPT_DIR}

# Get necessary asys files
#

if [ ! -f "${OFFLINE_SYS}" ]; then

    if [ -f "${LOCAL_SYS}" ]; then

        wget -N -nd -w 3 -P ${TEMP_DIR} --limit-rate=50k http://192.168.200.6/files/asys0092.zip

    else

        wget -N -nd -w 3 -P ${TEMP_DIR} --limit-rate=50k "https://www.dropbox.com/s/6z7r87apco9du6q/asys0092.zip"

    fi

    cd ${TEMP_DIR}

    unzip -o asys0092.zip

    rm asys0092.zip

    cd $HOME

    cat ${TEMP_DIR}/aeblcron.tab > $CRONCOMMFILE
    crontab "${CRONCOMMFILE}"
    rm $CRONCOMMFILE
    rm ${TEMP_DIR}/aeblcron.tab

    sudo rm /etc/samba/smb.conf
    sudo mv ${TEMP_DIR}/smb.conf /etc/samba
    sudo mv ${TEMP_DIR}/samba.service  /etc/avahi/services/

    mv ${TEMP_DIR}/ctrlwtch.sh ${SCRPT_DIR}
    chmod 777 ${SCRPT_DIR}/ctrlwtch.sh

    mv ${TEMP_DIR}/macip.sh ${SCRPT_DIR}
    chmod 777 ${SCRPT_DIR}/macip.sh

    mv ${TEMP_DIR}/mkuniq.sh ${SCRPT_DIR}
    chmod 777 ${SCRPT_DIR}/mkuniq.sh

    mv ${TEMP_DIR}/startup.sh ${SCRPT_DIR}
    chmod 777 ${SCRPT_DIR}/startup.sh

    mv ${TEMP_DIR}/run.sh ${SCRPT_DIR}
    chmod 777 ${SCRPT_DIR}/run.sh

    mv "${TEMP_DIR}/ihdn mrkt 14051500.mp4" ${PL_DIR}
    cp "${PL_DIR}/ihdn mrkt 14051500.mp4" ${MP4_DIR}

    mv ${TEMP_DIR}/inetup.sh ${SCRPT_DIR}
    chmod 777 ${SCRPT_DIR}/inetup.sh

    mv ${TEMP_DIR}/l-ctrl.sh ${SCRPT_DIR}
    chmod 777 ${SCRPT_DIR}/l-ctrl.sh

    mv ${TEMP_DIR}/synfilz.sh ${SCRPT_DIR}
    chmod 777 ${SCRPT_DIR}/synfilz.sh

    mv ${TEMP_DIR}/grabfiles.sh ${SCRPT_DIR}
    chmod 777 ${SCRPT_DIR}/grabfiles.sh

    mv ${TEMP_DIR}/aebl_play.sh ${SCRPT_DIR}
    chmod 777 ${SCRPT_DIR}/aebl_play.sh

    mv ${TEMP_DIR}/mkplay.sh ${SCRPT_DIR}
    chmod 777 ${SCRPT_DIR}/mkplay.sh

    mv ${TEMP_DIR}/playlist.sh ${SCRPT_DIR}
    chmod 777 ${SCRPT_DIR}/playlist.sh

    mv ${TEMP_DIR}/process_playlist.sh ${SCRPT_DIR}
    chmod 777 ${SCRPT_DIR}/process_playlist.sh

    mv ${TEMP_DIR}/dropbox_uploader.sh ${SCRPT_DIR}
    chmod 777 ${SCRPT_DIR}/dropbox_uploader.sh

    mv ${TEMP_DIR}/dropbox_uploader.conf $HOME/.dropbox_uploader

    mv ${TEMP_DIR}/patch.sh ${SCRPT_DIR}
    chmod 777 ${SCRPT_DIR}/patch.sh

    mv ${TEMP_DIR}/upgrade.sh ${SCRPT_DIR}
    chmod 777 ${SCRPT_DIR}/upgrade.sh

    mv ${TEMP_DIR}/grbchan.sh ${SCRPT_DIR}
    chmod 777 ${SCRPT_DIR}/grbchan.sh

    # archive files
    mkdir ${BKUP_DIR}
    cp $HOME/version ${BKUP_DIR}
    mkdir ${BKUP_DIR}/scripts
    cp ${SCRPT_DIR}/*.sh ${BKUP_DIR}/scripts
    mkdir ${BKUP_DIR}/bin
    cp ${BIN_DIR}/* ${BKUP_DIR}/bin
    mkdir ${BKUP_DIR}/pl
    cp $HOME/pl/* ${BKUP_DIR}/pl
    mkdir ${BKUP_DIR}/ctrl
    cp $HOME/ctrl/* ${BKUP_DIR}/ctrl

    # set bootup last in case of fail during install
    sudo rm /etc/init.d/bootup.sh
    sudo mv ${TEMP_DIR}/bootup.sh /etc/init.d
    sudo chmod 755 /etc/init.d/bootup.sh
    sudo update-rc.d bootup.sh defaults

    cp -p ${SCRPT_DIR}/* /run/shm/scripts

if [ -f "$HOME/aeblvm" ]; then
    $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic @kratt, #AEBL_VM ${MACe0} registered." &
else
    $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic @kratt, #AEBLpi ${MACe0} registered." &
fi
    # sleep 5 seconds to ensure system ready for reboot
    echo "Processing files.  Please wait."
    sleep 15

    rm ${TEMP_DIR}/*

    rmdir ${TEMP_DIR}

fi

rm /home/pi/.scripts/asys0092.sh

sudo reboot

exit

#!/bin/sh
#
# Copyright (C) 2016 Uvea I. S., Kevin Rattai
#
# test opennic dns
# hosts can be found at:
# https://www.opennicproject.org/
#
# DNS should be set in: /etc/resolv.conf
# current available:
# 107.170.95.180 (ns6.ny.us) -- 99.86% uptime
# 50.116.40.226 (ns8.ga.us) -- 99.81% uptime
# 104.238.153.178 (ns3.wa.us) -- 99.95% uptime
# 50.116.23.211 (ns19.tx.us) -- 99.87% uptime
#
# The rest of this doc is currently (160420) a reference script
# Will use this script as supplement to manage hosts on opennic

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

FIRST_RUN_DONE="/home/pi/.firstrundone"

TYPE_SYS="unknown"

ID_FILE="${HOME}/.id"
IPw0=$(ip addr show wlan0 | awk '/inet / {print $2}' | cut -d/ -f 1)
IPe0=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f 1)


MACe0=$(ip link show eth0 | awk '/ether/ {print $2}')

if [ -f "${AEBL_TEST}" ]; then
    TYPE_SYS="AEBLtest"
fi
 
if [ -f "${AEBL_SYS}" ]; then
    TYPE_SYS="AEBLsystem"
fi
 
if [ -f "${IHDN_TEST}" ]; then
    TYPE_SYS="IHDN/AEBLtest"
fi
 
if [ -f "${IHDN_SYS}" ]; then
    TYPE_SYS="IHDNpi"
fi


echo "MAC Address: $MACe0"

echo $(date +"%y-%m-%d")
echo $(date +"%T")

# check file doesn't exist
if [ ! -f "${ID_FILE}" ]; then

    # create uid
    U_ID="$(date +"%y-%m-%d")$(date +"%T")$MACe0$IPw0"

    # create file
    echo ${U_ID} > ${ID_FILE}

    $T_SCR/./macip.sh >> ${ID_FILE}

    # create local store id file

    # put to dropbox
    $T_SCR/./dropbox_uploader.sh upload ${ID_FILE} /${U_ID}

    # Tweet -> SMS announce
#     $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic To @kratt, #${TYPE_SYS} registered ${U_ID} ${IPw0} ${IPe0} by ifTTT Tweet -> SMS."

else

    echo "File exists."

fi

exit

#!/bin/sh
#
# Copyright (C) 2014 Uvea I. S., Kevin Rattai
#
# make unique channel

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
# IPw0=$(ip addr show wlan0 | awk '/inet / {print $2}' | cut -d/ -f 1)
IPe0=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f 1)

# MACe0=$(ip link show eth0 | awk '/ether/ {print $2}')

# echo var from position for length
# var="Welcome to the AEBLstuff"

# echo ${var:15}
# echo ${var:15:4}

# with the above, could potentially use to get and strip from var
# when used with a "find" like operation 

# $ ./substr.sh
# AEBLstuff
# AEBL

# replace pattern with value
# echo "After Replacement:" ${filename/str*./operations.}

# replace all pattern with value
# echo "After Replacement:" ${filename//bash/sh}

# fe80::ba27:ebff:fee3:df8
# expands to
# fe80:0000:0000:0000:ba27:ebff:fee3:0df8

# This doesn't work if there is a network assigned or public IPv6 as well
#  add leading 0s between : and take second IPv6 as channel
IP6e0=$(ip addr show eth0 | sed 's/://g' | sed 's/\/64//' | awk '/inet6 / {print $2}')

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
    $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic To @kratt, #${TYPE_SYS} channel registered ${U_ID} ${IPw0} ${IPe0} by ifTTT Tweet -> SMS."

else

    echo "File exists."

fi

exit

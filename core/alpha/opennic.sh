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
#
# Will likely, eventually want to set resov.conf on boot, after DHCP obtained
#   Otherwise, bootup may clobber resolv.conf
#
# Further reference info at:
#   http://superuser.com/questions/617796/how-do-i-set-dns-servers-on-raspberry-pi

# There are many opinions on how to set DNS, although in many cases,
#   resolv.conf ends up with DHCP provided DNS as primaries.  The
#   only instance where solution worked, was set in interfaces, as
#   static config.

# What does work is, overwrite resov.conf once system booted.  Will
#   do that until more elegant solution found.

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

    # create local store id file

    # put to dropbox
#     $T_SCR/./dropbox_uploader.sh upload ${ID_FILE} /${U_ID}

    # Tweet -> SMS announce
#     $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic To @kratt, #${TYPE_SYS} registered ${U_ID} ${IPw0} ${IPe0} by ifTTT Tweet -> SMS."

cp -p $T_SCR/./resolv.conf /etc/resolv.conf

exit

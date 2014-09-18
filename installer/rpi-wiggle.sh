#!/bin/bash
###################################################################
# A Project of TNET Services, Inc
#
# Title: rpi-wiggle
# Author: Kevin Reed (Dweeber)
# dweeber.dweebs@gmail.com
# Project: Raspberry Pi Stuff
#
# Credits: jojopi on Raspberry Pi Forum who provided sample code
# MrEngman on Raspberry Pi Forum for testing
# Examples from http://github.com/asb/raspi-config
#
# Copyright: Copyright (c) 2012 Kevin Reed <kreed@tnet.com>
# https://github.com/dweeber/rpiwiggle
#
# Purpose:
# This is a simple script which looks at the current disk that is
# being used and expands the filesystem to almost the max
# minus 3 512 blocks. This is the ensure that the image is
# smaller than most SDcards of that size
#
# Instructions:
# Script needs to be run as root. It is pretty much automatic...
# it performs a resize command and setups a script which will
# run after a reboot and then ask you to press enter to reboot.
#
# The script WILL REBOOT YOUR SYSTEM
#
# When the system is coming back up, the next command will run
# automatically, and the one time script will be removed and
# when you see the login prompt again, it will be complete
#
###################################################################
# START OF SCRIPT
###################################################################
PROGRAM="rpi-wiggle"
VERSION="v1.1 2012-09-24"
###################################################################
if [ $(id -u) -ne 0 ]; then
  printf "Script must be run as root. Try 'sudo ./rpi-wiggle'\n"
  exit 1
fi
###################################################################
DISK_SIZE="$(($(sudo blockdev --getsz /dev/mmcblk0)/2048/925))"
PART_START="$(sudo parted /dev/mmcblk0 -ms unit s p |grep "^2" |cut -f2 -d:)"
[ "$PART_START" ] || exit 1
PART_END="$(((DISK_SIZE*925*2048-1)-1536))"
###################################################################
# Display some Stuff...
###################################################################
echo $PROGRAM - $VERSION
echo ======================================================
echo Current Disk Info
fdisk -l /dev/mmcblk0
echo
echo ======================================================
echo
echo Calculated Info:
echo " Disk Size = $DISK_SIZE gb"
echo " Part Start = $PART_START"
echo " Part End = $PART_END"
echo
echo "Making changes using fdisk..."
printf "d\n2\nn\np\n2\n$PART_START\n$PART_END\np\nw\n" | fdisk /dev/mmcblk0
echo
echo Setting up init.d resize2fs_once script

cat <<\EOF > /etc/init.d/resize2fs_once &&
#!/bin/sh
### BEGIN INIT INFO
# Provides: resize2fs_once
# Required-Start:
# Required-Stop:
# Default-Start: 2 3 4 5
# Default-Stop: 0 1 6
# Short-Description: Run resize2fs_once on boot
# Description:
### END INIT INFO

. /lib/lsb/init-functions

case "$1" in
  start)
    log_daemon_msg "Starting resize2fs_once, THIS WILL TAKE A FEW MINUTES " &&
    
    # Do our stuff....
    resize2fs /dev/mmcblk0p2 &&
    
    # Okay, not lets remove this script
    rm /etc/init.d/resize2fs_once &&
    update-rc.d resize2fs_once remove &&
    log_end_msg $?
    ;;
  *)
    echo "Usage: $0 start" >&2
    exit 3
    ;;
esac
EOF
  chmod +x /etc/init.d/resize2fs_once &&
  update-rc.d resize2fs_once defaults &&

echo
echo

# Copyright (C) 2014 Uvea I. S., Kevin Rattai
# Change 2014-06-14
# Remarking out read aok as this should not be an interactive
# script, rather an automagic script on first AEBL run to ensure
# part size is appropriate for card
# Change 2014-08-19
# Changed to call shutdown after 1 minute
#####################################################################
echo System is now ready to resize your system. A REBOOT IS REQUIRED NOW!
# echo "Press ENTER to reboot : \c"
# read aok
# sleep 15
# echo REBOOTING....
# /bin/sync
# /sbin/reboot
# echo
# echo Script Complete...

sudo shutdown -r +1 &

###################################################################
# END OF SCRIPT
###################################################################

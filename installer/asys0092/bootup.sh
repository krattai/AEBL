#!/bin/bash
# runs on boot
#
# Copyright (C) 2014 Uvea I. S., Kevin Rattai
#
# Boot up also included the following changes from:
# http://blog.sheasilverman.com/2013/09/adding-a-startup-movie-to-your-raspberry-pi/
#
# You will need to edit your /boot/cmdline.txt file:
#
#    sudo nano /boot/cmdline.txt
#
# Add quiet to the end of the line. It will look something like this:
#
#    dwc_otg.lpm_enable=0 console=ttyAMA0,115200 kgdboc=ttyAMA0,115200 console=tty1 root=/dev/mmcblk0p2 rootfstype=ext4 elevator=deadline rootwait quiet
#
# May wish to continue with the above and make a video splash, but
# in the event a static image is prefered, have currently gone with:
# http://www.edv-huber.com/index.php/problemloesungen/15-custom-splash-screen-for-raspberry-pi-raspbian
#
#
#
#! /bin/sh
# /etc/init.d/blah
#

# Some things that run always
# touch /var/lock/blah

# Carry out specific functions when asked to by the system
case "$1" in
  start)
    AUTOOFF_CHECK_FILE="/home/pi/.noauto"

    sudo -u pi rm /home/pi/.playlist
    sudo -u pi rm /home/pi/.local
    sudo -u pi rm /home/pi/.network
    sudo -u pi rm /home/pi/.offline
    sudo -u pi rm /home/pi/.newpl
    sudo -u pi rm /home/pi/.nonew
#    sudo -u pi touch /home/pi/.playlist
    sudo -u pi rm /home/pi/syncing
    sudo -u pi rm /home/pi/.omx_playing
    sudo -u pi rm /home/pi/.mkplayrun
    sudo -u pi rm /home/pi/.optimized
    sudo -u pi rm /home/pi/.getchan
    sudo -u pi rm /home/pi/.sysrunning
    mount -o exec,remount /run/shm
    sudo -u pi mkdir /run/shm/scripts
    sudo -u pi cp -p /home/pi/.scripts/* /run/shm/scripts
    sudo -u pi /run/shm/scripts/./ctrlwtch.sh &

    if [ ! -f "${AUTOOFF_CHECK_FILE}" ]; then
        echo "${AUTOOFF_CHECK_FILE} not found, in auto mode."
        setterm -blank 1
        sudo -u pi /run/shm/scripts/./startup.sh &
    fi
    echo "Could do more here"
    ;;
  stop)
    echo "Stopping script bootup.sh"
    echo "Could do more here"
    ;;
  *)
    echo "Usage: /etc/init.d/bootup.sh {start|stop}"
    exit 1
    ;;
esac

exit 0

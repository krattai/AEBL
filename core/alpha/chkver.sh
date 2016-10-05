#!/bin/sh
# This script checks version for Pi version
# Copyright (C) 2016 Uvea I. S., Kevin Rattai
#
# Useage:
# There is no useage, this is a standalone script
#
# Models as indicated here:
# http://www.raspberrypi-spy.co.uk/2012/09/checking-your-raspberry-pi-board-version/
#
# or more:
# http://elinux.org/RPi_HardwareHistory#Board_Revision_History
#
# Command to pull rev info, per elinux:
# + cat /proc/cpuinfo | grep 'Revision' | awk '{print $3}' | sed 's/^1000//'

# Try this:
# cat /proc/cpuinfo | grep a01041
# 
# if [ $? -eq 0 ]; then
#     touch .p2
#     echo "Sony Pi 2 B."
# fi

# cat /proc/cpuinfo | grep a21041
# 
# if [ $? -eq 0 ]; then
#     touch .p2
#     echo "Embest Pi 2 B."
# fi

# cat /proc/cpuinfo | grep 900092

# if [ $? -eq 0 ]; then
#     touch .p2
#     echo "Pi Zero."
# fi

# cat /proc/cpuinfo | grep a02082

# if [ $? -eq 0 ]; then
#     touch .p2
#     echo "Sony Pi 3 B."
# fi

# cat /proc/cpuinfo | grep a22082

# if [ $? -eq 0 ]; then
#     touch .p2
#     echo "Embest Pi 3 B."
# fi

ver=$(cat /proc/cpuinfo | grep 'Revision' | awk '{print $3}' | sed 's/^1000//')

if [ $ver = "a01040" ]; then
    touch .p2
    echo "Unknown Pi 2 B."
fi

if [ $ver = "a01041" ]; then
    touch .p2
    echo "Sony Pi 2 B."
fi

if [ $ver = "a21041" ]; then
    touch .p2
    echo "Embest Pi 2 B."
fi

if [ $ver = "a22042" ]; then
    touch .p2
    echo "Embest Pi 2 B with BCM2837."
fi

if [ $ver = "a02082" ]; then
    touch .p3
    echo "Sony Pi 3 B."
fi

if [ $ver = "a22082" ]; then
    touch .p3
    echo "Embest Pi 3 B."
fi

if [ $ver = "000e" ]; then
    touch .p1
    echo "Sony Pi 1 B Q4 2012."
fi

exit


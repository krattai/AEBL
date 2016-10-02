#!/bin/sh
# This script checks version for Pi 2
# Copyright (C) 2016 Uvea I. S., Kevin Rattai
#
# Useage:
# There is no useage, this is a standalone script
#
# Models as indicated here:
# http://www.raspberrypi-spy.co.uk/2012/09/checking-your-raspberry-pi-board-version/

cat /proc/cpuinfo | grep a01041

if [ $? -eq 0 ]; then
    touch .p2
    echo "Sony Pi 2 B."
fi

cat /proc/cpuinfo | grep a21041

if [ $? -eq 0 ]; then
    touch .p2
    echo "Embest Pi 2 B."
fi

cat /proc/cpuinfo | grep 900092

if [ $? -eq 0 ]; then
    touch .p2
    echo "Pi Zero."
fi

cat /proc/cpuinfo | grep a02082

if [ $? -eq 0 ]; then
    touch .p2
    echo "Sony Pi 3 B."
fi

cat /proc/cpuinfo | grep a22082

if [ $? -eq 0 ]; then
    touch .p2
    echo "Embest Pi 3 B."
fi

exit


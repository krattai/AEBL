#!/bin/sh
# This script checks version for Pi 2
# Copyright (C) 2016 Uvea I. S., Kevin Rattai
#
# Useage:
# There is no useage, this is a standalone script

cat /proc/cpuinfo | grep a01041

if [ $? -eq 0 ]; then
    touch .p2
    echo "Sony Pi 2."
fi

cat /proc/cpuinfo | grep a21041

if [ $? -eq 0 ]; then
    touch .p2
    echo "Embest Pi 2."
fi

exit


#!/bin/sh
# This script checks version for Pi version
# Copyright (C) 2016 - 2017 Uvea I. S., Kevin Rattai
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

# leaving this as a reference:
# cat /proc/cpuinfo | grep a01041
# 
# if [ $? -eq 0 ]; then
#     touch .p2
#     echo "Sony Pi 2 B."
# fi

ver=$(cat /proc/cpuinfo | grep 'Revision' | awk '{print $3}' | sed 's/^1000//')

if [ $ver = "Beta" ]; then
#     touch .p1
    echo "Beta Pi 1 B Q1 2012 256MB" > .p1
fi

if [ $ver = "0002" ]; then
#     touch .p1
    echo "Pi 1 B Q1 2012 256MB" > .p1
fi

if [ $ver = "0003" ]; then
#     touch .p1
    echo "Pi 1 B Q3 2012 256MB" > .p1
fi

if [ $ver = "0004" ]; then
#     touch .p1
    echo "Sony Pi 1 B Q3 2012 256MB" > .p1
fi

if [ $ver = "0005" ]; then
#     touch .p1
    echo "Qisda Pi 1 B Q4 2012 256MB" > .p1
fi

if [ $ver = "0006" ]; then
#     touch .p1
    echo "Egoman Pi 1 B Q4 2012 256MB" > .p1
fi

if [ $ver = "0007" ]; then
#     touch .p1
    echo "Egoman Pi 1 A Q1 2013 256MB" > .p1
fi

if [ $ver = "0008" ]; then
#     touch .p1
    echo "Sony Pi 1 A Q1 2013 256MB" > .p1
fi

if [ $ver = "0009" ]; then
#     touch .p1
    echo "Qisda Pi 1 A Q1 2013 256MB" > .p1
fi

if [ $ver = "000d" ]; then
#     touch .p1
    echo "Egoman Pi 1 B Q4 2012 512MB" > .p1
fi

if [ $ver = "000e" ]; then
#     touch .p1
    echo "Sony Pi 1 B Q4 2012 512MB" > .p1
fi

if [ $ver = "000f" ]; then
#     touch .p1
    echo "Qisda Pi 1 B Q4 2012 512MB" > .p1
fi

if [ $ver = "0010" ]; then
#     touch .p1
    echo "Sony Pi 1 B+ Q3 2014 512MB" > .p1
fi

if [ $ver = "0011" ]; then
#     touch .p1
    echo "Sony Pi 1 Computer Module Q2 2014 512MB" > .p1
fi

if [ $ver = "0012" ]; then
#     touch .p1
    echo "Sony Pi 1 A+ Q4 2014 256MB" > .p1
fi

if [ $ver = "0013" ]; then
#     touch .p1
    echo "? Pi 1 B+ Q1 2015 512MB" > .p1
fi

if [ $ver = "0014" ]; then
#     touch .p1
    echo "Embest Pi 1 Compute Module Q2 2014 512MB" > .p1
fi

if [ $ver = "0015" ]; then
#     touch .p1
    echo "Embest Pi 1 A+ ? 256/512MB" > .p1
fi

if [ $ver = "a01040" ]; then
#     touch .p2
    echo "Unknown Pi 2 B unknown 1GB" > .p2
fi

if [ $ver = "a01041" ]; then
#     touch .p2
    echo "Sony Pi 2 B Q1 2015 1GB" > .p2
fi

if [ $ver = "a21041" ]; then
#     touch .p2
    echo "Embest Pi 2 B Q1 2015 1GB" > .p2
fi

if [ $ver = "a22042" ]; then
#     touch .p2
    echo "Embest Pi 2 B with BCM2837 Q3 2016 1GB" > .p2
fi

if [ $ver = "900092" ]; then
#     touch .p0
    echo "Sony Pi 0 Q4 2015 512MB" > .p0
fi

if [ $ver = "900093" ]; then
#     touch .p0
    echo "Sony Pi 0 Q2 2016 512MB" > .p0
fi

if [ $ver = "a02082" ]; then
#     touch .p3
    echo "Sony Pi 3 B Q1 2016 1GB" > .p3
fi

if [ $ver = "a22082" ]; then
#     touch .p3
    echo "Embest Pi 3 B Q1 2016 1GB" > .p3
fi

exit


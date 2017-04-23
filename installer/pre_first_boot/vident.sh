#!/bin/bash
#
# This script runs during a fresh AEBL device
# It is for entertainment while installation is taking place
#
# Copyright (C) 2017 Uvea I. S., Kevin Rattai
#
# Useage:
# There is no useage, this is a standalone script

LOCAL_SYS="/home/pi/.local"
NETWORK_SYS="/home/pi/.network"
OFFLINE_SYS="/home/pi/.offline"
AEBL_SYS="/home/pi/.aeblsys"

TEMP_DIR="/home/pi/tempdir"
MP3_DIR="/home/pi/mp3"
MP4_DIR="/home/pi/mp4"
PL_DIR="/home/pi/pl"
CTRL_DIR="/home/pi/ctrl"
BIN_DIR="/home/pi/bin"

USER=`whoami`
IPe0=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f 1)
MACe0=$(ip link show eth0 | awk '/ether/ {print $2}')

PLAYER_OPTIONS="-o both --vol -2500 -r"

cd $HOME

wait=0

# Repeat during installation
while [ $wait -lt 1 ]; do

    omxplayer -o both --vol -1000 -r http://ihdn.ca/ads/installvid/aeblinstall.mp4

    omxplayer ${PLAYER_OPTIONS} http://ihdn.ca/ads/installvid/The%20Maker.mp4

    omxplayer ${PLAYER_OPTIONS} http://ihdn.ca/ads/installvid/AEBL_slideshow.mp4

    omxplayer -o both --vol -1000 http://ihdn.ca/ads/installvid/Zero.mp4

    omxplayer ${PLAYER_OPTIONS} http://ihdn.ca/ads/IHDNcallToAdvertise.mp4

    omxplayer ${PLAYER_OPTIONS} http://ihdn.ca/ads/installvid/Tears%20of%20Steel.mp4

    omxplayer ${PLAYER_OPTIONS} http://ihdn.ca/ads/ihdn%20mrkt%2014051500.mp4

done

exit

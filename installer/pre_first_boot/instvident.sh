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

PLAYER_OPTIONS="-o both --vol -1500"

cd $HOME

wait=0

# Repeat during installation
while [ $wait -lt 1 ]; do

    omxplayer ${PLAYER_OPTIONS} http://ihdn.ca/ads/installvid/Caminandes%201%20Llama%20Drama.mp4

    omxplayer ${PLAYER_OPTIONS} http://ihdn.ca/ads/installvid/Caminandes%202%20Gran%20Dillama.mp4

    omxplayer ${PLAYER_OPTIONS} http://ihdn.ca/ads/installvid/Caminandes%203%20Llamigos.mp4

    omxplayer ${PLAYER_OPTIONS} http://ihdn.ca/ads/ihdn%20mrkt%2014051500.mp4

    omxplayer ${PLAYER_OPTIONS} http://ihdn.ca/ads/installvid/Big%20Buck%20Bunny.mp4

    omxplayer ${PLAYER_OPTIONS} http://ihdn.ca/ads/Specialty%20Shots%20Video%20Promotions%20Inc%20_%20In-House%20Digital%20Network%20Inc.mp4

    omxplayer ${PLAYER_OPTIONS} "http://ihdn.ca/ads/In-House%20Digital%20Network%20Inc%20Restaurant%20Promotions%20Steve's%20Bistro.mp4"

    omxplayer ${PLAYER_OPTIONS} http://ihdn.ca/ads/installvid/Sintel%20Open%20Source%20Film.mp4

    omxplayer ${PLAYER_OPTIONS} http://ihdn.ca/ads/installvid/Cosmos%20Laundromat.mp4

    omxplayer ${PLAYER_OPTIONS} http://ihdn.ca/ads/installvid/The%20Maker.mp4

    omxplayer ${PLAYER_OPTIONS} http://ihdn.ca/ads/installvid/Zero.mp4

done

exit

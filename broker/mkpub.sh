#!/bin/bash
#
# makes social media content playlist
#
# Copyright (C) 2016 Uvea I. S., Kevin Rattai
#

# TEMP_DIR="/home/user/tmp"
CONT_DIR="/home/ihdn/content"

# T_STO="/run/shm"
# T_SCR="/run/shm/scripts"

# PLAYLIST="${T_STO}/.playlist"
CONTENT="${CONT_DIR}/.soc_content"

# MACe0=$(ip link show eth0 | awk '/ether/ {print $2}')

cd $HOME

touch .mkcontent

while [ -f ".mkcontent" ]; do

    mosquitto_sub -h uveais.ca -t "aebl/add/content" |
    while IFS= read -r line
        do
#           if [[ $line = "sixxs alive" ]]; then
#               echo "$(date +"%T") - sixxs ACK"
#               echo " "
#           fi
#           if [[ $line == *"ihdnsrvr IPv6"* ]]; then
#               echo "$(date +"%T") - ihdnsrvr ACK"
#               echo "$line"
#               echo " "
#           fi
#           if [[ $line == *"played"* ]]; then
#               echo "$(date +"%T") - play log"
#               echo "$line"
#               echo " "
#           fi
#

            # Append file to playlist
            echo "$line #am2p" >> "${CONTENT}"

        done


done

# tput clear
exit 0

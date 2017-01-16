#!/bin/bash
#
# makes social media content playlist for aebl subscribers
#
# Copyright (C) 2017 Uvea I. S., Kevin Rattai
#

# to make short URL using tinyurl:
# wget http://tinyurl.com/api-create.php?url=http://ihdn.ca/


# TEMP_DIR="/home/user/tmp"
CONT_DIR="/home/kevin/content"

# T_STO="/run/shm"
# T_SCR="/run/shm/scripts"

# PLAYLIST="${T_STO}/.playlist"
CONTENT="${CONT_DIR}/.psa_content"

# MACe0=$(ip link show eth0 | awk '/ether/ {print $2}')

cd $HOME

touch .psacontent

while [ -f ".psacontent" ]; do

    mosquitto_sub -h ihdn.ca -t "aebl/add/psa" |
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
#

            # Append file to playlist
            echo "$line #am2p" >> "${CONTENT}"

        done


done

# tput clear
exit 0

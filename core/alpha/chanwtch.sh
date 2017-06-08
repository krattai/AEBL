#!/bin/bash
#
# Need to specific /bin/bash because /bin/sh (=dash) doesn't like redirect

# Copyright (C) 2015 - 2017 Uvea I. S., Kevin Rattai

#
# Element14 - SuddenImpact design challenge
# http://www.element14.com/community/community/design-challenges/sudden-impact
#
# This file is part of submission made for Modular&EasyConfigure project (tomaj$
#
# v010 - January 11th 2015.
#      Initial version. Subscribe to MQTT broker and act upon messages received.
#

# Expect this script to watch channels by name, number, or hostname

#     mosquitto_sub -h uveais.ca -t "aebl/add/content" |
#     while IFS= read -r line

# use hostname to determine channel to watch as initial version
hostn=$(cat /etc/hostname)

# mosquitto_pub -d -t ihdn/alive -m "$(date) : $hostn IPv6 $ext_ip6 is online." -h "ihdn.ca"

# need to check if should be watching ALL or just certain:
#  + all by aebl/$hostn/#
#  + certain as topics by name 

mosquitto_sub -h "ihdn.ca" -t "aebl/$hostn/#" |
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
#             echo "$line #am2p" >> "${CONTENT}"

#           if [[ $line = "sixxs alive" ]]; then
#               echo "$(date +"%T") - sixxs ACK"
#               echo " "
#           fi

# Additional functions which might be desirable:
#     + revpn
#     + out
#     + nout
#     + patch
#     + upgrade
#     + skip/next
#     + change channel

          if [[ $line = "hello?" ]]; then
              IPt44=$(ip addr show tun44 | awk '/inet / {print $2}' | cut -d/ -f 1)
              mosquitto_pub -d -t aebl/alive -m "$(date) : hello! $hostn tun44 $IPt44 is online." -h "ihdn.ca"
              echo "$(date +"%T") - hello request received"
              echo " "
          fi

          if [[ $line = "halt" ]]; then
              touch "${HOME}/ctrl/halt"
          fi

          if [[ $line = "reboot" ]]; then
              touch "${HOME}/ctrl/reboot"
          fi

          if [[ $line = "speed" ]]; then
              mosquitto_pub -d -t aebl/alive -m "$(date) : $(cat /etc/hostname) checking speed." -h "ihdn.ca"
              touch "${HOME}/ctrl/speed"
          fi

done

exit 0

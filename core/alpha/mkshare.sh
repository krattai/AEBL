#!/bin/bash
# This script can be used to make a network share
#
# Copyright (C) 2017 Uvea I. S., Kevin Rattai
#
# mkdir media
# net usershare add documents /home/pi/media "media" everyone:F guest_ok=y
# chmod 0777 /home/pi/media


# use hostname to determine channel to watch as initial version
hostn=$(cat /etc/hostname)

# mosquitto_pub -d -t ihdn/alive -m "$(date) : $hostn IPv6 $ext_ip6 is online." -h "ihdn.ca"

# need to check if should be watching ALL or just certain:
#  + all by aebl/$hostn/#
#  + certain as topics by name 

# mosquitto_pub -d -t aebl/ctrl/idet009 -m "reboot" -h "ihdn.ca"


mosquitto_sub -h "ihdn.ca" -t "aebl/ctrl/$hostn/#" |
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

          if [[ $line = "reboot" ]]; then
              touch ctrl/reboot
          fi

          if [[ $line = "halt" ]]; then
              touch ctrl/halt
          fi

          if [[ $line = "patch" ]]; then
              touch ctrl/patch
          fi

          if [[ $line = "revpn" ]]; then
              /run/shm/scripts/revpn.sh &
          fi

          if [[ $line = "out" ]]; then
              touch ctrl/out
          fi

done

exit 0

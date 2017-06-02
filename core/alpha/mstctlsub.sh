#!/bin/bash
#
# Need to specific /bin/bash because /bin/sh (=dash) doesn't like redirect

# Copyright (C) 2016 - 2017 Uvea I. S., Kevin Rattai

#
# Element14 - SuddenImpact design challenge
# http://www.element14.com/community/community/design-challenges/sudden-impact
#
# This file is part of submission made for Modular&EasyConfigure project (tomaj$
#

# This script watches host channel for control commands
#
# Should be able to hook to device and channel with reduced management set, authorized by m/c

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

          if [[ $line = "sixxs alive" ]]; then
              echo "$(date +"%T") - sixxs ACK"
              echo " "
          fi
done

exit 0

#!/bin/bash
#
# Need to specific /bin/bash because /bin/sh (=dash) doesn't like redirect

# Copyright (C) 2015 - 2016 Uvea I. S., Kevin Rattai

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

mosquitto_sub -h 2001:5c0:1100:dd00:240:63ff:fefd:d3f1 -t "hello/+" -t "aebl/+" -t "ihdn/+" -t "uvea/+" |
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

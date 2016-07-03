#!/bin/bash
#
# Copyright (C) 2016 Uvea I. S., Kevin Rattai
# checks for control messages and acts accordingly
#
# This script borrows from:
#
# Element14 - SuddenImpact design challenge
# http://www.element14.com/community/community/design-challenges/sudden-impact
#
# This file is part of submission made for Modular&EasyConfigure project (tomaj$
#
# v010 - January 11th 2015.
#      Initial version. Subscribe to MQTT broker and act upon messages received.
#
#
#

mosquitto_sub -h uveais.ca -t "aebl/sys_m" |
while IFS= read -r line
    do
          if [[ $line = "reboot" ]]; then
              echo "$(date +"%T") - rebooting"
              echo " "
              mosquitto_pub -d -t ihdn/action -m "$(date) : AEBL device from $ext_ip rebooting." -h "uveais.ca"
              touch ~/ctrl/reboot
          fi
done

exit 0

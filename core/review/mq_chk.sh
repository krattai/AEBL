#!/bin/bash
#
# Copyright (C) 2016 Uvea I. S., Kevin Rattai
# checks for control messages and acts accordingly
# Will likely, eventually replace msgrec.sh
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
# ~~~~~~~~~~~~
# run.sh should contain (mq_chk eventually replaced by msgrec.sh):
#   if [ "$(! pgrep mq_chk.sh)" ]; then
#     $T_SCR/./mq_chk.sh &
#   fi
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

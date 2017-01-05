#!/bin/bash
#
# Copyright (C) 2017 Uvea I. S., Kevin Rattai
#
# receives messages in file format, which could be parsed and then executed.
# may want script that watches, sets flag for system, and files that come in
#
# files pushed by way of command such as:
# mosquitto_pub -d -t aebl/test -f xchng.sh -h "ihdn.ca"
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

mosquitto_sub -h ihdn.ca -t "aebl/test" |
while IFS= read -r line
    do
          echo $line >> log
#           if [[ $line = "reboot" ]]; then
#               echo "$(date +"%T") - rebooting"
#               echo " "
#               mosquitto_pub -d -t ihdn/action -m "$(date) : AEBL device from $ext_ip rebooting." -h "uveais.ca"
#               touch ~/ctrl/reboot
#           fi
done

exit 0

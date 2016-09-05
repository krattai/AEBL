#!/bin/sh
# This script adds content for AEBL social publishing
# 
# Copyright (C) 2016 Uvea I. S., Kevin Rattai
#
# Useage:
# There is no useage, this is a standalone script
#
# For certain functions, use case:
#
#
# mosquitto_sub -h 2001:5c0:1100:dd00:240:63ff:fefd:d3f1 -t "hello/+" -t "aebl/+" -t "ihdn/+" -t "uvea/+" |
# while IFS= read -r line
#     do
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
# done
#
# And use AEBL playlist.sh and process_playlist.sh for example code
#  to process files
# For determining what content, should eventually be able to parse
#  a upload directory for playlists as well as files and then move
#  those files to download dir and notify specific client(s) of
#  availability.
# This can also be used in order to send URL for streamed content

i="0"

while [ $i -lt 1 ]
do
    mosquitto_sub -h uveais.ca -t -t "aebl/add/content" |
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
        done

done

exit 0

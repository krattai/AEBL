#!/bin/bash
# This script should remove content
# 
# Copyright (C) 2016 - 2017 Uvea I. S., Kevin Rattai
#
# Useage:
# There is no useage, this is a standalone script
# Most likely called from ctrlwtch.sh
# Might want to choose between remove and archive
#
# This code may not actually do much other than mv or rm
# As such, this code could ultimately be part of ctrlwtch.sh
# although with too much going on in that script, which is supposed
# to be realtime, spawning this function would keep ctrlwtch.sh responsive
# to momentary events
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

# This will require that mkchan.sh works

# i="0"

# while [ $i -lt 1 ]
# do
#     mosquitto_sub -h uveais.ca -t -t "aebl/#" -t "uvea/#" |
#     while IFS= read -r line
#         do
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
#         done

# hostn=$(cat /etc/hostname)
# ext_ip4=$(dig +short myip.opendns.com @resolver1.opendns.com)
# ext_ip6=$(curl icanhazip.com)
# mosquitto_pub -d -t hello/world -m "$(date) : irot LdB, online. IP is $ext_ip" -h "uveais.ca"
# mosquitto_pub -d -t uvea/alive -m "$(date) : $hostn server IP $ext_ip is online." -h "2604:8800:100:19a::2"
# mosquitto_pub -d -t uvea/alive -m "$(date) : $hostn IPv4 $ext_ip4 is online." -h "2001:5c0:1100:dd00:240:63ff:fefd:d3f1"
# mosquitto_pub -d -t aebl/alive -m "$(date) : $hostn IPv6 $ext_ip6 is online." -h "2001:5c0:1100:dd00:240:63ff:fefd:d3f1"
# mosquitto_pub -d -t uvea/alive -m "$(date) : $hostn IPv4 $ext_ip4 is online." -h "ihdn.ca"
# mosquitto_pub -d -t aebl/alive -m "$(date) : $hostn IPv6 $ext_ip6 is online." -h "uveais.ca"
# i=$[$i+1]
# sleep 300
# done

hostn=$(cat /etc/hostname)

# Use $hostn to watch for new content
mosquitto_sub -h "ihdn.ca" -t "aebl/$hostn/rem" |
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

            # remove file
#             echo "$line #am2p" >> "${CONTENT}"
#           would like to relegate sub listener to single script
#           and place function into single scripts, such as ctrlwtch.sh
            rm "/home/pi/pl/${line}"

done

exit 0

#!/bin/bash
# This script is for the distribution of AEBL framework channel content
# 
# Copyright (C) 2016 - 2017 Uvea I. S., Kevin Rattai
#
# Useage, from master control:
# mosquitto_pub -d -t aebl/aebltst0/add -m "winnipeg%20food%20video.mp4" -h "ihdn.ca"
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
#
# This could also use the current vpn that exists for the noo-ebs functionality

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
mosquitto_sub -h "ihdn.ca" -t "aebl/$hostn/add" |
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

            # grab file
#             echo "$line #am2p" >> "${CONTENT}"


#           could test by putting content into ctrl directory
#           could also pass/receive full URI rather than just file, specifically for AEBL
#             wget -N -nd -w 3 -P /home/pi/ad --limit-rate=50k "http://ihdn.ca/ads/${line}"
            mosquitto_pub -d -t aebl/$hostn -m "$(date) : $(cat /etc/hostname) getting $line." -h "ihdn.ca" &
            wget -N -nd -w 3 -P /home/pi/ctrl --limit-rate=50k "http://ihdn.ca/ads/${line}"
            mosquitto_pub -d -t aebl/$hostn -m "$(date) : $(cat /etc/hostname) received $line." -h "ihdn.ca" &
#           should also update pl after new file add
#           oh, and should also create script for removing content

done

exit 0

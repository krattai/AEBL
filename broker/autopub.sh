#!/bin/sh
# This script should auto pub content from flat file
# Copyright (C) 2016 Uvea I. S., Kevin Rattai
#
# Basic premise"
# + able to take numberical value, and conversion vector
# + return value in desired currency
# i.e. 5 hrs CDN (5 hours to canadian): return 75
# able to grab current values from yahoo
# assumed that hour equals (arbitrary) wage of $15/hr
#
# $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "Today's bitcoin rate CAD\$517.2529 #PSA #am2p"
#
# or
#
# mosquitto_pub -d -t aebl/social -m "Today's bitcoin rate is CAD\\\$576.5844 and US$ rate is CAD\\\$1.3769 #PSA #am2p" -h "uveais.ca"
#
# wget -O btc.txt "http://finance.yahoo.com/d/quotes.csv?e=.csv&f=sl1d1t1&s=BTCCAD=X"
#
# btc=$(awk -F "\"*,\"*" '{print $2}' btccad.txt)

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

i="0"

while [ $i -lt 1 ]
do
    mosquitto_sub -h uveais.ca -t -t "aebl/#" -t "uvea/#" |
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
done

exit 0

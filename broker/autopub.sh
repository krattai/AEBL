#!/bin/sh
# This script should auto pub content from flat file
# Copyright (C) 2016 Uvea I. S., Kevin Rattai
#
# Useage:
# There is no useage, this is a standalone script
i="0"

while [ $i -lt 1 ]
do
hostn=$(cat /etc/hostname)
ext_ip4=$(dig +short myip.opendns.com @resolver1.opendns.com)
ext_ip6=$(curl icanhazip.com)
# mosquitto_pub -d -t hello/world -m "$(date) : irot LdB, online. IP is $ext_ip" -h "uveais.ca"
# mosquitto_pub -d -t uvea/alive -m "$(date) : $hostn server IP $ext_ip is online." -h "2604:8800:100:19a::2"
# mosquitto_pub -d -t uvea/alive -m "$(date) : $hostn IPv4 $ext_ip4 is online." -h "2001:5c0:1100:dd00:240:63ff:fefd:d3f1"
# mosquitto_pub -d -t aebl/alive -m "$(date) : $hostn IPv6 $ext_ip6 is online." -h "2001:5c0:1100:dd00:240:63ff:fefd:d3f1"
mosquitto_pub -d -t uvea/alive -m "$(date) : $hostn IPv4 $ext_ip4 is online." -h "ihdn.ca"
mosquitto_pub -d -t aebl/alive -m "$(date) : $hostn IPv6 $ext_ip6 is online." -h "uveais.ca"
# i=$[$i+1]
sleep 300
done


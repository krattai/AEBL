#!/bin/bash
# AEBL send message using MQTT
#
# Copyright (C) 2015 Uvea I. S., Kevin Rattai
#

i="0"

# should modify this loop to simply ping persistently
while [ $i -lt 9999 ]
do
ext_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
# mosquitto_pub -d -t hello/world -m "$(date) : irot LdB, online. IP is $ext_ip" -h "uveais.ca"
mosquitto_pub -d -t hello/world -m "$(date) : AEBL device from $ext_ip ping." -h "uveais.ca"
i=$[$i+1]
sleep 300
done

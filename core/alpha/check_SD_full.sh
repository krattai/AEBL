#!/bin/bash
# AEBL send message to MQTT broker on SD card close to full
#
# Copyright (C) 2016 Uvea I. S., Kevin Rattai
#
# This could be integrated with regular checks

i="0"

# This is old code, use inetup.sh script or similar as reference

# Shows column 5 (use$) of all drives
# df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }'

# should modify this loop to simply ping persistently
while [ $i -lt 9999 ]
do
ext_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
# mosquitto_pub -d -t hello/world -m "$(date) : irot LdB, online. IP is $ext_ip" -h "uveais.ca"
mosquitto_pub -d -t hello/world -m "$(date) : AEBL device from $ext_ip ping." -h "uveais.ca"
i=$[$i+1]
sleep 300
done


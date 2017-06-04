#!/bin/bash
# AEBL send message to MQTT broker on $hostn channel
#
# Copyright (C) 2015 - 2017 Uvea I. S., Kevin Rattai
#
# 20170604 - this script may actually be useless except as an example, _if_ useful as a stand alone,
# this script may be used temporarily, to be replaced by compiled C application
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


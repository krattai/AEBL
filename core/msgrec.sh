#!/bin/bash
# AEBL receive message using MQTT
#
# Copyright (C) 2015 Uvea I. S., Kevin Rattai
#

i="0"

# should modify this loop to simply listen persistently
while [ $i -lt 9999 ]
do
ext_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
# mosquitto_pub -d -t hello/world -m "$(date) : irot LdB, online. IP is $ext_ip" -h "uveais.ca"

mosquitto_pub -d -t hello/world -m "$(date) : AEBL device from $ext_ip ping." -h "uveais.ca"

# the following code is example of MQTT subscribe usage
# mosquitto_sub -h uveais.ca -t "hello/+" -t "aebl/+" -t "ihdn/+"

# this routine function should listen on topic and then act on it

i=$[$i+1]
sleep 300
done


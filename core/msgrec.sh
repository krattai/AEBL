#!/bin/bash

i="0"

while [ $i -lt 9999 ]
do
ext_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
# mosquitto_pub -d -t hello/world -m "$(date) : irot LdB, online. IP is $ext_ip" -h "uveais.ca"
mosquitto_pub -d -t hello/world -m "$(date) : device IP $ext_ip is online." -h "uveais.ca"
i=$[$i+1]
sleep 300
done


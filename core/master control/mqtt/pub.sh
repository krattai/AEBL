#!/bin/bash

i="0"

while [ $i -lt 1 ]
do
hostn=$(cat /etc/hostname)
ext_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
# mosquitto_pub -d -t hello/world -m "$(date) : irot LdB, online. IP is $ext_ip" -h "uveais.ca"
# mosquitto_sub -h 2001:5c0:1100:dd00:240:63ff:fefd:d3f1 -t "hello/+" -t "aebl/+" -t "ihdn/+" -t "uvea/+"

mosquitto_pub -d -t aebl/alive -m "$(date) : $hostn device IP $ext_ip is online." -h "2001:5c0:1100:dd00:ba27:ebff:fe2c:41d7"
# i=$[$i+1]
sleep 300
done

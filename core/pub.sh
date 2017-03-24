#!/bin/bash
VPN_SYS="${T_STO}/.vpn_on"

i="0"
hostn=$(cat /etc/hostname)

while [ $i -lt 1 ]
do
ext_ip4=$(dig +short myip.opendns.com @resolver1.opendns.com)
ext_ip6=$(curl icanhazip.com)
# mosquitto_pub -d -t hello/world -m "$(date) : irot LdB, online. IP is $ext_ip" -h "uveais.ca"
# mosquitto_pub -d -t ihdn/alive -m "$(date) : rotator SIXXS device IP $ext_ip4 is online." -h "2604:8800:100:19a::2"
# mosquitto_pub -d -t ihdn/alive -m "$(date) : rotator SIXXS device IP $ext_ip6 is online." -h "2001:5c0:1100:dd00:240:63ff:fefd:d3f1"

mosquitto_pub -d -t ihdn/$hostn -m "$(date) : sixxs $hostn IPv4 $ext_ip4 is online." -h "ihdn.ca"
mosquitto_pub -d -t ihdn/$hostn -m "$(date) : sixxs $hostn IPv6 $ext_ip6 is online." -h "ihdn.ca"

IPt0=$(ip addr show tun0 | awk '/inet / {print $2}' | cut -d/ -f 1)
mosquitto_pub -d -t ihdn/alive -m "$(date) : $hostn tun0 $IPt0 is online." -h "ihdn.ca"

# added this line for better, specific tun0 mmonitoring
mosquitto_pub -d -t uvea/alive -m "$(date) : $hostn tun0 $IPt0 is online." -h "ihdn.ca"

# i=$[$i+1]
sleep 300
done

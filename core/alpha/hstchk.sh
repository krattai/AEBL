#!/bin/bash
# Copyright (C) 2017 Uvea I. S., Kevin Rattai
#
# Lists responding hosts
#

# user@host:~$ nmap -A x.x.x.x/22 | grep "FQDN"
# |   FQDN: quad00
# |   FQDN: onq00
# |   FQDN: idethd14
# |   FQDN: srvr-via00
# |   FQDN: sixxs
# |   FQDN: uvea-nas00
# |   FQDN: xxx-pav-17
# |   FQDN: aebltst1
# |   FQDN: aeblsha0
# |   FQDN: aeblsys
# |   FQDN: aebltst0
# |   FQDN: aeblsrvr0
# |   FQDN: ebox00
# |   FQDN: vicche0
# |   FQDN: irotbsjr

VPN_SYS="${T_STO}/.vpn_on"

i="0"

while [ $i -lt 1 ]
do
hostn=$(cat /etc/hostname)
ext_ip4=$(dig +short myip.opendns.com @resolver1.opendns.com)
if [ $? -eq 0 ]; then
    echo "IPV6 available."
    ext_ip6=$(curl icanhazip.com)
    mosquitto_pub -d -t ihdn/log -m "$(date) : $hostn IPv6 available." -h "ihdn.ca" &
else
    mosquitto_pub -d -t ihdn/log -m "$(date) : $hostn IPV6 NOT available." -h "ihdn.ca" &
fi
IPt0=$(ip addr show tun0 | awk '/inet / {print $2}' | cut -d/ -f 1)
IPt44=$(ip addr show tun44 | awk '/inet / {print $2}' | cut -d/ -f 1)

# mosquitto_pub -d -t hello/world -m "$(date) : irot LdB, online. IP is $ext_ip" -h "uveais.ca"
# mosquitto_pub -d -t ihdn/alive -m "$(date) : rotator SIXXS device IP $ext_ip4 is online." -h "2604:8800:100:19a::2"
# mosquitto_pub -d -t ihdn/alive -m "$(date) : rotator SIXXS device IP $ext_ip6 is online." -h "2001:5c0:1100:dd00:240:63ff:fefd:d3f1"

mosquitto_pub -d -t ihdn/$hostn -m "$(date) : sixxs $hostn IPv4 $ext_ip4 is online." -h "ihdn.ca"
mosquitto_pub -d -t ihdn/$hostn -m "$(date) : sixxs $hostn IPv6 $ext_ip6 is online." -h "ihdn.ca"

mosquitto_pub -d -t ihdn/alive -m "$(date) : $hostn tun0 $IPt0 is online." -h "ihdn.ca"

mosquitto_pub -d -t ihdn/alive -m "$(date) : $hostn tun44 $IPt44 is online." -h "ihdn.ca"

mosquitto_pub -d -t uvea/alive -m "$(date) : $hostn tun0 $IPt0 is online." -h "ihdn.ca"
mosquitto_pub -d -t uvea/alive -m "$(date) : $hostn tun44 $IPt44 is online." -h "ihdn.ca"

# from:
#     space=`df -h | awk '{print $5}' | grep % | grep -v Use | head -1 | cut -d "%" -f1 -`
space=`df -h | awk '{print $5}' | grep % | grep -v Use | head -1`
mosquitto_pub -d -t uvea/alive -m "$(date) : $hostn disk is $space full." -h "ihdn.ca"

# i=$[$i+1]
sleep 300
done




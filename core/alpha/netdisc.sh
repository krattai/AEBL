#!/bin/bash
# Copyright (C) 2017 Uvea I. S., Kevin Rattai
#
# Attempt to auto-discover network
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


# example from:
#    https://superuser.com/questions/261818/how-can-i-list-all-ips-in-the-connected-network-through-terminal-preferably
# 
# for ip in 192.168.0.{1..254}; do
#   ping -c 1 -W 1 $ip | grep "64 bytes" &
# done

# This is interesting:
#   ping 224.0.0.1

# Interested in finding all subnets in private space

# Private networks can use IP addresses anywhere in the following ranges:
#     192.168.0.0 - 192.168.255.255 (65,536 IP addresses)
#     172.16.0.0 - 172.31.255.255 (1,048,576 IP addresses)
#     10.0.0.0 - 10.255.255.255 (16,777,216 IP addresses)

# sudo arp-scan 192.168.0.0/16
# sudo arp-scan 172.16.0.0/12
# sudo arp-scan 10.0.0.0/18

# (http://www.nta-monitor.com/tools/arp-scan/

# gateway:
# https://stackoverflow.com/questions/1204629/how-do-i-get-the-default-gateway-in-linux-given-the-destination
# find gateway from route using default label
# IP=$(/sbin/ip route | awk '/default/ { print $3 }')
# echo $IP
#
# https://serverfault.com/questions/31170/how-to-find-the-gateway-ip-address-in-linux
# ip route show 0.0.0.0/0 dev eth0 | cut -d\  -f3

# https://www.unixmen.com/how-to-find-default-gateway-in-linux/

# http://manpages.ubuntu.com/manpages/zesty/en/man1/arp-scan.1.html

# https://en.wikipedia.org/wiki/Private_network

# additional arp-scan examples
# sudo arp-scan --localnet --numeric --quiet --ignoredups | grep -E '([a-f0-9]{2}:){5}[a-f0-9]{2}' | awk '{print $1}'

# sudo arp-scan --localnet --numeric --quiet --ignoredups

# sudo arp-scan --localnet --quiet --ignoredups | gawk '/([a-f0-9]{2}:){5}[a-f0-9]{2}/ {print $1}'


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




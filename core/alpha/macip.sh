#!/bin/sh
#
# show IP and MAC
#
# Copyright (C) 2015 - 2017 Uvea I. S., Kevin Rattai
#
# another way to get mac address:
# cat /sys/class/net/eth0/address
#
# this apparently works with "all" *nixs
# ifconfig eth0 | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}'
 
IPw0=$(ip addr show wlan0 | awk '/inet / {print $2}' | cut -d/ -f 1)
MACw0=$(ip link show wlan0 | awk '/ether/ {print $2}')
 
echo "IP Address: $IPw0"
echo "MAC Address: $MACw0"
 
IPe0=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f 1)
MACe0=$(ip link show eth0 | awk '/ether/ {print $2}')
 
echo "IP Address: $IPe0"
echo "MAC Address: $MACe0"

echo $(date +"%y-%m-%d")
echo $(date +"%T")

echo $(date +"%y-%m-%d")$(date +"%T")$MACe0$IPw0
 
exit

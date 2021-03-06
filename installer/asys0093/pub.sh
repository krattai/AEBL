#!/bin/bash
# Copyright (C) 2016 - 2017 Uvea I. S., Kevin Rattai
#
# This script publishes device status
#
# eventually, this script will be redundant, as system should publish alives at certain intervals,
#   but otherwise will only publish if queries to it are performed

VPN_SYS="${T_STO}/.vpn_on"

i="0"

while [ $i -lt 1 ]
do
  hostn=$(cat /etc/hostname)
  ext_ip4=$(dig +short myip.opendns.com @resolver1.opendns.com)

  ext_ip6=$(curl icanhazip.com)
  if [ $? -eq 0 ]; then
      echo "IPV6 available."
      mosquitto_pub -d -t ihdn/log -m "$(date) : $hostn IPv6 available." -h "ihdn.ca" &
  else
      mosquitto_pub -d -t ihdn/log -m "$(date) : $hostn IPV6 NOT available." -h "ihdn.ca" &
  fi

  IPt0=$(ip addr show tun0 | awk '/inet / {print $2}' | cut -d/ -f 1)
  IPt44=$(ip addr show tun44 | awk '/inet / {print $2}' | cut -d/ -f 1)
  # added checks for local network; assuming only one of each
  eth0=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f 1)
  wln0=$(ip addr show wlan0 | awk '/inet / {print $2}' | cut -d/ -f 1)
  MACe0=$(ifconfig eth0 | grep -o -E '([[:xdigit:]]{1,2}:){5}[[:xdigit:]]{1,2}')

  # mosquitto_pub -d -t hello/world -m "$(date) : irot LdB, online. IP is $ext_ip" -h "uveais.ca"
  # mosquitto_pub -d -t ihdn/alive -m "$(date) : rotator SIXXS device IP $ext_ip4 is online." -h "2604:8800:100:19a::2"
  # mosquitto_pub -d -t ihdn/alive -m "$(date) : rotator SIXXS device IP $ext_ip6 is online." -h "2001:5c0:1100:dd00:240:63ff:fefd:d3f1"

  mosquitto_pub -d -t uvea/$hostn -m "$(date) : $hostn MAC $MACe0" -h "ihdn.ca"

  mosquitto_pub -d -t ihdn/$hostn -m "$(date) : $hostn IPv4 $ext_ip4 IPv6 $ext_ip6" -h "ihdn.ca"

  mosquitto_pub -d -t ihdn/alive -m "$(date) : $hostn tun0 $IPt0 tun44 $IPt44" -h "ihdn.ca"

  mosquitto_pub -d -t uvea/alive -m "$(date) : $hostn tun0 $IPt0 tun44 $IPt44" -h "ihdn.ca"

  mosquitto_pub -d -t uvea/alive -m "$(date) : $hostn eth0 $eth0 wlan0 $wln0" -h "ihdn.ca"

  # from:
  #     space=`df -h | awk '{print $5}' | grep % | grep -v Use | head -1 | cut -d "%" -f1 -`
  space=`df -h | awk '{print $5}' | grep % | grep -v Use | head -1`
  mosquitto_pub -d -t uvea/alive -m "$(date) : $hostn disk is $space full." -h "ihdn.ca"

  # i=$[$i+1]
  sleep 300
done

exit

# follows is some of the old code
# #!/bin/bash
# VPN_SYS="${T_STO}/.vpn_on"
# 
# i="0"
# hostn=$(cat /etc/hostname)
# 
# while [ $i -lt 1 ]
# do
# ext_ip4=$(dig +short myip.opendns.com @resolver1.opendns.com)
# ext_ip6=$(curl icanhazip.com)
# 
# ping6 -c 1 google.com
# 
# if [ $? -eq 0 ]; then
#     echo "IPV6 available."
#     ext_ip6=$(curl icanhazip.com)
#     hostn=$(cat /etc/hostname)
#     mosquitto_pub -d -t ihdn/log -m "$(date) : $hostn IPv6 available." -h "ihdn.ca" &
# else
#     rm $VPN_SYS
#     hostn=$(cat /etc/hostname)
#     mosquitto_pub -d -t ihdn/log -m "$(date) : $hostn IPV6 NOT available." -h "ihdn.ca" &
#     sudo service openvpn restart
# fi
# 
# IPt0=$(ip addr show tun0 | awk '/inet / {print $2}' | cut -d/ -f 1)
# IPt44=$(ip addr show tun44 | awk '/inet / {print $2}' | cut -d/ -f 1)
# 
# mosquitto_pub -d -t hello/world -m "$(date) : irot LdB, online. IP is $ext_ip" -h "uveais.ca"
# mosquitto_pub -d -t ihdn/alive -m "$(date) : rotator SIXXS device IP $ext_ip4 is online." -h "2604:8800:100:19a::2"
# mosquitto_pub -d -t ihdn/alive -m "$(date) : rotator SIXXS device IP $ext_ip6 is online." -h "2001:5c0:1100:dd00:240:63ff:fefd:d3f1"
# 
# mosquitto_pub -d -t ihdn/$hostn -m "$(date) : sixxs $hostn IPv4 $ext_ip4 is online." -h "ihdn.ca"
# mosquitto_pub -d -t ihdn/$hostn -m "$(date) : sixxs $hostn IPv6 $ext_ip6 is online." -h "ihdn.ca"
# 
# mosquitto_pub -d -t ihdn/alive -m "$(date) : $hostn tun0 $IPt0 is online." -h "ihdn.ca"
# 
# mosquitto_pub -d -t ihdn/alive -m "$(date) : $hostn tun44 $IPt44 is online." -h "ihdn.ca"
# 
# mosquitto_pub -d -t uvea/alive -m "$(date) : $hostn tun0 $IPt0 is online." -h "ihdn.ca"
# mosquitto_pub -d -t uvea/alive -m "$(date) : $hostn tun44 $IPt44 is online." -h "ihdn.ca"
# 
# from:
#     space=`df -h | awk '{print $5}' | grep % | grep -v Use | head -1 | cut -d "%" -f1 -`
# space=`df -h | awk '{print $5}' | grep % | grep -v Use | head -1`
# mosquitto_pub -d -t uvea/alive -m "$(date) : $hostn disk is $space full." -h "ihdn.ca"
# 
# i=$[$i+1]
# sleep 300
# done



#!/bin/bash
# AEBL send message to MQTT broker on SD card close to full
#
# Copyright (C) 2016 - 2017 Uvea I. S., Kevin Rattai
#
# This could be integrated with regular checks
#
# Example script from: https://www.cyberciti.biz/tips/shell-script-to-watch-the-disk-space.html
#

i="0"

# This is old code, use inetup.sh script or similar as reference
# check script like mkchan.sh for reference

# Shows column 5 (use$) of all drives
# df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }'

# This will replace most of below, except instead of mailing, should report by MQTT
#df -H | grep -vE '^Filesystem|tmpfs|cdrom' | awk '{ print $5 " " $1 }' | while read output;
# do
#   echo $output
#   usep=$(echo $output | awk '{ print $1}' | cut -d'%' -f1  )
#   partition=$(echo $output | awk '{ print $2 }' )
#   if [ $usep -ge 90 ]; then
#     echo "Running out of space \"$partition ($usep%)\" on $(hostname) as on $(date)" |
#      mail -s "Alert: Almost out of disk space $usep%" you@somewhere.com
#   fi
# done

# from: http://tldp.org/LDP/Bash-Beginners-Guide/html/sect_07_02.html
# This shoud work for Pi
# space=`df -h | awk '{print $5}' | grep % | grep -v Use | head -1 | cut -d "%" -f1 -`
# alertvalue="80"

# if [ "$space" -ge "$alertvalue" ]; then
#   echo "At least one of my disks is nearly full!" | mail -s "daily diskcheck" root
# else
#   echo "Disk space normal" | mail -s "daily diskcheck" root
# fi

hostn=$(cat /etc/hostname)

# should modify this loop to simply ping persistently
while [ $i -lt 9999 ]
do
    ext_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)

# example of message
# mosquitto_pub -d -t hello/world -m "$(date) : irot LdB, online. IP is $ext_ip" -h "uveais.ca"

# example of file
# mosquitto_pub -d -t ihdn/alive -f xchng.sh -h "ihdn.ca"
    space=`df -h | awk '{print $5}' | grep % | grep -v Use | head -1 | cut -d "%" -f1 -`
    alertvalue="80"

    if [ "$space" -ge "$alertvalue" ]; then
#     echo "At least one of my disks is nearly full!" | mail -s "daily diskcheck" root
        mosquitto_pub -d -t uvea/alive -m "!!** $(date) : $hostn disk is $space% full. **!!" -h "ihdn.ca"
    else
#     echo "Disk space normal" | mail -s "daily diskcheck" root
        mosquitto_pub -d -t uvea/alive -m " $(date) : $hostn disk is space fine." -h "ihdn.ca"
fi


i=$[$i+1]
sleep 300
done


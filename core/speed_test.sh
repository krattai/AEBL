#!/bin/sh
# test internet speed for setting data txfr speeds
#
# Copyright (C) 2016 - 2017 Uvea I. S., Kevin Rattai
#
# might want to perform once a week
#
 
rm /home/pi/ctrl/speed.txt

echo "internet speed:" > /home/pi/ctrl/speed.txt
 
wget -O /dev/null https://github.com/krattai/AEBL/raw/master/core/stpkg.zip 2>&1 | grep '\([0-9.]\+ [KM]B/s\)' | sed -e 's|^.*(\([0-9.]\+ [KM]B/s\)).*$|\1|' >> /home/pi/ctrl/speed.txt

mosquitto_pub -d -t aebl/alive -m "$(date) : $(cat /etc/hostname) $(cat /home/pi/ctrl/speed.txt)." -h "ihdn.ca"

exit

# echo "10.8.44.2" >> speed.txt
# wget -O /dev/null http://10.8.44.2/stpkg.zip 2>&1 | grep '\([0-9.]\+ [KM]B/s\)' | sed -e 's|^.*(\([0-9.]\+ [KM]B/s\)).*$|\1|' >> speed.txt


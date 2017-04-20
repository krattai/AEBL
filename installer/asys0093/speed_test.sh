#!/bin/sh
# test internet speed for setting data txfr speeds
 
rm /home/pi/ctrl/speed.txt

echo "internet speed:" > /home/pi/ctrl/speed.txt
 
wget -O /dev/null https://github.com/krattai/AEBL/blob/master/core/stpkg.zip 2>&1 | grep '\([0-9.]\+ [KM]B/s\)' | sed -e 's|^.*(\([0-9.]\+ [KM]B/s\)).*$|\1|' >> /home/pi/ctrl/speed.txt

exit

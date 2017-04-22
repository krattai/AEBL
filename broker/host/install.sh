#!/bin/sh
# This script should install ovpn
# Copyright (C) 2016 - 2017 Uvea I. S., Kevin Rattai
#
# get here:
#   wget https://github.com/krattai/AEBL/raw/master/broker/host/install.sh
#

sudo apt-get install -y p7zip-full openvpn

cd tmp

wget https://github.com/krattai/AEBL/raw/master/broker/host/aebl44.7z

7z x aebl44.7z

rm aebl44.7z

sudo mv aebl44.conf /etc/openvpn/aebl44.conf
sudo mv aebl44.crt /etc/openvpn/aebl44.crt
sudo mv aebl44.key /etc/openvpn/aebl44.key
sudo mv aeblca.crt /etc/openvpn/aeblca.crt

sudo chown root:root /etc/openvpn/aebl44.conf
sudo chown root:root /etc/openvpn/aebl44.crt
sudo chown root:root /etc/openvpn/aebl44.key
sudo chown root:root /etc/openvpn/aeblca.crt

sudo chmod 600 /etc/openvpn/aebl44.key

# need to install the following into pub.sh or hrtbt.sh
# IPt44=$(ip addr show tun44 | awk '/inet / {print $2}' | cut -d/ -f 1)
# mosquitto_pub -d -t ihdn/alive -m "$(date) : $hostn tun44 $IPt44 is online." -h "ihdn.ca"

# added this line for better, specific tun44 mmonitoring
# mosquitto_pub -d -t uvea/alive -m "$(date) : $hostn tun44 $IPt44 is online." -h "ihdn.ca"

# need to restart ovpn after this

exit 0

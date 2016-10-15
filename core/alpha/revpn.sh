#!/bin/bash
# Restart VPN
#
# Copyright (C) 2016 Uvea I. S., Kevin Rattai
#
# This may likely only work for AEBL

hostn=$(cat /etc/hostname)
mosquitto_pub -d -t ihdn/alive -m "$(date) : $hostn attempting to restart VPN." -h "ihdn.ca" &
sudo service openvpn restart

exit 0

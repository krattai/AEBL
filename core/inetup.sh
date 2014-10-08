#!/bin/bash
#
# This script is a cron job script
# It checks for network and internet connectivity
# It should attempt to recover from network errors if possible.
#
# wget useful parameters
#
# -c count  ie. 1
# -I interface  either an address, or an interface name
# -q  quiet  output.  Nothing is displayed except the summary lines at startup time and when finished
# --tries=10
# --timeout=20

AEBL_TEST="/home/pi/.aebltest"
AEBL_SYS="/home/pi/.aeblsys"
IHDN_TEST="/home/pi/.ihdntest"
IHDN_SYS="/home/pi/.ihdnsys"
TEMP_DIR="/home/pi/tmp"

T_STO="/run/shm"
T_SCR="/run/shm/scripts"

LOCAL_SYS="${T_STO}/.local"
NETWORK_SYS="${T_STO}/.network"
OFFLINE_SYS="${T_STO}/.offline"


cd $HOME

if [ -f "${AEBL_TEST}" ] || [ -f "${AEBL_SYS}" ]; then
    echo "Checking network status." >> log.txt
    echo $(date +"%T") >> log.txt
fi

# Discover network availability
#
# should have a way to periodically check if no network for a long time
# perhaps a network SHOULD be available, so attempt to establish
# thus:
# if inetup.sh run 4 times = 1 hour, and no network, then
# down, then up, all network interfaces and reset ticker
# or simply do this every time, if no network / offline

if [ -f "${OFFLINE_SYS}" ]; then
    sudo ifdown eth0
    sudo ifdown wlan0
    sleep 5
    sudo ifup eth0
    sudo ifup wlan0
    sleep 10
fi

# Check internet availability against master control IP
ping -c 1 184.71.76.158

if [ $? -eq 0 ]; then
    touch $NETWORK_SYS
    echo "Internet available."
else
    rm $NETWORK_SYS
fi

# Check local network availability against local server
ping -c 1 192.168.200.6

if [[ $? -eq 0 ]]; then
    touch $LOCAL_SYS
    echo "Local network available."
else
    rm $LOCAL_SYS
fi

if [ ! -f "${LOCAL_SYS}" ] && [ ! -f "${NETWORK_SYS}" ]; then
    touch $OFFLINE_SYS
    echo "No network available."
else
    rm $OFFLINE_SYS
fi

# check IPv6 tun vs native assigned IPV6 up and if not, start/restart
if [ -f "${NETWORK_SYS}" ]; then
    if [ ! -L /sys/class/net/tun ]; then
        sudo /etc/init.d/gogoc restart
    fi
fi

exit

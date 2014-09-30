#!/bin/bash
# Shell script to pull channel control files off server
#
# Copyright (C) 2014 Uvea I. S., Kevin Rattai
#
# curl sftp upload example
#
# curl -T "$HOME/mp4/Vanishing Vegetables.mp4" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000000_uploads/"


FIRST_RUN_DONE="/home/pi/.firstrundone"
AEBL_TEST="/home/pi/.aebltest"
AEBL_SYS="/home/pi/.aeblsys"
IHDN_TEST="/home/pi/.ihdntest"
IHDN_SYS="/home/pi/.ihdnsys"
TEMP_DIR="/home/pi/tmp"

LOCAL_SYS="local"
NETWORK_SYS="network"
OFFLINE_SYS="offline"

AEBL_TEST="/home/pi/aebltest"
AEBL_SYS="/home/pi/aeblsys"
IHDN_TEST="/home/pi/ihdntest"
IHDN_SYS="/home/pi/ihdnsys"
TEMP_DIR="/home/pi/tmp"

T_STO="/run/shm"
T_SCR="/run/shm/scripts"

IPe0=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f 1)
MACe0=$(ip link show eth0 | awk '/ether/ {print $2}')

# cd $HOME
# cd ..
while [[ "$PWD" = */mc ]] ; do
    cd ..
done

# check network
#
# this will fail if local network but no internet
# also fails if network was available but drops

if [ ! -f "${OFFLINE_SYS}" ]; then
    if [ -f "${LOCAL_SYS}" ]; then

        echo y | rm mc/chan0/*

        # change chan and folder according to known IHDN_TEST sys
        wget -N -nd -w 3 -P mc/chan0 --limit-rate=50k "http://192.168.200.6/files/ihdn.m3u"
        mv mc/chan0/ihdn.m3u mc/chan0/upload.txt
        wget -N -nd -w 3 -P mc/chan0 --limit-rate=50k "http://192.168.200.6/files/ihdntest.pl"
        mv mc/chan0/ihdntest.pl mc/chan0/playlist.txt
    fi

# /usr/bin/expect <<EOF
# connect via scp
# spawn scp "user@example.com:/home/santhosh/file.dmp" /u01/dumps/file.dmp
#######################
# expect {
#   -re ".*es.*o.*" {
#     exp_send "yes\r"
#     exp_continue
#   }
#   -re ".*sword.*" {
#     exp_send "PASSWORD\r"
#   }
# }
# interact
# EOF

#     curl -o "chan25/upload.txt" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000025/chan25.m3u"
#     curl -o "chan25/playlist.txt" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000025/chan25.pl"
    echo y | rm mc/chan25/*
    pscp -pw password -P 8022 videouser@184.71.76.158:videos/000025/chan25.m3u mc/chan25/upload.txt
    pscp -pw password -P 8022 videouser@184.71.76.158:videos/000025/chan25.pl mc/chan25/playlist.txt

    echo y | rm mc/chan26/*
    pscp -pw password -P 8022 videouser@184.71.76.158:videos/000026/chan26.m3u mc/chan26/upload.txt
    pscp -pw password -P 8022 videouser@184.71.76.158:videos/000026/chan26.pl mc/chan26/playlist.txt

    echo y | rm mc/chan27/*
    pscp -pw password -P 8022 videouser@184.71.76.158:videos/000027/chan27.m3u mc/chan27/upload.txt
    pscp -pw password -P 8022 videouser@184.71.76.158:videos/000027/chan27.pl mc/chan27/playlist.txt

    echo y | rm mc/chan28/*
    pscp -pw password -P 8022 videouser@184.71.76.158:videos/000028/chan28.m3u mc/chan28/upload.txt
    pscp -pw password -P 8022 videouser@184.71.76.158:videos/000028/chan28.pl mc/chan28/playlist.txt

fi

# if [ -f "${HOME}/.newchan0" ]; then
#     $HOME/tmpdir_maintenance/mod_Twitter/./tcli.sh -c statuses_update -s "automagic #IHDNpi Robert E. Steen channel 26 updated." &

# tput clear
exit 0

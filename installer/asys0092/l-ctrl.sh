#!/bin/bash
# keeps systems up to date
#
# Copyright (C) 2015 Uvea I. S., Kevin Rattai
# BSD license https://raw.githubusercontent.com/krattai/AEBL/master/LICENSE
#
# This will eventually co-ordinate with Master Control.

AUTOOFF_CHECK_FILE="/home/pi/.noauto"
FIRST_RUN_DONE="/home/pi/.firstrundone"
AEBL_TEST="/home/pi/.aebltest"
AEBL_SYS="/home/pi/.aeblsys"
AEBL_VM="/home/pi/.aeblvm"
IHDN_TEST="/home/pi/.ihdntest"
IHDN_SYS="/home/pi/.ihdnsys"
IHDN_DET="/home/pi/.ihdndet"
TEMP_DIR="/home/pi/tmp"

T_STO="/run/shm"
T_SCR="/run/shm/scripts"

LOCAL_SYS="${T_STO}/.local"
NETWORK_SYS="${T_STO}/.network"
OFFLINE_SYS="${T_STO}/.offline"

NOTHING_NEW="${T_STO}/.nonew"
NEW_PL="${T_STO}/.newpl"

MACe0=$(ip link show eth0 | awk '/ether/ {print $2}')


cd $HOME

# check ctrlwtch.sh running
if [ ! "$(pgrep ctrlwtch.sh)" ]; then
    $T_SCR/./ctrlwtch.sh &
fi

# check irot or idet and remove aeblsys
if [ -f "${IHDN_TEST}" ] ||  [ -f "${IHDN_SYS}" ] || [ -f "${IHDN_DET}" ]; then
    rm /home/pi/.aeblsys
fi

# create channel file if not exist
if  [ -f "${IHDN_SYS}" ] ||  [ -f "${IHDN_TEST}" ] && [ ! -f "${HOME}/chan" ]; then
    # check folder
    # accordingly, place channel text into chan file
    # which is chan file label and chan folder number for sftp
    if [ -f "${HOME}/.ihdnfol-2" ]; then
        touch /home/pi/chan
        echo "chan-2" >> /home/pi/chan
        echo "0000-2" >> /home/pi/chan
    fi
    if [ -f "${HOME}/.ihdnfol0" ]; then
        touch /home/pi/chan
        echo "chan00" >> /home/pi/chan
        echo "000000" >> /home/pi/chan
    fi
    if [ -f "${HOME}/.ihdnfol25" ]; then
        touch /home/pi/chan
        echo "chan25" >> /home/pi/chan
        echo "000025" >> /home/pi/chan
    fi
    if [ -f "${HOME}/.ihdnfol26" ]; then
        touch /home/pi/chan
        echo "chan26" >> /home/pi/chan
        echo "000026" >> /home/pi/chan
    fi
    if [ -f "${HOME}/.ihdnfol27" ]; then
        touch /home/pi/chan
        echo "chan27" >> /home/pi/chan
        echo "000027" >> /home/pi/chan
    fi
    if [ -f "${HOME}/.ihdnfol28" ]; then
        touch /home/pi/chan
        echo "chan28" >> /home/pi/chan
        echo "000028" >> /home/pi/chan
    fi
    if [ -f "${HOME}/.ihdnfol100" ]; then
        touch /home/pi/chan
        echo "chan100" >> /home/pi/chan
        echo "000100" >> /home/pi/chan
    fi
    if [ -f "${HOME}/.ihdnfol101" ]; then
        touch /home/pi/chan
        echo "chan101" >> /home/pi/chan
        echo "000101" >> /home/pi/chan
    fi
    if [ -f "${HOME}/.ihdnfol102" ]; then
        touch /home/pi/chan
        echo "chan102" >> /home/pi/chan
        echo "000102" >> /home/pi/chan
    fi
    if [ -f "${HOME}/.ihdnfol103" ]; then
        touch /home/pi/chan
        echo "chan103" >> /home/pi/chan
        echo "000103" >> /home/pi/chan
    fi
    if [ -f "${HOME}/.ihdnfol105" ]; then
        touch /home/pi/chan
        echo "chan105" >> /home/pi/chan
        echo "000105" >> /home/pi/chan
    fi
    if [ -f "${HOME}/.ihdnfol106" ]; then
        touch /home/pi/chan
        echo "chan106" >> /home/pi/chan
        echo "000106" >> /home/pi/chan
    fi
    if [ -f "${HOME}/.ihdnfol107" ]; then
        touch /home/pi/chan
        echo "chan107" >> /home/pi/chan
        echo "000107" >> /home/pi/chan
    fi
    if [ -f "${HOME}/.ihdnfol108" ]; then
        touch /home/pi/chan
        echo "chan108" >> /home/pi/chan
        echo "000108" >> /home/pi/chan
    fi
    if [ -f "${HOME}/.ihdnfol109" ]; then
        touch /home/pi/chan
        echo "chan109" >> /home/pi/chan
        echo "000109" >> /home/pi/chan
    fi
    if [ -f "${HOME}/.ihdnfol110" ]; then
        touch /home/pi/chan
        echo "chan110" >> /home/pi/chan
        echo "000110" >> /home/pi/chan
    fi
    if [ -f "${HOME}/.ihdnfol111" ]; then
        touch /home/pi/chan
        echo "chan111" >> /home/pi/chan
        echo "000111" >> /home/pi/chan
    fi
    if [ -f "${HOME}/.ihdnfol112" ]; then
        touch /home/pi/chan
        echo "chan112" >> /home/pi/chan
        echo "000112" >> /home/pi/chan
    fi
    if [ -f "${HOME}/.ihdnfol113" ]; then
        touch /home/pi/chan
        echo "chan113" >> /home/pi/chan
        echo "000113" >> /home/pi/chan
    fi
    if [ -f "${HOME}/.ihdnfol114" ]; then
        touch /home/pi/chan
        echo "chan114" >> /home/pi/chan
        echo "000114" >> /home/pi/chan
    fi
    if [ -f "${HOME}/.ihdnfol116" ]; then
        touch /home/pi/chan
        echo "chan116" >> /home/pi/chan
        echo "000116" >> /home/pi/chan
    fi
    if [ -f "${HOME}/.ihdnfol117" ]; then
        touch /home/pi/chan
        echo "chan117" >> /home/pi/chan
        echo "000117" >> /home/pi/chan
    fi
    if [ -f "${HOME}/.ihdnfol118" ]; then
        touch /home/pi/chan
        echo "chan118" >> /home/pi/chan
        echo "000118" >> /home/pi/chan
    fi
    if [ -f "${HOME}/.ihdnfol119" ]; then
        touch /home/pi/chan
        echo "chan119" >> /home/pi/chan
        echo "000119" >> /home/pi/chan
    fi
fi

# try to recover from non-playing system
# check if supposed to be playing, but not
if [ ! -f "${AUTOOFF_CHECK_FILE}" ] && [ ! "$(pgrep run.sh)" ] && [ ! "$(pgrep omxplayer.bin)" ] && [ ! -f "${IHDN_DET}" ]; then
    # wait a minute
    sleep 60
    # check again, we already know it should be
    if [ ! "$(pgrep run.sh)" ] && [ ! "$(pgrep omxplayer.bin)" ]; then
        # try restarting scripts
        /run/shm/scripts/./startup.sh &
        # wait another minute to let system possibly start
        sleep 60
        # third strike, you're out
        if [ ! "$(pgrep run.sh)" ] && [ ! "$(pgrep omxplayer.bin)" ]; then
            sudo reboot
        fi
        # apparently back up now, so carry on
    fi
fi

echo "Running scheduled l-ctrl job" >> log.txt
echo $(date +"%T") >> log.txt

# log current IPs
echo "Current IPs as follows:" >> log.txt
echo "WAN IP: $IPw0" >> log.txt
echo "LAN IP: $IPe0" >> log.txt

echo $(date +"%y-%m-%d") >> log.txt

killall dbus-daemon

if [ ! -f "${OFFLINE_SYS}" ]; then
    if [ -f "${LOCAL_SYS}" ]; then

        # Get playlists from local server
        if [ -f "${AEBL_TEST}" ]; then
            wget -N -r -nd -l2 -w 3 -O "${T_STO}/mynew.tmp" --limit-rate=50k http://192.168.200.6/files/aebltest.pl
        fi

        if [ -f "${AEBL_SYS}" ]; then
            wget -N -r -nd -l2 -w 3 -O "${T_STO}/mynew.tmp" --limit-rate=50k http://192.168.200.6/files/aebltest.pl
        fi

        if [ -f "${IHDN_TEST}" ]; then
            wget -N -r -nd -l2 -w 3 -O "${T_STO}/mynew.tmp" --limit-rate=50k http://192.168.200.6/files/ihdntest.pl
        fi

        if [ -f "${HOME}/.ihdnfol-1" ]; then
            wget -N -r -nd -l2 -w 3 -O "${T_STO}/mynew.tmp" --limit-rate=50k http://192.168.200.6/files/ihdntest.pl
        fi

        if [ -f "${HOME}/.ihdnfol-2" ]; then
            wget -N -r -nd -l2 -w 3 -O "${T_STO}/mynew.tmp" --limit-rate=50k http://192.168.200.6/files/idettest.pl
        fi

    else

        echo "no further realtime updates for non-local systems"

        # but DO get playlists
        if [ -f "${HOME}/.ihdnfol25" ]; then
            curl -o "${T_STO}/mynew.tmp" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000025/chan25.pl"
        fi

        if [ -f "${HOME}/.ihdnfol26" ]; then
            curl -o "${T_STO}/mynew.tmp" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000026/chan26.pl"
        fi

        if [ -f "${HOME}/.ihdnfol27" ]; then
            curl -o "${T_STO}/mynew.tmp" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000027/chan27.pl"
        fi

        if [ -f "${HOME}/.ihdnfol28" ]; then
            curl -o "${T_STO}/mynew.tmp" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000028/chan28.pl"
        fi

        if [ -f "${HOME}/.ihdnfol100" ]; then
            curl -o "${T_STO}/mynew.tmp" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000100/chan100.pl"
        fi

        if [ -f "${HOME}/.ihdnfol101" ]; then
            curl -o "${T_STO}/mynew.tmp" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000101/chan101.pl"
        fi

        if [ -f "${HOME}/.ihdnfol102" ]; then
            curl -o "${T_STO}/mynew.tmp" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000102/chan102.pl"
        fi

        if [ -f "${HOME}/.ihdnfol103" ]; then
            curl -o "${T_STO}/mynew.tmp" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000103/chan103.pl"
        fi

        if [ -f "${HOME}/.ihdnfol105" ]; then
            curl -o "${T_STO}/mynew.tmp" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000105/chan105.pl"
        fi

        if [ -f "${HOME}/.ihdnfol106" ]; then
            curl -o "${T_STO}/mynew.tmp" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000106/chan106.pl"
        fi

        if [ -f "${HOME}/.ihdnfol107" ]; then
            curl -o "${T_STO}/mynew.tmp" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000107/chan107.pl"
        fi

        if [ -f "${HOME}/.ihdnfol108" ]; then
            curl -o "${T_STO}/mynew.tmp" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000108/chan108.pl"
        fi

        if [ -f "${HOME}/.ihdnfol109" ]; then
            curl -o "${T_STO}/mynew.tmp" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000109/chan109.pl"
        fi

        if [ -f "${HOME}/.ihdnfol110" ]; then
            curl -o "${T_STO}/mynew.tmp" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000110/chan110.pl"
        fi

        if [ -f "${HOME}/.ihdnfol111" ]; then
            curl -o "${T_STO}/mynew.tmp" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000111/chan111.pl"
        fi

        if [ -f "${HOME}/.ihdnfol112" ]; then
            curl -o "${T_STO}/mynew.tmp" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000112/chan112.pl"
        fi

        if [ -f "${HOME}/.ihdnfol113" ]; then
            curl -o "${T_STO}/mynew.tmp" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000113/chan113.pl"
        fi

        if [ -f "${HOME}/.ihdnfol114" ]; then
            curl -o "${T_STO}/mynew.tmp" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000114/chan114.pl"
        fi

        if [ -f "${HOME}/.ihdnfol115" ]; then
            curl -o "${T_STO}/mynew.tmp" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000115/chan115.pl"
        fi

        if [ -f "${HOME}/.ihdnfol116" ]; then
            curl -o "${T_STO}/mynew.tmp" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000116/chan116.pl"
        fi

        if [ -f "${HOME}/.ihdnfol117" ]; then
            curl -o "${T_STO}/mynew.tmp" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000117/chan117.pl"
        fi

        if [ -f "${HOME}/.ihdnfol118" ]; then
            curl -o "${T_STO}/mynew.tmp" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000118/chan118.pl"
        fi

        if [ -f "${HOME}/.ihdnfol119" ]; then
            curl -o "${T_STO}/mynew.tmp" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000119/chan119.pl"
        fi

    fi

    dos2unix "${T_STO}/mynew.tmp"
    mv "${T_STO}/mynew.tmp" "${T_STO}/mynew.pl"

    $T_SCR/./synfilz.sh &

    if [ ! -f "{$T_STO}/.getchan" ]; then
        $T_SCR/./grbchan.sh &
    fi

    if [ ! -f "{$T_STO}/.delfile" ]; then
        $T_SCR/./rmfile.sh &
    fi

fi

if [ -f "${IHDN_SYS}" ] || [ -f "${IHDN_DET}" ] && [ -f $HOME/.production ]; then

    $T_SCR/./prs.sh

    cp /home/pi/chan /home/pi/chtmp
    CHAN_LOC="chtmp"
    # Get the channel id
    c_id=$(cat "${CHAN_LOC}" | head -n1)
    # And strip it off the file
    cat "${CHAN_LOC}" | tail -n+2 > "${CHAN_LOC}.new"
    mv "${CHAN_LOC}.new" "${CHAN_LOC}"
    # Get channel number
    chan=$(cat "${CHAN_LOC}" | head -n1)

    rm "${CHAN_LOC}"

    # upload ping.txt to sftp server
    curl -T "$HOME/ping.txt" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000000_uploads/ihdnpi_logs/ping_${chan}.txt" &
 
fi
exit

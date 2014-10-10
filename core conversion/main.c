/* main.c: replacement for startup.sh and run.sh
           this is the master program that starts and manages system

Copyright (C) 2014 Uvea I. S., Kevin Rattai
Date created:	October 10, 2014

*/

#include <sys/types.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

void main(void)
{
    char AEBL_TEST="/home/pi/.aebltest",
         AEBL_SYS="/home/pi/.aeblsys",
         TEMP_DIR="/home/pi/tmp",
         T_STO="/run/shm",
         T_SCR="/run/shm/scripts",
         LOCAL_SYS="${T_STO}/.local", /* will be used in conj with path */
         NETWORK_SYS="${T_STO}/.network", /* will be used in conj with path */
         OFFLINE_SYS="${T_STO}/.offline"; /* will be used in conj with path */

	printf("\n\nThis applications manages the system\n");
	system("startup.sh");
	system("run.sh");

/* What follows is the original source from the startup.sh app */
/*   Should be part of a main.c function startup()             */

cd $HOME

cp -p /home/pi/.scripts/* /run/shm/scripts

if [ ! -f "${T_STO}/.optimized" ]; then
#     sudo service dbus stop
    sudo mount -o remount,size=128M /dev/shm
    echo -n performance | sudo tee /sys/devices/system/cpu/cpu0/cpufreq/scaling_governor
    sudo service triggerhappy stop
    sudo killall console-kit-daemon
    sudo killall polkitd
    killall gvfsd
    killall dbus-daemon
    killall dbus-launch
    touch $T_STO/.optimized

fi

if [ ! -f "${T_STO}/.mkplayrun" ] && [ ! -f "${IHDN_DET}" ]; then
    $T_SCR/./mkplay.sh &
fi

if [ ! -f "${FIRST_RUN_DONE}" ]; then
    chmod 777 $HOME/pl
    chmod 777 $HOME/ctrl
    chmod 777 $HOME/mp4
    chmod 777 $HOME/mp3

    rm .id

    # archive files - eventually, this should be a standalone script
    # assumption made that on first run, all files good
    mkdir $HOME/.backup
    cp $HOME/version $HOME/.backup
    mkdir $HOME/.backup/scripts
    cp $HOME/scripts/*.sh $HOME/.backup/scripts
#     cp $HOME/.scripts/*.sh $HOME/.backup/scripts
    mkdir $HOME/.backup/bin
    cp $HOME/bin/* $HOME/.backup/bin
    mkdir $HOME/.backup/pl
    cp $HOME/pl/* $HOME/.backup/pl
    mkdir $HOME/.backup/ctrl
    cp $HOME/ctrl/* $HOME/.backup/ctrl

    touch $HOME/.firstrundone
fi

if [ -f "${T_STO}/.omx_playing" ]; then
    rm $T_STO/.omx_playing
fi

echo "~~~~~~~~~~~~~~~~~~~~~~~~" >> log.txt
echo $(date +"%T") >> log.txt
echo "Booted up." >> log.txt

# Discover network availability if not previously tested
if [ ! -f "${LOCAL_SYS}" ] && [ ! -f "${NETWORK_SYS}" ] && [ ! -f "${OFFLINE_SYS}" ]; then

    $T_SCR/./inetup.sh

fi

if [ ! -f "${OFFLINE_SYS}" ] && [ ! -f "${IHDN_DET}" ]; then
    $T_SCR/./mkuniq.sh &

    ID_FILE="${HOME}/ctrl/ip.txt"
    IPw0=$(ip addr show wlan0 | awk '/inet / {print $2}' | cut -d/ -f 1)
    IPe0=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f 1)

    echo ${IPw0} > ${ID_FILE}
    echo ${IPe0} >> ${ID_FILE}

    ID_FILE="${HOME}/ctrl/ip.txt"
    IPw0=$(ip addr show wlan0 | awk '/inet / {print $2}' | cut -d/ -f 1)
    IPe0=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f 1)

    echo ${IPw0} > ${ID_FILE}
    echo ${IPe0} >> ${ID_FILE}

fi

if [ ! "$(pgrep ctrlwtch.sh)" ]; then
    $T_SCR/./ctrlwtch.sh &
fi


# clear all network check files
rm index*

$T_SCR/./run.sh &

/* What follows is the original source from the run.sh app     */
/*   Should be part of a main.c function run() or main()       */

NOTHING_NEW="${T_STO}/.nonew"
NEW_PL="${T_STO}/.newpl"

IPw0=$(ip addr show wlan0 | awk '/inet / {print $2}' | cut -d/ -f 1)
MACw0=$(ip link show wlan0 | awk '/ether/ {print $2}')
IPe0=$(ip addr show eth0 | awk '/inet / {print $2}' | cut -d/ -f 1)
MACe0=$(ip link show eth0 | awk '/ether/ {print $2}')

CRONCOMMFILE="${T_STO}/.tempcron"
 
# set to home directory
 
cd $HOME

touch $T_STO/.sysrunning

while [ -f "${T_STO}/.sysrunning" ]; do

    # log .id

#    cat .id >> log.txt

    if [ -f "${AEBL_TEST}" ] || [ -f "${AEBL_SYS}" ]; then
        $T_SCR/./aebl_play.sh

        if [ "${MACe0}" == 'b8:27:eb:37:07:5a' ] && [ -f "${AEBL_SYS}" ]; then
#            echo "MAC is ending :5a so touching .aeblsys_test." >> log.txt
#            echo $(date +"%T") >> log.txt
            touch .aeblsys_test
            touch .aebltest
            rm ${AEBL_SYS}
        fi
    fi

    if [ -f "${IHDN_TEST}" ] || [ -f "${IHDN_SYS}" ]; then
        if [ ! -f "${IHDN_DET}" ]; then
            $T_SCR/./ihdn_play.sh
        fi
        if [ ! -f "${T_STO}/.syschecks" ] && [ ! "$(pgrep ihdn_tests.sh)" ]; then
            $T_SCR/./ihdn_tests.sh &
        fi
    fi

    # Check nothing new
    # This section to watch and react to requested or auto change in system


    if [ -f "${AEBL_TEST}" ] || [ -f "${AEBL_SYS}" ] && [ ! -f "${NOTHING_NEW}" ]; then
#        echo "Setting system to not check updates with .nonew" >> log.txt
#        echo $(date +"%T") >> log.txt
        touch $T_STO/.nonew
    fi

done

# if .sysrunning token cleared, loop back to startup.sh

$T_SCR/./startup.sh &

}

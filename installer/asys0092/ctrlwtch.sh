#!/bin/bash
#
# manages ctrl folder content
#
# Copyright (C) 2014 Uvea I. S., Kevin Rattai
#

AEBL_TEST="/home/pi/.aebltest"
AEBL_SYS="/home/pi/.aeblsys"
# IHDN_TEST="/home/pi/.ihdntest"
# IHDN_SYS="/home/pi/.ihdnsys"
TEMP_DIR="/home/pi/tmp"

T_STO="/run/shm"
T_SCR="/run/shm/scripts"

LOCAL_SYS="${T_STO}/.local"
NETWORK_SYS="${T_STO}/.network"
OFFLINE_SYS="${T_STO}/.offline"

# NEW_PL="/home/pi/.newpl"
# PLAYLIST="/home/pi/.playlist"

# MACe0=$(ip link show eth0 | awk '/ether/ {print $2}')

cd $HOME

while [ ! -f "${HOME}/ctrl/reboot" ]; do

    # not clean, but useful for now, cron will restart ctrlwtch.sh
    if [ -f "${HOME}/ctrl/.newctrl" ]; then
        rm "${HOME}/ctrl/.newctrl"
        sleep 2
        if [ "$(pgrep ctrlwtch.sh)" ]; then
            kill $(pgrep ctrlwtch.sh)
        fi
    fi

    # manual patch
    if [ -f "${HOME}/ctrl/patch" ]; then
        /run/shm/scripts/patch.sh &
        sudo chown pi:pi "${HOME}/ctrl/patch"
        rm "${HOME}/ctrl/patch"
    fi

    # force patch rollback
    if [ -f "${HOME}/ctrl/rollback" ]; then
        /run/shm/scripts/rollback.sh &
        sudo chown pi:pi "${HOME}/ctrl/rollback"
        rm "${HOME}/ctrl/rollback"
    fi

     # force system rebuild, bringing system to current
    if [ -f "${HOME}/ctrl/rebuild" ]; then
        /run/shm/scripts/rebuild.sh &
        sudo chown pi:pi "${HOME}/ctrl/rebuild"
        rm "${HOME}/ctrl/rebuild"
    fi

   # change hostname
    if [ -f "${HOME}/ctrl/hostname" ]; then
        mv "${HOME}/ctrl/hostname" "${HOME}/ctrl/newhost"
        /run/shm/scripts/chhostname.sh &
    fi

    # Process request to display the contents of the pl folder
    if [ -f "${HOME}/ctrl/showpl" ]; then
        rm "${HOME}/ctrl/showpl"
        cat "${T_STO}/.newpl"
    fi

    # Set stand alone AEBL playlist, currently only for mp4 content
    # !! 141001 - THIS FUNCTION AND NOT TESTED AT THIS DATE !!
    # !? Why can this not just cp ctrl/newpl to /run/shm/mynew.pl ?!
    if [ -f "${HOME}/ctrl/newpl" ]; then
        dos2unix "${HOME}/ctrl/newpl"
        cp "${HOME}/ctrl/newpl" "${HOME}/ctrl/pltmp"
        PL_FILES="${HOME}/ctrl/pltmp"
        touch $T_STO/plfiles
        while [ -f "${T_STO}/plfiles" ]; do
            # Do nothing if no remove file
            if [ ! -f "ctrl/${PL_FILES}" ]; then
                echo "File ${PL_FILES} not found"
                continue
            fi
            # Get the top of the remove list
            file=$(cat "ctrl/${PL_FILES}" | head -n1)
            # And strip it off the playlist file
            cat "ctrl/${PL_FILES}" | tail -n+2 > "ctrl/${PL_FILES}.new"
            mv "ctrl/${PL_FILES}.new" "ctrl/${PL_FILES}"
            # Skip if this is empty
            if [ -z "${file}" ]; then
                echo "Remove file empty or bumped into an empty entry"
                rm $T_STO/plfiles
                continue
            fi
            # Check that the file exists
            if [ ! -f "pl/${file}" ]; then
                echo "File ${file} not found"
                continue
            fi
            # move the file
            mv "pl/${file}" "mp4/${file}"
        done
        rm "ctrl/${PL_FILES}"
        rm "ctrl/${PL_FILES}.new"
        # This is on faith, I have absolutely no idea where mkplay.sh is called
        # NB: mkplay.sh is daemon run from startup.sh except on detector
        mv "${HOME}/ctrl/newpl" "${T_STO}/mynew.pl"
    fi

    # Reset stand alone AEBL playlist placing content back to pl folder
    # Waring:  Using this function on channel AEBL could cause errors
    # !! 141001 - THIS FUNCTION AND NOT TESTED AT THIS DATE !!
    if [ -f "${HOME}/ctrl/resetpl" ]; then
        mv mp4/* pl
        mv mp3/* pl
    fi

    # Process request to remove content from pl folder
    # !! 141101 - THIS FUNCTION AND NOT TESTED AT THIS DATE !!
    if [ -f "${HOME}/ctrl/rmfiles" ] && [ ! -f "{$T_STO}/.delfile" ]; then
        $T_SCR/./rmfile.sh &
        # make sure wait long enough for rmfile.sh to mark .delfile token
        sleep 2
    fi
#         dos2unix "${HOME}/ctrl/rmfiles"
#         REMOVE_FILES="${HOME}/ctrl/rmfiles"
#         touch $T_STO/rmfiles
#         while [ -f "${T_STO}/rmfiles" ]; do
#             # Do nothing if no remove file
#             if [ ! -f "ctrl/${REMOVE_FILES}" ]; then
#                 echo "File ${REMOVE_FILES} not found"
#                 continue
#             fi
            # Get the top of the remove list
#             file=$(cat "ctrl/${REMOVE_FILES}" | head -n1)
            # And strip it off the playlist file
#             cat "ctrl/${REMOVE_FILES}" | tail -n+2 > "ctrl/${REMOVE_FILES}.new"
#             mv "ctrl/${REMOVE_FILES}.new" "ctrl/${REMOVE_FILES}"
            # Skip if this is empty
#             if [ -z "${file}" ]; then
#                 echo "Remove file empty or bumped into an empty entry"
#                 rm $T_STO/rmfiles
#                 continue
#             fi
            # Check that the file exists
#             if [ ! -f "pl/${file}" ]; then
#                 echo "File ${file} not found"
#                 continue
#             fi
            # remove the file
#             rm "pl/${file}"
#         done
#         rm "ctrl/${REMOVE_FILES}"
#         rm "ctrl/${REMOVE_FILES}.new"
#     fi

    # Add blade to AEBL
    # At the time of code, most blades are simply installed applications
    #  and we will restrict only one blade install per request, at this time
    if [ -f "${HOME}/ctrl/mkblade" ]; then
        # once working, the following code will be in mkblade.sh and this will
        #  simply call mkblade.sh and carry on
        dos2unix "${HOME}/ctrl/mkblade"
        # Get the top of the remove list
        blade=$(cat "ctrl/mkblade" | head -n1)
        if [ "$blade" == "raspctl" ]; then
            wget -N -r -nd -l2 -w 3 -O "${T_SCR}/raspctl.sh" --limit-rate=50k https://github.com/krattai/AEBL/blob/master/blades/raspctl.sh?raw=true
            chmod 777 $T_SCR/raspctl.sh
            $T_SCR/raspctl.sh &
            mkdir /home/pi/blades
            touch /home/pi/blades/raspctl
        fi
        if [ "$blade" == "mediatomb" ]; then
            wget -N -r -nd -l2 -w 3 -O "${T_SCR}/mediatomb.sh" --limit-rate=50k https://github.com/krattai/AEBL/blob/master/blades/mediatomb.sh?raw=true
            chmod 777 $T_SCR/mediatomb.sh
            $T_SCR/mediatomb.sh &
            mkdir /home/pi/blades
            touch /home/pi/blades/mediatomb
        fi
        if [ "$blade" == "webmin" ]; then
            wget -N -r -nd -l2 -w 3 -O "${T_SCR}/webmin.sh" --limit-rate=50k https://github.com/krattai/AEBL/blob/master/blades/webmin.sh?raw=true
            chmod 777 $T_SCR/webmin.sh
            $T_SCR/webmin.sh &
            mkdir /home/pi/blades
            touch /home/pi/blades/webmin
        fi
        if [ "$blade" == "owncloud" ]; then
            wget -N -r -nd -l2 -w 3 -O "${T_SCR}/owncloud.sh" --limit-rate=50k https://github.com/krattai/AEBL/blob/master/blades/owncloud.sh?raw=true
            chmod 777 $T_SCR/owncloud.sh
            $T_SCR/owncloud.sh &
            mkdir /home/pi/blades
            touch /home/pi/blades/owncloud
        fi
        if [ "$blade" == "ajenti" ]; then
            wget -N -r -nd -l2 -w 3 -O "${T_SCR}/ajenti.sh" --limit-rate=50k https://github.com/krattai/AEBL/blob/master/blades/ajenti.sh?raw=true
            chmod 777 $T_SCR/ajenti.sh
            $T_SCR/ajenti.sh &
            mkdir /home/pi/blades
            touch /home/pi/blades/ajenti
        fi
#         sudo apt-get install -y $blade

        # this should only remove mkblade once mkblade.sh no longer running
        # ie.  if ! ps aux | grep mkblade.sh then mkblade.sh rm mkblade fi
        rm ctrl/mkblade
    fi

    # Remove blade from AEBL
    # At the time of code, most blades are simply installed applications
    #  and we will restrict only one blade install per request, at this time
    # !! 141002 - THIS FUNCTION AND NOT TESTED AT THIS DATE !!
    if [ -f "${HOME}/ctrl/rmblade" ]; then
        dos2unix "${HOME}/ctrl/rmblade"
        # Get the top of the remove list
        blade=$(cat "ctrl/rmblade" | head -n1)
        sudo apt-get remove $blade
        rm ctrl/rmblade
    fi

    # Set wlan
    # !! 141002 - THIS FUNCTION AND NOT TESTED AT THIS DATE !!
    if [ -f "${HOME}/ctrl/wlan" ]; then
        dos2unix "${HOME}/ctrl/wlan"
        # Get the top of the remove list
        sudo mv "${HOME}/ctrl/wlan" "/etc/network/interfaces"
        touch ctrl/reboot
    fi

    # check channel change present
    # eventually want to put in a channel file which will consist of:
    #     add channel :- +26
    #     remove channel :- -26
    #  or change channel :- =26 (which removes all other channels

    if ls /home/pi/ctrl/cchan* &> /dev/null; then
        echo "files do exist"

        # for now, just emulate channel change, then figue out rest
        cd $HOME/ctrl
        find -depth -name "cchan*" -exec bash -c 'cp "$1" "${1/\cchan/chanid}"' _ {} \;
        rm /home/pi/ctrl/cchan*
        cd $HOME

        # example of adding chanid to ctrl in ihdn_test.sh
#         if ! ls /home/pi/ctrl/chanid* &> /dev/null; then
    #         cp /home/pi/.ihdnfol* /home/pi/ctrl/chanid*
#             cd $HOME
            # this finds .ihdnfol* and copies renamed file it to ctrl fol
#             find -depth -name "chan.ihdnfol*" -exec bash -c 'cp "$1" "ctrl/${1/\.ihdnfol/chanid}"' _ {} \;
#         fi    
#     else
#         echo "files do not exist"
#     fi
    fi

    # put audio and/or video files to proper folders
    if ls /home/pi/ctrl/*.mp4 &> /dev/null; then
        if ! [[ `smbstatus | grep -i mp4` ]]; then
            mv /home/pi/ctrl/*.mp4 /home/pi/pl
        fi
    fi

    if ls /home/pi/ctrl/*.mp3 &> /dev/null; then
        if ! [[ `smbstatus | grep -i mp3` ]]; then
            mv /home/pi/ctrl/*.mp3 /home/pi/pl
        fi
    fi

    if [ ! -f "${HOME}/ctrl/Welcome.txt" ]; then
        cp "${HOME}/.backup/Welcome.txt" "${HOME}/ctrl" 
    fi

    if [ ! -f "${HOME}/ctrl/admin_guide.txt" ]; then
        cp "${HOME}/.backup/admin_guide.txt" "${HOME}/ctrl" 
    fi

    if [ -f "${HOME}/ctrl/halt" ]; then
        sudo chown pi:pi "${HOME}/ctrl/halt"
        touch "${HOME}/ctrl/reboot"
    fi

# Need to be sure that ctrlwtch does not fire certain functions if
#  it is NOT an .aebltest or .aeblsys appliance.

    # Do features not part of IHDN systems
    if [ ! -f "${IHDN_SYS}" ]; then

        if [ -f "${HOME}/ctrl/noauto" ]; then
            rm "${HOME}/ctrl/noauto"
            touch "${HOME}/.noauto"
            touch "${HOME}/ctrl/reboot"
        fi

        if [ -f "${HOME}/ctrl/auto" ]; then
            rm "${HOME}/ctrl/auto"
            rm "${HOME}/.noauto"
            touch "${HOME}/ctrl/reboot"
        fi

        if [ -f "${HOME}/ctrl/next" ]; then
            rm "${HOME}/ctrl/next"
            kill $(pgrep omxplayer.bin)
        fi

    fi

    # Do features specific to IHDN
#     if [ -f "${IHDN_SYS}" ] && [ -f "${HOME}/ctrl/password" ]; then

#         if [ -f "${HOME}/ctrl/noauto" ]; then
#             rm "${HOME}/ctrl/noauto"
#             touch "${HOME}/.noauto"
#             touch "${HOME}/ctrl/reboot"
#         fi

#         if [ -f "${HOME}/ctrl/auto" ]; then
#             rm "${HOME}/ctrl/auto"
#             rm "${HOME}/.noauto"
#             touch "${HOME}/ctrl/reboot"
#         fi

#     fi

    sleep 1s

done

sudo chown pi:pi "${HOME}/ctrl/reboot"
rm $HOME/ctrl/reboot

if [  -f "${HOME}/ctrl/halt" ]; then
    rm "${HOME}/ctrl/halt"

    sleep 1s
    sudo poweroff &
else
    sleep 1s
    sudo reboot &
fi

exit 0

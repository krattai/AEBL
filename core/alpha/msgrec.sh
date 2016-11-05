#!/bin/bash
# AEBL receive control messages using MQTT
#
# Copyright (C) 2015 - 2016 Uvea I. S., Kevin Rattai
#
# The beginning of this script is from ctrlwtch.sh as a reference for
#   $hostname control messages

# add "out" for detectors

# i="0"

# ext_ip=$(dig +short myip.opendns.com @resolver1.opendns.com)
# mosquitto_pub -d -t hello/world -m "$(date) : irot LdB, online. IP is $ext_ip" -h "uveais.ca"

# mosquitto_pub -d -t hello/world -m "$(date) : AEBL device from $ext_ip ping." -h "uveais.ca"

# the following code is example of MQTT subscribe usage
# mosquitto_sub -h uveais.ca -t "hello/+" -t "aebl/+" -t "ihdn/+"

# this routine function should listen on topic and then act on it

# it might be something like this, to grab messages off broker
# mosquitto_sub -d -t +/# 2>&1 | sed -n "/PUBLISH/{s|.*\('.*',\).*|\1$(date),|;N;s/\n//;p}"

# will need to fix the checks below
# while [ ! -f "${HOME}/ctrl/reboot" ]; do

    # not clean, but useful for now, cron will restart ctrlwtch.sh
#     if [ -f "${HOME}/ctrl/.newctrl" ]; then
#         rm "${HOME}/ctrl/.newctrl"
#         sleep 2
#         if [ "$(pgrep ctrlwtch.sh)" ]; then
#             kill $(pgrep ctrlwtch.sh)
#         fi
#     fi

    # manual patch
#     if [ -f "${HOME}/ctrl/patch" ]; then
#         /run/shm/scripts/patch.sh &
#         sudo chown pi:pi "${HOME}/ctrl/patch"
#         rm "${HOME}/ctrl/patch"
#     fi

    # force patch rollback
#     if [ -f "${HOME}/ctrl/rollback" ]; then
#         /run/shm/scripts/rollback.sh &
#         sudo chown pi:pi "${HOME}/ctrl/rollback"
#         rm "${HOME}/ctrl/rollback"
#     fi

     # force system rebuild, bringing system to current
#     if [ -f "${HOME}/ctrl/rebuild" ]; then
#         /run/shm/scripts/rebuild.sh &
#         sudo chown pi:pi "${HOME}/ctrl/rebuild"
#         rm "${HOME}/ctrl/rebuild"
#     fi

   # change hostname
#     if [ -f "${HOME}/ctrl/hostname" ]; then
#         mv "${HOME}/ctrl/hostname" "${HOME}/ctrl/newhost"
#         /run/shm/scripts/chhostname.sh &
#     fi

    # Process request to display the contents of the pl folder
#     if [ -f "${HOME}/ctrl/showpl" ]; then
#         rm "${HOME}/ctrl/showpl"
#         cat "${T_STO}/.newpl"
#     fi

    # Set stand alone AEBL playlist, currently only for mp4 content
    # !! 141001 - THIS FUNCTION AND NOT TESTED AT THIS DATE !!
    # !? Why can this not just cp ctrl/newpl to /run/shm/mynew.pl ?!
#     if [ -f "${HOME}/ctrl/newpl" ]; then
#         dos2unix "${HOME}/ctrl/newpl"
#         cp "${HOME}/ctrl/newpl" "${HOME}/ctrl/pltmp"
#         PL_FILES="${HOME}/ctrl/pltmp"
#         touch $T_STO/plfiles
#         while [ -f "${T_STO}/plfiles" ]; do
            # Do nothing if no remove file
#             if [ ! -f "ctrl/${PL_FILES}" ]; then
#                 echo "File ${PL_FILES} not found"
#                 continue
#             fi
            # Get the top of the remove list
#             file=$(cat "ctrl/${PL_FILES}" | head -n1)
            # And strip it off the playlist file
#             cat "ctrl/${PL_FILES}" | tail -n+2 > "ctrl/${PL_FILES}.new"
#             mv "ctrl/${PL_FILES}.new" "ctrl/${PL_FILES}"
            # Skip if this is empty
#             if [ -z "${file}" ]; then
#                 echo "Remove file empty or bumped into an empty entry"
#                 rm $T_STO/plfiles
#                 continue
#             fi
            # Check that the file exists
#             if [ ! -f "pl/${file}" ]; then
#                 echo "File ${file} not found"
#                 continue
#             fi
            # move the file
#             mv "pl/${file}" "mp4/${file}"
#         done
#         rm "ctrl/${PL_FILES}"
#         rm "ctrl/${PL_FILES}.new"
        # This is on faith, I have absolutely no idea where mkplay.sh is called
        # NB: mkplay.sh is daemon run from startup.sh except on detector
#         mv "${HOME}/ctrl/newpl" "${T_STO}/mynew.pl"
#     fi

    # Reset stand alone AEBL playlist placing content back to pl folder
    # Waring:  Using this function on channel AEBL could cause errors
    # !! 141001 - THIS FUNCTION AND NOT TESTED AT THIS DATE !!
#     if [ -f "${HOME}/ctrl/resetpl" ]; then
#         mv mp4/* pl
#         mv mp3/* pl
#     fi

    # Process request to remove content from pl folder
    # !! 141101 - THIS FUNCTION AND NOT TESTED AT THIS DATE !!
#     if [ -f "${HOME}/ctrl/rmfiles" ] && [ ! -f "{$T_STO}/.delfile" ]; then
#         $T_SCR/./rmfile.sh &
        # make sure wait long enough for rmfile.sh to mark .delfile token
#         sleep 2
#     fi
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
#     if [ -f "${HOME}/ctrl/mkblade" ]; then
        # once working, the following code will be in mkblade.sh and this will
        #  simply call mkblade.sh and carry on
#         dos2unix "${HOME}/ctrl/mkblade"
        # Get the top of the remove list
#         blade=$(cat "ctrl/mkblade" | head -n1)
#         if [ "$blade" == "raspctl" ]; then
#             wget -N -r -nd -l2 -w 3 -O "${T_SCR}/raspctl.sh" --limit-rate=50k https://github.com/krattai/AEBL/blob/master/blades/raspctl.sh?raw=true
#             chmod 777 $T_SCR/raspctl.sh
#             $T_SCR/raspctl.sh &
#             mkdir /home/pi/blades
#             touch /home/pi/blades/raspctl
#         fi
#         if [ "$blade" == "mediatomb" ]; then
#             wget -N -r -nd -l2 -w 3 -O "${T_SCR}/mediatomb.sh" --limit-rate=50k https://github.com/krattai/AEBL/blob/master/blades/mediatomb.sh?raw=true
#             chmod 777 $T_SCR/mediatomb.sh
#             $T_SCR/mediatomb.sh &
#             mkdir /home/pi/blades
#             touch /home/pi/blades/mediatomb
#         fi
#         sudo apt-get install -y $blade

        # this should only remove mkblade once mkblade.sh no longer running
        # ie.  if ! ps aux | grep mkblade.sh then mkblade.sh rm mkblade fi
#         rm ctrl/mkblade
#     fi

    # Remove blade from AEBL
    # At the time of code, most blades are simply installed applications
    #  and we will restrict only one blade install per request, at this time
    # !! 141002 - THIS FUNCTION AND NOT TESTED AT THIS DATE !!
#     if [ -f "${HOME}/ctrl/rmblade" ]; then
#         dos2unix "${HOME}/ctrl/rmblade"
        # Get the top of the remove list
#         blade=$(cat "ctrl/rmblade" | head -n1)
#         sudo apt-get remove $blade
#         rm ctrl/rmblade
#     fi

    # Set wlan
    # !! 141002 - THIS FUNCTION AND NOT TESTED AT THIS DATE !!
#     if [ -f "${HOME}/ctrl/wlan" ]; then
#         dos2unix "${HOME}/ctrl/wlan"
        # Get the top of the remove list
#         sudo mv "${HOME}/ctrl/wlan" "/etc/network/interfaces"
#         touch ctrl/reboot
#     fi

    # check channel change present
    # eventually want to put in a channel file which will consist of:
    #     add channel :- +26
    #     remove channel :- -26
    #  or change channel :- =26 (which removes all other channels

#     if ls /home/pi/ctrl/cchan* &> /dev/null; then
#         echo "files do exist"

        # for now, just emulate channel change, then figue out rest
#         cd $HOME/ctrl
#         find -depth -name "cchan*" -exec bash -c 'cp "$1" "${1/\cchan/chanid}"' _ {} \;
#         rm /home/pi/ctrl/cchan*
#         cd $HOME

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
#     fi

    # put audio and/or video files to proper folders
#     if ls /home/pi/ctrl/*.mp4 &> /dev/null; then
#         if ! [[ `smbstatus | grep -i mp4` ]]; then
#             mv /home/pi/ctrl/*.mp4 /home/pi/pl
#         fi
#     fi

#     if [ ! -f "${HOME}/ctrl/Welcome.txt" ]; then
#         cp "${HOME}/.backup/Welcome.txt" "${HOME}/ctrl" 
#     fi

#     if [ -f "${HOME}/ctrl/halt" ]; then
#         sudo chown pi:pi "${HOME}/ctrl/halt"
#         touch "${HOME}/ctrl/reboot"
#     fi

# Need to be sure that ctrlwtch does not fire certain functions if
#  it is NOT an .aebltest or .aeblsys appliance.

    # Do features not part of IHDN systems
#     if [ ! -f "${IHDN_SYS}" ]; then

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

#         if [ -f "${HOME}/ctrl/next" ]; then
#             rm "${HOME}/ctrl/next"
#             kill $(pgrep omxplayer.bin)
#         fi

#     fi

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

#     sleep 1s

# done

#
# Element14 - SuddenImpact design challenge
# http://www.element14.com/community/community/design-challenges/sudden-impact
#
# This file is part of submission made for Modular&EasyConfigure project (tomaj$
#

# Expect this script to watch channels by name, number, or hostname

#     mosquitto_sub -h uveais.ca -t "aebl/add/content" |
#     while IFS= read -r line

# use hostname to determine channel to watch as initial version
hostn=$(cat /etc/hostname)

# mosquitto_pub -d -t ihdn/alive -m "$(date) : $hostn IPv6 $ext_ip6 is online." -h "ihdn.ca"

# need to check if should be watching ALL or just certain:
#  + all by aebl/$hostn/#
#  + certain as topics by name 

# mosquitto_pub -d -t aebl/ctrl/idet009 -m "reboot" -h "ihdn.ca"


mosquitto_sub -h "ihdn.ca" -t "aebl/ctrl/$hostn/#" |
while IFS= read -r line
    do
#           if [[ $line = "sixxs alive" ]]; then
#               echo "$(date +"%T") - sixxs ACK"
#               echo " "
#           fi
#           if [[ $line == *"ihdnsrvr IPv6"* ]]; then
#               echo "$(date +"%T") - ihdnsrvr ACK"
#               echo "$line"
#               echo " "
#           fi
#

            # Append file to playlist
#             echo "$line #am2p" >> "${CONTENT}"

#           if [[ $line = "sixxs alive" ]]; then
#               echo "$(date +"%T") - sixxs ACK"
#               echo " "
#           fi

          if [[ $line = "reboot" ]]; then
              touch ctrl/reboot
          fi

          if [[ $line = "halt" ]]; then
              touch ctrl/halt
          fi

          if [[ $line = "patch" ]]; then
              touch ctrl/patch
          fi

          if [[ $line = "revpn" ]]; then
              /run/shm/scripts/revpn.sh &
          fi

done

exit 0

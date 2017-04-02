/* l-ctrl.c: replacement for l-ctrl.sh and synfilz.sh
           this is the master cron job that handles system syncs

Copyright (C) 2014 - 2017 Uvea I. S., Kevin Rattai
Date created:	October 10, 2014

*/

#include <sys/types.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

void main(void)
{
    const char AEBL_TEST[] = "/home/pi/.aebltest",
         AEBL_SYS[] = "/home/pi/.aeblsys",
         TEMP_DIR[] = "/home/pi/tmp",
         T_STO[] = "/run/shm",
         T_SCR[] = "/run/shm/scripts",
         LOCAL_SYS[] = "${T_STO}/.local", /* will be used in conj with path */
         NETWORK_SYS[] = "${T_STO}/.network", /* will be used in conj with path */
         OFFLINE_SYS[] = "${T_STO}/.offline"; /* will be used in conj with path */

	printf("\n\nThis applications manages the system\n");
	system("startup.sh");
	system("run.sh");

    const char AUTOOFF_CHECK_FILE[] = "/home/pi/.noauto"
    const char FIRST_RUN_DONE[] = "/home/pi/.firstrundone"
    const char AEBL_TEST[] = "/home/pi/.aebltest"
    const char AEBL_SYS[] = "/home/pi/.aeblsys"
    const char IHDN_TEST[] = "/home/pi/.ihdntest"
    const char IHDN_SYS[] = "/home/pi/.ihdnsys"
    const char IHDN_DET[] = "/home/pi/.ihdndet"
    const char TEMP_DIR[] = "/home/pi/tmp"

    const char T_STO[] = "/run/shm"
    const char T_SCR[] = "/run/shm/scripts"

    const char LOCAL_SYS[] = "${T_STO}/.local"
    const char NETWORK_SYS[] = "${T_STO}/.network"
    const char OFFLINE_SYS[] = "${T_STO}/.offline"

    const char NOTHING_NEW[] = "${T_STO}/.nonew"
    const char NEW_PL[] = "${T_STO}/.newpl"

    const char MACe0[] = $(ip link show eth0 | awk '/ether/ {print $2}')

    /* What follows is the original source from the l-ctrl.sh app  */

    cd $HOME

    # check ctrlwtch.sh running
    if [ ! "$(pgrep ctrlwtch.sh)" ]; then
        $T_SCR/./ctrlwtch.sh &
    fi

    # check irot or idet and remove aeblsys
    if [ -f "${IHDN_TEST}" ] ||  [ -f "${IHDN_SYS}" ] || [ -f "${IHDN_DET}" ]; then
        rm /home/pi/.aeblsys
    fi

    # As of 141007 ihdn_tests.sh not standard run by detector, so run here
    # if  [ -f "${IHDN_DET}" ]; then
    #     $T_SCR/./ihdn_tests.sh
    # fi

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

    # temp check
    # log host $HOME dirctory

    # echo "Current home directory" >> log.txt
    # echo $(date +"%T") >> log.txt
    # ls -al >> log.txt

    # echo "Current pl directory" >> log.txt
    # echo $(date +"%T") >> log.txt
    # ls -al pl >> log.txt

    killall dbus-daemon

    if [ ! -f "${OFFLINE_SYS}" ]; then
        if [ -f "${LOCAL_SYS}" ]; then

            # don't get any more script updates from non-patch system

            #  Except!  Do want this one, as not all installs include this file
            wget -N -r -nd -l2 -w 3 -P $HOME/scripts --limit-rate=50k http://192.168.200.6/files/synfilz.sh

            cp $HOME/scripts/synfilz.sh $HOME/.scripts
            cp $HOME/scripts/synfilz.sh $T_SCR

            # Get playlists from local server
            if [ -f "${AEBL_TEST}" ]; then
                wget -N -r -nd -l2 -w 3 -O "${T_STO}/mynew.pl" --limit-rate=50k http://192.168.200.6/files/aebltest.pl
            fi

            if [ -f "${AEBL_SYS}" ]; then
                wget -N -r -nd -l2 -w 3 -O "${T_STO}/mynew.pl" --limit-rate=50k http://192.168.200.6/files/aebltest.pl
            fi

            if [ -f "${IHDN_TEST}" ]; then
                wget -N -r -nd -l2 -w 3 -O "${T_STO}/mynew.pl" --limit-rate=50k http://192.168.200.6/files/ihdntest.pl
            fi

            if [ -f "${HOME}/.ihdnfol-1" ]; then
                wget -N -r -nd -l2 -w 3 -o "${T_STO}/mynew.pl" --limit-rate=50k http://192.168.200.6/files/ihdntest.pl
            fi

            if [ -f "${HOME}/.ihdnfol-2" ]; then
                wget -N -r -nd -l2 -w 3 -o "${T_STO}/mynew.pl" --limit-rate=50k http://192.168.200.6/files/idettest.pl
            fi

        else

            echo "no further realtime updates for non-local systems"

            # but DO get playlists
            if [ -f "${HOME}/.ihdnfol25" ]; then
                curl -o "${T_STO}/mynew.pl" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000025/chan25.pl"
            fi

            if [ -f "${HOME}/.ihdnfol26" ]; then
                curl -o "${T_STO}/mynew.pl" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000026/chan26.pl"
            fi

            if [ -f "${HOME}/.ihdnfol27" ]; then
                curl -o "${T_STO}/mynew.pl" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000027/chan27.pl"
            fi

            if [ -f "${HOME}/.ihdnfol28" ]; then
                curl -o "${T_STO}/mynew.pl" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000028/chan28.pl"
            fi

            if [ -f "${HOME}/.ihdnfol100" ]; then
                curl -o "${T_STO}/mynew.pl" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/0000100/chan100.pl"
            fi

            if [ -f "${HOME}/.ihdnfol101" ]; then
                curl -o "${T_STO}/mynew.pl" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/0000101/chan101.pl"
            fi

        fi

        chmod 777 $T_SCR/synfilz.sh
        chmod 777 $HOME/scripts/synfilz.sh
        chmod 777 $HOME/.scripts/synfilz.sh

        $T_SCR/./synfilz.sh &

        if [ ! -f "${HOME}/.getchan" ]; then
            $T_SCR/./grbchan.sh &
        fi

    fi

    if [ ! -f "${OFFLINE_SYS}" ] && [ ! -f "${HOME}/.patched_too" ]; then
        rm $HOME/.ap009*
        rm $HOME/.patched
    fi

    # this needs to stay!  to ensure that systems are good to patch
    if [ ! -f "${OFFLINE_SYS}" ] && [ ! -f "${HOME}/.patched" ]; then
        if [ -f "${LOCAL_SYS}" ]; then
            wget -N -nd -w 3 -P ${HOME}/.scripts --limit-rate=50k http://192.168.200.6/files/patch.sh
        else
            wget -N -nd -w 3 -P ${HOME}/.scripts --limit-rate=50k "https://www.dropbox.com/s/vznou2g9dxc74lm/patch.sh"
        fi
        chmod 777 $HOME/.scripts/patch.sh
        cp $HOME/.scripts/patch.sh $T_SCR
        cp $HOME/.scripts/patch.sh $HOME/.scripts

        $T_SCR/./patch.sh &

        touch $HOME/.patched
        touch $HOME/.patched_too
    fi

    /* What follows is the original source from the synfilz.sh app  */

    FIRST_RUN_DONE="/home/pi/.firstrundone"
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

    NOTHING_NEW="${T_STO}/.nonew"
    NEW_PL="${T_STO}/.newpl"

    MACe0=$(ip link show eth0 | awk '/ether/ {print $2}')

    cd $HOME

    if [ -f "${NETWORK_SYS}" ]; then

    #     rm $HOME/log.txt

    #     touch $HOME/log.txt

        rm $T_STO/test.log

        touch $T_STO/test.log

        echo "${MACe0}" >> $T_STO/test.log
        echo "$(date +"%y-%m-%d")" >> $T_STO/test.log
        echo "$(date +"%T")" >> $T_STO/test.log

    fi

    if [ "${MACe0}" == 'b8:27:eb:a7:23:94' ] && [ -f "${HOME}/.rblt" ]; then

#         touch $HOME/.rblt

        rm $HOME/.rblt

        sudo reboot

    fi

    if [ -f "${AEBL_TEST}" ] || [ -f "${AEBL_SYS}" ]; then
    #     echo "Check if MAC is ending :5a" >> log.txt
        echo "MAC Address is created as: $MACe0"
    #     echo $(date +"%T") >> log.txt
        if [ "${MACe0}" == 'b8:27:eb:37:07:5a' ] && [ -f "${AEBL_SYS}" ]; then
    #         echo "MAC is ending :5a and has .aeblsys but should not, so removing .aeblsys and .aeblsys_test." >> log.txt
            rm .aeblsys
            rm .aeblsys_test
        fi
    fi

    if [ -f "${AEBL_TEST}" ] || [ -f "${AEBL_SYS}" ]; then
        echo "Running sync filz."
    #     echo "Running sync filz." >> log.txt
    #     echo $(date +"%T") >> log.txt
    fi

    if [ -f "${AEBL_TEST}" ] || [ -f "${AEBL_SYS}" ]; then
    #     echo "!*******************!" >> log.txt
        echo "Posting log"
    #     echo "Posting log" >> log.txt
    #     echo $(date +"%T") >> log.txt
    #     echo "!*******************!" >> log.txt

    fi

    # Check network before syncing
    if [ -f "${LOCAL_SYS}" ]; then
        rm index*
        echo "Online"

        # Check if not syncing
        # should append syncing to syncing file and dump it to dropbox

        if [ ! -f "${T_STO}/syncing" ]; then
    #         echo "Currently not syncing." >> log.txt
    #         echo "Making running token."  >> log.txt
    #         echo $(date +"%T") >> log.txt

            touch "${T_STO}/syncing"

    #         wget -N -nd -w 3 -P $HOME/scripts --limit-rate=50k http://192.168.200.6/files/getupdt.sh

    #         chmod 777 $HOME/scripts/getupdt.sh

    #         cp $HOME/scripts/getupdt.sh $T_SCR

    #         wget -N -nd -w 3 -P $HOME/scripts --limit-rate=50k http://192.168.200.6/files/ctrlwtch.sh

    #         chmod 777 $HOME/scripts/ctrlwtch.sh

    #         [ $file1 -ot $file2 ]

            if [ "scripts/ctrlwtch.sh" -nt "/run/shm/scripts/ctrlwtch.sh" ]; then
                touch $HOME/ctrl/.newctrl
            fi

            cp $HOME/scripts/ctrlwtch.sh $HOME/.scripts
            cp $HOME/scripts/ctrlwtch.sh $T_SCR

    #         wget -N -nd -w 3 -P $HOME/scripts --limit-rate=50k http://192.168.200.6/files/process_playlist.sh

    #         chmod 777 $HOME/scripts/process_playlist.sh

    #         cp $HOME/scripts/process_playlist.sh $T_SCR

    #         wget -N -nd -w 3 -P $HOME/scripts --limit-rate=50k http://192.168.200.6/files/grabfiles.sh

    #         chmod 777 $HOME/scripts/grabfiles.sh

    #         cp $HOME/scripts/grabfiles.sh $T_SCR

    #         $T_SCR/./grabfiles.sh

            if [ -f "${AEBL_TEST}" ] || [ -f "${AEBL_SYS}" ]; then
                wget -N -nd -w 3 -P $T_STO --limit-rate=50k http://192.168.200.6/files/aebl.m3u

                rm $T_STO/synfil

                cp $T_STO/aebl.m3u $T_STO/synfil

                rm $T_STO/aebl.m3u

                GRAB_FILE="${T_STO}/synfil"

            fi

    #         if [ -f "${IHDN_TEST}" ]; then
    #             wget -N -nd -w 3 -P $T_STO --limit-rate=50k http://192.168.200.6/files/ihdn.m3u
    #             cp $T_STO/ihdn.m3u $T_STO/synfil
    #             rm $T_STO/ihdn.m3u
    #         fi

            x=1

            if [ ! -d "tmp" ]; then
                mkdir tmp
            fi

    #         if  [ -f "${AEBL_TEST}" ] || [ -f "${AEBL_SYS}" ] || [ -f "${IHDN_TEST}" ]; then
            if  [ -f "${AEBL_TEST}" ] || [ -f "${AEBL_SYS}" ]; then
                while [ $x == 1 ]; do
                    # Sleep so it's possible to kill this
            #         sleep 1

                    # check file doesn't exist
                    if [ ! -f "${GRAB_FILE}" ]; then
                        echo "Playlist file ${GRAB_FILE} not found"
                        continue
                    fi
    
                    # Get the top of the playlist
                    cont=$(cat "${GRAB_FILE}" | head -n1)
    
                    # And strip it off the playlist file
                    cat "${GRAB_FILE}" | tail -n+2 > "${GRAB_FILE}.new"
                    mv "${GRAB_FILE}.new" "${GRAB_FILE}"

                    # Skip if this is empty
                    if [ -z "${cont}" ]; then
                        echo "Playlist empty or bumped into an empty entry for some reason"

                        # added by Kevin: exit clean if empty
                        x=0

    #                    continue

                    fi

                    # Check that the file exists
            #         if [ ! -f "${cont}" ]; then
            #                 echo "Playlist entry ${cont} not found"
            #                 continue
            #         fi

                    clear
                    echo
                    echo "Getting ${cont} ..."
                    echo

                    if [ ! -f "$HOME/mp4/${cont}" ]; then
            #         "${PLAYER}" ${PLAYER_OPTIONS} "${cont}" > /dev/null
                        wget -N -nd -w 3 -P ${TEMP_DIR} --limit-rate=50k "http://192.168.200.6/files/mp4/${cont}"
                        mv "${TEMP_DIR}/${cont}" $HOME/mp4
                    fi

                    echo
                    echo "File complete, continuing to next item."
                    echo

                done
                rm ${GRAB_FILE}
            fi

    # possible method for creating new playlist
    # find "$(pwd)/aud" -maxdepth 1 -type f

    #         wget -r -nd -nc -l 2 -w 3 -A mp4 -P $HOME/mp4 http://192.168.200.6/files/

    #         wget -r -nd -nc -l 2 -w 3 -A mp3 -P $HOME/aud http://192.168.200.6/files/

    #         echo "Done syncing." >> log.txt
    #         echo "Removing running token."  >> log.txt
    #         echo $(date +"%T") >> log.txt
            rm "${T_STO}/syncing"

        # Else do nothing files
        #    else
        #        echo "Already syncing!"
        fi

        if [ -f "${AEBL_TEST}" ] || [ -f "${AEBL_SYS}" ]; then
    #         echo "Done sync filz." >> log.txt
    #         echo $(date +"%T") >> log.txt
        fi

    fi

    # Check network before syncing
    # if [ -f "${HOME}/.ihdnfol26" ] && [ ! -f "${OFFLINE_SYS}" ]; then
    #     rm index*

        # Check if not syncing
        # should append syncing to syncing file and dump it to dropbox

    #     if [ ! -f "${T_STO}/syncing" ]; then
    #         echo "Currently not syncing." >> log.txt
    #         echo "Making running token."  >> log.txt
    #         echo $(date +"%T") >> log.txt

    #         touch "${T_STO}/syncing"

    #         rm $T_STO/mychan

    #         curl -o "$T_STO/chan26.m3u" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000026/chan26.m3u"

    #         cp $T_STO/chan26.m3u $T_STO/mychan

    #         rm $T_STO/chan26.m3u

    #         wget -N -nd -w 3 -P $HOME/scripts --limit-rate=50k "https://www.dropbox.com/s/vtm7naqg4sbq2wh/ihdn_tests.sh"

    #         GRAB_FILE="${T_STO}/mychan"

    #         x=1

    #         if [ ! -d "tmp" ]; then
    #             mkdir tmp
    #         fi

    #         while [ $x == 1 ]; do
                # Sleep so it's possible to kill this
        #         sleep 1

                # check file doesn't exist
    #             if [ ! -f "${GRAB_FILE}" ]; then
    #                 echo "Playlist file ${GRAB_FILE} not found"
    #                 continue
    #             fi
    
                # Get the top of the playlist
    #             cont=$(cat "${GRAB_FILE}" | head -n1)
    
                # And strip it off the playlist file
    #             cat "${GRAB_FILE}" | tail -n+2 > "${GRAB_FILE}.new"
    #             mv "${GRAB_FILE}.new" "${GRAB_FILE}"

                # Skip if this is empty
    #             if [ -z "${cont}" ]; then
    #                 echo "Playlist empty or bumped into an empty entry for some reason"

                    # added by Kevin: exit clean if empty
    #                 x=0

    #                 continue

    #             fi

                # Check that the file exists
        #         if [ ! -f "${cont}" ]; then
        #                 echo "Playlist entry ${cont} not found"
        #                 continue
        #         fi

    #             clear
    #             echo
    #             echo "Getting ${cont} ..."
    #             echo
    #             if [ ! -f "$HOME/mp4/${cont}" ]; then

        #         "${PLAYER}" ${PLAYER_OPTIONS} "${cont}" > /dev/null
    #                 curl -z "$HOME/mp4/${cont}" -o "${TEMP_DIR}/${cont}" -k -u videouser:password "sftp://184.71.76.158:8022/home/videouser/videos/000026/${cont}"
    #                 mv "${TEMP_DIR}/${cont}" $HOME/mp4
    #             fi

    #             echo
    #             echo "File complete, continuing to next item."
    #             echo

    #         done
    #         rm ${GRAB_FILE}
    #     fi

    # possible method for creating new playlist
    # find "$(pwd)/aud" -maxdepth 1 -type f

    #         wget -r -nd -nc -l 2 -w 3 -A mp4 -P $HOME/mp4 http://192.168.200.6/files/

    #         wget -r -nd -nc -l 2 -w 3 -A mp3 -P $HOME/aud http://192.168.200.6/files/

    #     echo "Done syncing." >> log.txt
    #     echo "Removing running token."  >> log.txt
    #     echo $(date +"%T") >> log.txt
    #     rm "${T_STO}/syncing"

    # Else do nothing files
    #    else
    #        echo "Already syncing!"
    # fi

}

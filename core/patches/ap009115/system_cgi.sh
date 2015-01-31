#!/bin/bash
#
# Provides system information and management functions
#
# Copyright (C) 2015 Uvea I. S., Kevin Rattai
# BSD license https://raw.githubusercontent.com/krattai/AEBL/master/LICENSE
#

echo "Content-type: text/html"

AEBL_TEST="/home/pi/.aebltest"
AEBL_SYS="/home/pi/.aeblsys"
TEMP_DIR="/home/pi/tmp"
IHDN_TEST="/home/pi/.ihdntest"
IHDN_SYS="/home/pi/.ihdnsys"
IHDN_DET="/home/pi/.ihdndet"

T_STO="/run/shm"
T_SCR="/run/shm/scripts"

LOCAL_SYS="${T_STO}/.local"
NETWORK_SYS="${T_STO}/.network"
OFFLINE_SYS="${T_STO}/.offline"

echo ""

echo '<html>'
echo ""
echo '<head>'
echo '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">'
echo '<link rel="SHORTCUT ICON" href="http://www.megacorp.com/favicon.ico">'
echo '<link rel="stylesheet" href="http://www.megacorp.com/style.css" type="text/css">'

PATH="/bin:/usr/bin:/usr/ucb:/usr/opt/bin"
export $PATH

echo '<title>Set ping information</title>'
echo '</head>'
echo ""
echo '<body>'
echo '<h3>'
hostname
echo '</h3>'

uptime

echo '<br><br>'
echo 'setting ping information'
echo '<br><br>'

# Check if should respond
# if so:
# + hostname
# + cat chan
# + uptime

# always ping on these
hostname > ping.txt
echo $(date +"%T") >> ping.txt
cat chan >> ping.txt
uptime >> ping.txt

cat ping.txt

mv ping.txt /home/pi/ping_cgi.txt

echo '<br><br>'
echo '<a href="../index.html">Home</a>'
echo '</body>'
echo ""
echo '</html>'

exit 0

#!/bin/bash
#
# displays .config file
#
# Copyright (C) 2015 Uvea I. S., Kevin Rattai
# BSD license https://raw.githubusercontent.com/krattai/AEBL/master/LICENSE
#

echo "Content-type: text/html"
echo ""

echo '<html>'
echo '<head>'
echo '<meta http-equiv="Content-Type" content="text/html; charset=UTF-8">'
echo '<link rel="SHORTCUT ICON" href="http://www.megacorp.com/favicon.ico">'
echo '<link rel="stylesheet" href="http://www.megacorp.com/style.css" type="text/css">'

PATH="/bin:/usr/bin:/usr/ucb:/usr/opt/bin"
export $PATH

echo '<title>Configuration File Contents</title>'
echo '</head>'
echo '<body>'

echo '<h3>'
hostname
echo '</h3>'

uptime

echo '<br><br>'
cat /home/pi/.config

echo '<br><br>'
echo '<a href="../index.html">Home</a>'
echo '</body>'
echo '</html>'

exit 0


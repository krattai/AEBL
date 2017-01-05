#!/bin/sh
# This script should auto pub content from flat file
# Copyright (C) 2017 Uvea I. S., Kevin Rattai
#
# Runs as cron job, will post one item per day at this time, with more possible in future
#
# cron as:
# 0     14     *     *     * /home/kevin/scripts/cronpub.sh
#
# Use AEBL playlist.sh and process_playlist.sh for example code
#  to process files

# TEMP_DIR="/home/user/tmp"
CONT_DIR="/home/kevin/content"

# PLAYLIST="${T_STO}/.playlist"
CONTENT="${CONT_DIR}/.soc_content"

# Get the top of the playlist
pub=$(cat "${CONTENT}" | head -n1)

# And strip it off the playlist file
cat "${CONTENT}" | tail -n+2 > "${CONTENT}.new"
mv "${CONTENT}.new" "${CONTENT}"

mosquitto_pub -d -t aebl/social -m "$pub" -h "ihdn.ca"

# Append pub to end of content
echo "$pub" >> "${CONTENT}"

exit 0

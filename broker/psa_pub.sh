#!/bin/sh
# This script should auto ad content from flat file
# Copyright (C) 2017 Uvea I. S., Kevin Rattai
#
# Runs as cron job, scheduled according to desired frequency

#
# Use AEBL playlist.sh and process_playlist.sh for example code
#  to process files

# TEMP_DIR="/home/user/tmp"
CONT_DIR="/home/kevin/content"

# PLAYLIST="${T_STO}/.playlist"
CONTENT="${CONT_DIR}/.psa_content"

# PLAYLIST="${T_STO}/.playlist"
PLAYED="${CONT_DIR}/.psa_played"

# Get the top of the playlist
pub=$(cat "${CONTENT}" | head -n1)

# And strip it off the playlist file
cat "${CONTENT}" | tail -n+2 > "${CONTENT}.new"
mv "${CONTENT}.new" "${CONTENT}"

mosquitto_pub -d -t aebl/social -m "$pub" -h "ihdn.ca"

# Append pub to old content
echo "$pub" >> "${PLAYED}"

exit 0

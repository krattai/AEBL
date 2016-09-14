#!/bin/sh
# This script should auto pub content from flat file
# Copyright (C) 2016 Uvea I. S., Kevin Rattai
#
# Runs as cron job, should post one item per day

#
# Use AEBL playlist.sh and process_playlist.sh for example code
#  to process files

# 160914 - appears to post multiple times, or at least twice
#        - the link appears to suggest this is a buffer.com reason
#        - found iftt recipe connected to buffer.com, turned it off

# TEMP_DIR="/home/user/tmp"
CONT_DIR="/home/ihdn/content"

# PLAYLIST="${T_STO}/.playlist"
CONTENT="${CONT_DIR}/.soc_content"

# PLAYLIST="${T_STO}/.playlist"
PLAYED="${CONT_DIR}/.soc_played"

# Get the top of the playlist
pub=$(cat "${CONTENT}" | head -n1)

# And strip it off the playlist file
cat "${CONTENT}" | tail -n+2 > "${CONTENT}.new"
mv "${CONTENT}.new" "${CONTENT}"

mosquitto_pub -d -t aebl/social -m "$pub" -h "ihdn.ca"

# Append pub to old content
echo "$pub" >> "${PLAYED}"

exit 0

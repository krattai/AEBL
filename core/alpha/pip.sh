#!/bin/sh
# This script should auto pub content from flat file
# Copyright (C) 2016 Uvea I. S., Kevin Rattai
#
# Plays pip (Picture In Picture)
#
# Audio should be off for these inserts.
#

mkfifo fifo
chmod 777 fifo
omxplayer --layer 2 --win "475 300 650 400" "mp4/Revolution OS.mp4" <fifo&
echo -n "." > fifo







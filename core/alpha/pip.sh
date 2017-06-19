#!/bin/sh
# This script should auto pub content from flat file
# Copyright (C) 2016 - 2017 Uvea I. S., Kevin Rattai
#
# Plays pip (Picture In Picture)
#
# Audio should be off for these inserts.
#

mkfifo fifo
chmod 777 fifo
# not sure if important, but should probably set audio volume for pip to some form of near, if not, zero
omxplayer --layer 2 --win "475 300 650 400" "mp4/Revolution OS.mp4" <fifo&
echo -n "." > fifo







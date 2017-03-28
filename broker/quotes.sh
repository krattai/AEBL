#!/bin/bash
# adds motd / fortune to file
#
# Copyright (C) 2017 Uvea I. S., Kevin Rattai
#
# requires installation of:
#   fortune-mod fortunes

CONT_DIR="/home/kevin/content"

CONTENT="${CONT_DIR}/.psa_content"

cd $HOME

endloop=0

while [ $endloop -lt 1 ]
do
   fort=$(fortune)
   if [ ${#fort} -lt 143 ]; then
      echo "$fort #am2p" | tr -d '\n' >> "${CONTENT}"
      sed -i -e '$a\' ${CONTENT}
      endloop=1
   fi
done

exit 0


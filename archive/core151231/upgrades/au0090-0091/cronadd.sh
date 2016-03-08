#!/bin/bash

# create crontab for user
#
# file modified from public presented code located at:
#
# http://www.unix.com/302331701-post2.html?s=0c45a137246ebab57440b5631c69ba15
#
# and
#
# http://stackoverflow.com/a/878647
#
# Eventually, it would be nice to have this script create
# log or file to indicate that it completed successfully
# this would be the last command before a the script exits
# on a success rather than a fail exit

USER=`whoami`
CRONLOC=/var/spool/cron/crontabs
# CRONCOMMFILE=/tmp/cron_comm_file.sh
CRONCOMMFILE="${HOME}/testcron.sh"
CRONGREP=$(crontab -l | cat )

# echo "I am ${USER}. Hello, world!"

# echo "echo CRONGREP"
# echo "${CRONGREP}"

if [ "$CRONGREP" != "" ]; then
  echo "Crontab already exists"

# use below to add to existing crontab

#   cat mycron  > $CRONCOMMFILE
#   crontab -l >> $CRONCOMMFILE
#   crontab "${CRONCOMMFILE}"
#   rm $CRONCOMMFILE

  crontab -l > $CRONCOMMFILE
  cat patch.ctab >> $CRONCOMMFILE
  cat upgrade.ctab >> $CRONCOMMFILE

  crontab "${CRONCOMMFILE}"
  rm $CRONCOMMFILE

  exit 
fi

# example of what should work

# #write out current crontab
# crontab -l > mycron
# #echo new cron into cron file
# echo "00 09 * * 1-5 echo hello" >> mycron
# #install new cron file
# crontab mycron
# rm mycron

#
# Create command file to create crontab file
#
# If command files already exists delete it

if [ -f "${CRONCOMMFILE}" ]; then
  rm -f "${CRONCOMMFILE}"
fi

# CRONLINE="0 9 * * 1,3,5 /var/tmp/sys_diag -l -a -o `hostname` -C"
# CRONLINE2="5 9 * * * /var/tmp/clean"
CRONLINE3="*/15 * * * * /home/pi/scripts/inetup.sh"

#
# Added commands into the file to create the crontab entry
#

# echo "#!/bin/sh" >> $CRONCOMMFILE
# echo "EDITOR=ed" >> $CRONCOMMFILE
# echo "export EDITOR" >> $CRONCOMMFILE


# echo "crontab -e $USER << EOF > /dev/null" >> $CRONCOMMFILE
# echo "a" >> $CRONCOMMFILE
# echo "$CRONLINE" >> $CRONCOMMFILE
# echo "$CRONLINE2" >> $CRONCOMMFILE
echo "$CRONLINE3" >> $CRONCOMMFILE
# echo "." >> $CRONCOMMFILE
# echo "w" >> $CRONCOMMFILE
# echo "q" >> $CRONCOMMFILE
# echo "EOF" >> $CRONCOMMFILE

# chmod 750 $CRONCOMMFILE

#
# Execute the the crontab command file
#

echo "echo CRONCOMMFILE"
echo " "
cat "${CRONCOMMFILE}"

if [ -f $CRONCOMMFILE ]; then
  crontab "${CRONCOMMFILE}"
  rm $CRONCOMMFILE
else
  echo "Error: File generated to create crontab entry does not exist"
  exit 1
fi

echo "Crontab Entry Inserted Successfully"
#
exit

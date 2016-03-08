#!/bin/bash

# remove items from crontab for user
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
#
# Perhaps better, there is the following script from:
# http://stackoverflow.com/a/17600721
#
#!/bin/sh
#
# Usage: 
# 1. Put this script somewhere in your project
# 2. Edit "$0".crontab file, it should look like this, 
#    but without the # in front of the lines
#0  *   *   *   *   stuff_you_want_to_do
#15 */5 *   *   *   stuff_you_want_to_do
#*  *   1,2 *   *   and_so_on
# 3. To install the crontab, simply run the script
# 4. To remove the crontab, run ./crontab.sh --remove
# 
# 
# cd $(dirname "$0")
# 
# test "$1" = --remove && mode=remove || mode=add
# 
# cron_unique_label="# $PWD"
# 
# crontab="$0".crontab
# crontab_bak=$crontab.bak
# test -f $crontab || cp $crontab.sample $crontab
# 
# crontab_exists() {
#     crontab -l 2>/dev/null | grep -x "$cron_unique_label" >/dev/null 2>/dev/null
# }
# 
# if crontab is executable
# if type crontab >/dev/null 2>/dev/null; then
#     if test $mode = add; then
#         if ! crontab_exists; then
#             crontab -l > $crontab_bak
#             echo 'Appending to crontab:'
#             cat $crontab
#             crontab -l 2>/dev/null | { cat; echo; echo $cron_unique_label; cat $crontab; echo; } | crontab -
#         else
#             echo 'Crontab entry already exists, skipping ...'
#             echo
#         fi
#         echo "To remove previously added crontab entry, run: $0 --remove"
#         echo
#     elif test $mode = remove; then
#         if crontab_exists; then
#             echo Removing crontab entry ...
#             crontab -l 2>/dev/null | sed -e "\?^$cron_unique_label\$?,/^\$/ d" | crontab -
#         else
#             echo Crontab entry does not exist, nothing to do.
#         fi
#     fi
# fi
#

USER=`whoami`
CRONLOC=/var/spool/cron/crontabs
# CRONCOMMFILE=/tmp/cron_comm_file.sh
CRONCOMMFILE="${HOME}/testcron.sh"
CRONGREP=$(crontab -l | cat )

# echo "I am ${USER}. Hello, world!"

# echo "echo CRONGREP"
# echo "${CRONGREP}"

# remember, this script is modified from cronadd, so edit accordingly
#
# To remove

sudo sed -i '/\*\/3 \* \* \* \* \/run\/shm\/scripts\/l-ctrl.sh/ d' /var/spool/cron/crontabs/pi

sudo sed -i '/\*\/15 \* \* \* \* \/run\/shm\/scripts\/inetup.sh/ d' /var/spool/cron/crontabs/pi

sudo sed -i '/\*\/3 \* \* \* \* \/home\/pi\/scripts\/inetup.sh/ d' /var/spool/cron/crontabs/pi

sudo sed -i '/\*\/15 \* \* \* \* \/home\/pi\/scripts\/l-ctrl.sh/ d' /var/spool/cron/crontabs/pi

echo "Crontab Entry Removed Successfully"
#
exit

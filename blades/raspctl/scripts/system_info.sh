#!/bin/bash

# This script is meant for recolecting all the information of the system that
# will be displayed in the RaspCTL dashboard. The decision of creating a bash
# script instead of do the same job in Python is the simplicity of it. This
# command will be executed with the STDERR redirected to devnull(2>/dev/null)
# The valueable information must be printed to the STDOUT with the format:
#        NAME_OF_CONSTANT:{value}
# important to note that the colons are required and every metric must be
# expressed # just _ONE_ line. That's why I'm using "echo -n" because when
# printing the key I don't want a \n charater inserted at the end of the
# string. If you want to add more metrics, just take anotherone as example.

# Important note. Is is possible that if you delete some metric from here that
# is used in the dashboard, the dashboard will return a HTTP 500 code because
# it will not find the deleted item. Please when deleting items from this script
# check that you delete it from the dashboard template too. Having metrics that
# are not being used do not harm to anybody, so they can be left here.
# Important note2: In my RaspPI this command is executed in 550 milli seconds,
# try to keep this time as lower as you can. This will prevent the dashboard to
# take ages to load. The execution time must be always lower than a second, keep
# this in mind.


# Just in case you have color options for GREP command
export GREP_OPTIONS='--color=none'


echo -n "HOSTNAME:"
hostname

echo -n "IP_ADDRESS:"
/sbin/ifconfig  | egrep "addr:([0-9]+\.[0-9]+\.[0-9]+\.[0-9]+)" -ho | egrep -v "(127|169)" | head -1 | cut -d":" -f2

echo -n "MEMORY_TOTAL:"
total=$(cat /proc/meminfo | grep MemTotal | egrep [0-9]+ -ho)
echo $total

echo -n "USED_MEMORY:"
used=$(cat /proc/meminfo | grep "Active:" | egrep [0-9]+ -ho)
echo $used

free=$(($total-$used))
echo -n "FREE_MEMORY:"
echo $free

echo -n "DISK_TOTAL:"
echo $(df | awk '{if ($6 ~ /^\/$/) print }' | head -1 | awk '{print $2}')

echo -n "DISK_USED:"
echo $(df | awk '{if ($6 ~ /^\/$/) print }' | head -1 | awk '{print $3}')

echo -n "DISK_FREE:"
echo $(df | awk '{if ($6 ~ /^\/$/) print }' | head -1 | awk '{print $4}')

echo -n "UPTIME:"
echo $(uptime  | awk '{print $3}' | tr -d ',')

echo -n "LOAD_AVG:"
echo $(cat /proc/loadavg | awk '{print $1, $2, $3}')

echo -n "PROCESSOR_NAME:"
echo $(cat /proc/cpuinfo | awk -F":" '/model name/{print $2}' | head -1)

echo -n "PROCESSOR_NAME2:"
echo $(cat /proc/cpuinfo | awk -F ":" '/Processor/{print $2}')

echo -n "PROCESSOR_BOGOMITS:"
echo $(cat /proc/cpuinfo  | grep -i "bogomips" | head -1 | egrep ":.*$" -ho | tr -d ":")

echo -n "PROCESSOR_CURRENT_SPEED:"
echo $(cat /sys/devices/system/cpu/cpu0/cpufreq/scaling_cur_freq)

echo -n "PROCESSOR_OVERLOCK:"
echo $(cat /boot/config.txt | grep arm_freq | egrep  [0-9]+ -ho)

echo -n "TOP_PROCESSES:"
echo $(ps axo pcpu,pid,comm | awk '{print $1, $2, $3}'  | sort -nr | head -n 6 | tr "\n" "#")

echo -n "TOP_MEMORY:"
echo $(ps axo %mem,pid,comm | awk '{print $1, $2, $3}' | sort -nr | head -6 | tr "\n" "#") 

echo -n "TEMPERATURE:"
echo $(vcgencmd measure_temp | egrep "[0-9.]*" -o)

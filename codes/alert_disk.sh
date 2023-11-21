#!/bin/bash 

################################################
# Author: Matheus Bernardello                  #
# Date: 04/11/2023                             #
# Description: Script to check disk usage      #
# Usage: ./alert_disk.sh                       #
################################################

# Email configuration
. src/email_config.sh
# Remember to put your email and password in the email_config.sh file and take off the .example extension

# Let's set the limit of we want to alert on
limit_disk=80 # 80% of usage is the limit
# Let's get the current usage of the disk
current_usage=$(df -h | grep /dev/sda4 | awk '{print $5}' | sed 's/%//g') # 5th column of the df -h command, remove the % sign, btw will show just the /dev/sda4 partition 

# Let's check if the current usage is greater than the limit
if [ $current_usage -gt $limit_disk ]; then
    echo "The disk is above 80% usage"
    sendemail -f "$from" -t "$to" -u "$subject" -m "$message" -s "$server" -xu "$from" -xp "$password"
else
    echo "The disk is ok"
fi

#!/bin/bash 

################################################
# Author: Matheus Bernardello                  #
# Date: 04/11/2023                             #
# Description: Script to check disk usage      #
# Usage: ./alert_disk.sh                       #
################################################

# Let's set the limit of we want to alert on
limit_disk=80 # 80% of usage is the limit
# Let's get the current usage of the disk
current_usage=$(df -h | grep /dev/sda1 | awk '{print $5}' | sed 's/%//g') 

# Let's check if the current usage is greater than the limit
if [[ $current_usage -gt $limit_disk ]] ; then
    #echo "The disk is above '$limit_disk'% usage"
    echo "Alerta: uso de disco acima de '$limit_disk'%" #Python code will look for this message, thats the reason to keep it in portuguese
fi

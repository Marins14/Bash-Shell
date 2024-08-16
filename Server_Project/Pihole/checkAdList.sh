#!/bin/bash

#####################################################################
# Server Project | Validate Pihole Lists                            #
#####################################################################
# Author: Matheus Marins                                            #
# Date: 16/08/2024                                                  #
# Version: 1.0                                                      #
# Description: This script is  going to check the adlists			#
# Test: Ubuntu 22.04 LTS  Bash version: 5.1.16                      #
#####################################################################
# In case of error or doubt, please contact the author.             #
#####################################################################

logFile="yourPath/checkAdList.log"

# Checking the pihole installation
if ! command -v pihole &> /dev/null; then
    echo "Pi-hole is not installed or is not working, check!" >> $logFile
    exit 1
fi 

# Getting the adlists from the database
adLists=$(sqlite3 /etc/pihole/gravity.db "SELECT id, address FROM adlist;")

checkAdList() {
    while IFS=| read -r id url; do
        echo "Checking $url"
        if ! curl -Is "$url" | head -n1 | grep "200\|301\|302" > /dev/null; then
            echo "Adlist $url is outdated! Removing from the database"
            sqlite3 /etc/pihole/gravity.db "DELETE FROM adlist WHERE id=$id;"
        else
            echo "Adlist $url is OK!"
        fi
    done <<< "$adLists"
} >> $logFile 2>&1

updateGravity() {
    echo "Updating gravity..."
    pihole -g
} >> $logFile 2>&1

# Calling the functions
checkAdList
updateGravity

echo "Script Completed!" >> $logFile


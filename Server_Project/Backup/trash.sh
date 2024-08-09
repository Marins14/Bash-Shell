#!/bin/bash

#####################################################################
# Server Project | Trash Backup log                                 #
#####################################################################
# Author: Matheus Marins                                            #
# Date: 04/07/2024                                                  #
# Version: 1.0                                                      #
# Description: This script is  going to clean the logs +5 days      #
# Use: ./trash.sh; If clone the repo, run: chmod +x trash.sh        #
# Test: Ubuntu 22.04 LTS  Bash version: 5.1.16                      #
#####################################################################
# In case of error or doubt, please contact the author.             #
#####################################################################

#Colors the message
red='\033[31m'
green='\033[32m'
yellow='\033[33m'


# Variables - this can be changed according to your needs
date=$(date +%d-%m-%Y-%H:%M)
log_path="/home/matheus/Documentos/Bin/Backup_Cadenciado/backup_logs/"
log_file="/home/matheus/Documentos/Bin/Backup_Cadenciado/trash_logs/trash_$date.log"

# Verify if is root user, in negative case, the script will be interrupted. If you don't need to be root, just comment the condition bellow.
if [ $(id -u) != "1000" ];then
    echo -e "$red[ERROR] ----- You must be the root user to run this script.-----  [ERROR] \e[m"
    echo "User detected: $(whoami) at $date is trying to run the script. Please, run the script as root user." >> $log_file
    exit 1
fi

# Verify is the backup_log exists
verify_log(){
    if [ -d $log_path ];then
        echo -e "$green[INFO] ----- Backup log found ----- [INFO] \e[m"
        echo -e "$yellow[INFO] ----- Cleaning the logs ----- [INFO] \e[m"
        find $log_path -name "backup_*.log" -mtime +5 -exec rm -f {} \; # Remove the logs older than 5 days, -f force the removal, you can change the number of days according to your needs
        echo -e "$green[INFO] ----- Logs cleaned successfully ----- [INFO] \e[m"
    else
        echo -e "$red[ERROR] ----- Backup log not found ----- [ERROR] \e[m"
    fi
} >> $log_file 2>&1

main(){
    echo -e "$yellow[INFO]----- Trash started at: $(date +%d-%m-%Y-%H-%M) -----[INFO] \e[m" >> $log_file
    verify_log
    echo -e "$yellow[INFO]----- Trash finished at: $(date +%d-%m-%Y-%H-%M) -----[INFO] \e[m" >> $log_file
}

#############################################################################
# Execution of the script
#############################################################################
main
#############################################################################

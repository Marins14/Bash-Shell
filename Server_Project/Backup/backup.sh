#!/bin/bash

#####################################################################
# Server Project | Backup                                           #
#####################################################################
# Author: Matheus Marins                                            #
# Date: 14/06/2024                                                  #
# Version: 1.0                                                      #
# Description: This script is  going to make a incremental backup   #
# Use: ./backup.sh; If clone the repo, run: chmod +x backup.sh      #
# Test: Ubuntu 22.04 LTS  Bash version: 5.1.16                      #
# Warning: This script needs to be run as root user and             #
# Don't forget to change the variables according to your needs      #
#####################################################################
# In case of error or doubt, please contact the author.             #
#####################################################################

#Colors the message 
red='\033[31m'
green='\033[32m'
yellow='\033[33m'

# Variables - this can be changed according to your needs
date=$(date +%d-%m-%Y-%H:%M)
dir_backup="/put/your/backup/path/here"
log_file="/put/your/backup/path/here/backup_$date.log"
origin_backup="/put/your/origin/path/here"

#Verify if is root user, in negative case, the script will be interrupted. If you don't need to be root, just comment the condition bellow.
if [ $(id -u) != "0" ];then
    echo -e "$red[ERROR] ----- You must be the root user to run this script.-----  [ERROR]"
    echo "User detected: $(whoami) at $date is trying to run the script. Please, run the script as root user." >> $log_file
    exit 1
fi

# Create backup
# rsync is a tool that allows you to copy files and directories locally or remotely, parameter -h human readable, -a archive mode, -v verbose, -P shows the progress of the transfer, -z compresses the data during the transfer
create_backup(){
    if rsync -havPz $origin_backup $dir_backup;then
        echo -e "$green[INFO] ----- Backup completed successfully ----- [INFO]"
    else
        echo -e "$red[ERROR] ----- Backup failed ----- [ERROR]" 
    fi 
} >> $log_file 2>&1


main(){
    echo -e "$yellow[INFO]----- Backup started at: $(date +%d-%m-%Y-%H-%M) -----[INFO]" >> $log_file
    create_backup
    echo -e "$yellow[INFO]----- Backup finished at: $(date +%d-%m-%Y-%H-%M) -----[INFO]" >> $log_file
}

#############################################################################
# Execution of the script
#############################################################################
main
#############################################################################
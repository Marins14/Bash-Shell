#!/bin/bash

#####################################################################
# Server Project | Backup                                           #
#####################################################################
# Author: Matheus Marins                                            #
# Date: 14/06/2024                                                  #
# Version: 1.0                                                      #
# Description: This script is  going to make a incremental backup   #
# Use: ./rotinaBackup.sh; If clone the repo,                        #
# run: chmod +x backup.sh                                           #
# Test: Ubuntu 22.04 LTS  Bash version: 5.1.16                      #
# Warning: This script needs to be run as root user and             #
# Don't forget to change the variables according to your needs      #
#####################################################################
# In case of error or doubt, please contact the author.             #
#####################################################################

#!/bin/bash

# Backup directory
backup_path="/your/backup/path"

# Directory where the backup will go
external_path="/your/external/path"

# File format
date_formated=$(date +%d-%m-%Y-%H-%M)
final_archive="backup_$date_formated.tar.gz"

# Logs
log_file="/your/log/path/backup.log"

#######################################
# Checks
#######################################
if [[ ! -d $external_path ]]; then
    printf "[ERROR]---- Destination directory does not exist $date_formated ----[ERROR]\n" >> $log_file
    exit 1
fi

#######################################
# Start the backup
#######################################
if tar -czf "$external_path/$final_archive" "$backup_path"; then
    printf "[INFO]---- Backup successfully created $date_formated ----[INFO]\n" >> $log_file
else
    printf "[ERROR]---- Error creating backup $date_formated ----[ERROR]\n" >> $log_file
fi

#######################################
# Deleting backups older than 10 days
#######################################
find $external_path -mtime +10 -delete

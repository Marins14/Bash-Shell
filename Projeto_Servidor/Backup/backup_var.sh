#!/bin/bash
# This script is used to backup all stuff that will be more than 80% of the disk space

# Variables
BACKUP_DIR="/arquivos/gestao/backup"
LOG_FILE="/var/log/backup_SO.log"
DATE=$(date +%Y-%m-%d)

# Check if the backup directory exists
if [ ! -d $BACKUP_DIR ]; then
    mkdir $BACKUP_DIR
fi

#Check if log file exists
if [ ! -f $LOG_FILE ]; then
    touch $LOG_FILE
fi

create_backup(){
    value=$(df -h | grep -i /var | awk '{ print $5 }' | sed 's/%//g')
    if [ $value -ge 80 ]; then
        echo "Backup directory: $BACKUP_DIR" 
        echo "Running backup at $(date)"
        echo "Backup date: $DATE" 
        echo "Disk space usage: $value%" 
        echo "Backup started at $(date)"
        tar -czf $BACKUP_DIR/backup-$DATE.tar.gz 
        echo "Backup finished at $(date)"
    fi
    
} >> $LOG_FILE 2>&1 

create_backup

# Check if the user is logging in via SSH
if [ -n "$SSH_CLIENT" ] || [ -n "$SSH_TTY" ]; then
    echo "Please take a look at the log => $LOG_FILE."
fi
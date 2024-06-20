#!/bin/bash

################################
# Projeto Servidor | Backup    #
################################
# Autor: Matheus Marins        #
# Data de criação: 14/06/2024  #
# Versão: 1.0                  #
################################

# Variables
#dir_backup="/arquivos/gestao/backup/"
dir_backup="/home/matheus/Documentos/Bash-Shell/Projeto_Servidor/Backup"
#log_file="/var/log/backup_SO.log"
log_file="/home/matheus/Documentos/backup_SO.log"
date=$(date +%d-%m-%Y-%H-%M)
origin_backup="/home/matheus/Documentos/Bin/Backup_Cadenciado/"
git_dir="/home/matheus/Documentos/Bash-Shell/"

# Check if the backup directory exists
if [ ! -d $dir_backup ]; then
    mkdir $dir_backup
fi

# Create backup
# rsync is a tool that allows you to copy files and directories locally or remotely, parameter -h human readable, -a archive mode, -v verbose, -P shows the progress of the transfer, -z compresses the data during the transfer
create_backup(){
    rsync -havPz $origin_backup $dir_backup 
} >> $log_file 2>&1


# Put the backup on github repository
repoConfig(){
    cd $git_dir
    git add .
    git commit -m "Backup $date"
    git push
} >> $log_file 2>&1

create_backup
repoConfig
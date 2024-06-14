#!/bin/bash

#========================================#
# Projeto Servidor                       #
#========================================#
# Script de backup de arquivos           #
# Autor: Matheus Marins                  #
# Data: 23/04/2024                       #
#========================================#

#Diretorio backup
backup_path="/var/lib/jellyfin/"

#Diretorio para onde o backup vai
external_path="/arquivos/gestao/backup/"

#Formato do arquivo
date_formated=$(date +%d-%m-%Y-%H-%M)
final_archive="backup_$date_formated.tar.gz"

#Logs
log_file="/var/log/backup.log" #colocar no /var/log

#######################################
# Verificacoes
#######################################
if [[ ! -d $external_path ]];then
    printf "[ERROR]---- Diretorio de destino nao existe $date_formated ----[ERROR]\n" >> $log_file
    exit 1
fi

#######################################
# Inicia o backup
#######################################
if tar -czf "$external_path/$final_archive" "$backup_path"; then
    printf "[INFO]---- Backup criado com sucesso $date_formated ----[INFO]\n" >> $log_file
else
    printf "[ERROR]---- Erro ao criar backup $date_formated ----[ERROR]\n" >> $log_file
fi

#######################################
# Excluindo backups com mais de 10 dias
#######################################
find $external_path -mtime +5 -delete


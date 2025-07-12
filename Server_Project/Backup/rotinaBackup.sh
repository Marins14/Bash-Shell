#!/bin/bash

#========================================#
# PandoraBox Rotina Backup               #
#========================================#
# Script de backup de arquivos           #
# Autor: Matheus Marins                  #
# Data: 23/04/2024                       #
# Att: 11/07/2025                        #
#========================================#

#Diretorios backup - Os que acho uteis! 
backup_path=("/var/lib/jellyfin/"
             "/etc/prometheus/"
             "/etc/alertmanager/"
             "/etc/grafana/"
             "/opt/OpenVpn/"
             "/opt/NextCloud/"
             "/opt/duckdns/")

#Diretorio para onde o backup vai
external_path="/arquivos/gestao/backup/"

#Formato do arquivo
date_formated=$(date +%d-%m-%Y)
inicio=$(date +%d-%m-%H-%M-%S)
final_archive="backup_$date_formated.tar.gz"

#Log e ja inicia o registro do inicio
log_file="/var/log/backup.log" #colocar no /var/log
echo "Inicio: $inicio" >> $log_file
# Diretorio temporario para o backup
temp_path="/backlog/backup_temp"
if [[ ! -d $temp_path ]]; then
    mkdir -p "$temp_path"
fi

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
for path in "${backup_path[@]}"; do
    if [[ ! -d "$path" ]]; then
        echo "[WARNING] Diretório não encontrado, ignorando: $path - $date_formated" >> $log_file
        continue
    fi

    # Extrai nome base da pasta sem trailing slash
    base_name=$(basename "$path")

    # Cria diretório temporário individual
    staging_dir="$temp_path/$base_name"
    mkdir -p "$staging_dir"

    # Copia os arquivos com rsync
    if rsync -a --delete "$path" "$staging_dir/" 2>> $log_file; then
        echo "[INFO] Rsync concluído com sucesso para $base_name - $date_formated" >> $log_file
    else
        echo "[ERROR] Falha no rsync para $base_name - $date_formated" >> $log_file
        continue
    fi

    # Deleta backup anterior do mesmo dia pra evitar acumular
    find "$external_path" -type f -name "${base_name}_$(date +%d-%m-%Y)*.tar.gz" -delete
    # Cria o tar.gz com nome da pasta + data
    archive_name="${base_name}_$date_formated.tar.gz"
    if tar -czf "$external_path/$archive_name" -C "$staging_dir" . 2>> $log_file; then
        echo "[INFO] Backup compactado: $archive_name - $date_formated" >> $log_file
    else
        echo "[ERROR] Falha ao compactar: $archive_name - $date_formated" >> $log_file
    fi
    

    # Remove staging para liberar espaço
    rm -rf "$staging_dir"
done

cd /arquivos/gestao/backup
if tar --exclude=BackupPandoraBox.tar.gz -czf BackupPandoraBox.tar.gz *.tar.gz >> "$log_file"; then
    echo "[INFO] Backup único criado [INFO]"  >> "$log_file"
    echo "[INFO] Deletando os arquivos antigos [INFO]" >> "$log_file"
    find . -maxdepth 1 -type f -name "*.tar.gz" ! -name "BackupPandoraBox.tar.gz" -delete
else
    echo "[ERROR] Falha ao compactar todos em backup único [ERROR]" >> "$log_file"
fi


#######################################
# Excluindo backups com mais de 10 dias
#######################################
find "$external_path" -type f -name "backup_*.tar.gz" -mtime +10 -exec rm -f {} \; -exec echo "[INFO] Backup antigo removido: {} - $date_formated" >> $log_file \;

trap 'rm -rf "$temp_path"' EXIT SIGINT SIGTERM # Limpa o diretório temporário ao sair

FIM=$(date +%d-%m-%H-%M-%S)

echo "FIM: $FIM" >> $log_file

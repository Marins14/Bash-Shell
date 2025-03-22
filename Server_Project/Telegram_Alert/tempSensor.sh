#!/bin/bash 

#========================================#
# Verifica a temperatura do sistema      #
#========================================#
# Script de verificação de temperatura   #
# Autor: Matheus Marins                  #
# Data: 03/05/2024                       #
#========================================#

#Data da ocorrência
date_formated=$(date +%d-%m-%Y--%H:%M)

#Log de onde será salvo
log_file="/var/log/tempSensor.log"

limit_temp=60 # 60 graus é o limite

# Pegando a temperatura atual do sistema
current_temp=$(sensors | awk 'NR==8 {print $4}' | sed 's/+//g' | sed 's/°C//g' | sed 's/\..*//g')

if [[ $current_temp -gt $limit_temp ]]; then
    echo "Alerta: temperatura acima de: $current_temp"
    #echo "A temperatura do sistema está acima de '$limit_temp' graus | Fato este ocorrido em $date_formated" >> $log_file
else 
	echo "ta ok em $date_formated" >> $log_file
fi

find $log_file -mtime +10 -delete

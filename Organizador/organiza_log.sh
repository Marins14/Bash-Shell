#!/bin/bash 
#SHEBANG! 

#=======================================================#
#		Organizador dos Logs Imagens/Docs	      	    #
#=======================================================#
# Função: Organizar os logs gerados pelo organizador.sh	#
# Autor: Matheus Marins Bernardello 				  	# 
# Criado em: 2023/10/28                               	#
# Att: --/--/--                                         #
#=======================================================#

#Definição dos caminhos a serem utilizados ao longo do programa
# exemplo de saida: 20/10/2023 - 13:43
DATA=$(date +"%d-%m-%y-%H:%M")
dir_log="/home/$(whoami)/Documentos/log"

# Função que verifica a "idade" do log e exclui se for maior que 90 dias
func_verifica_idade_log(){
    # Verifica se diretorio existe
    if [[ -d "$dir_log" ]]; then
        cd "$dir_log" || exit
        #Vamos compactar o arquivo antes de excluir
        zip "$dir_log"/logs_retirados.zip "$dir_log"/*.log
        # Verifica a idade do arquivo
        if [[ $(find "$dir_log" -name "*.log" -mtime -90) ]]; then
            # Exclui o arquivo
            rm "$dir_log"/*.log
            echo "Removemos os logs antigos do sistemas no dia: $DATA" >> "$dir_log"/logs_retirados.log
            echo "OBS: Os Logs removidos foram compactados e estão neste mesmo diretorio" >> "$dir_log"/logs_retirados.log
        fi
    fi
} >> "$dir_log"/logs_retirados.log 2>&1 # Redireciona a saida para o arquivo de log

#chama a função
func_verifica_idade_log

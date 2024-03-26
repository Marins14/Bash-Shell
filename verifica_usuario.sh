#!/bin/bash

#ALTERAR LINHA ABAIXO
arquivo="/home/$(whoami)/Documentos/csv.csv"
arquivo_saida=" "

#Verifica se o arquivo existe
if [[ ! -f $arquivo ]]; then
	echo "Arquivo não encontrado"
	read -p "Deseja criar? (s/n)" resposta
	case $resposta in
		s) touch $arquivo ;;
		n) exit 1 ;;
		*) echo "Opção inválida" ;;
	esac
	exit 1
fi

#Verifica se o arquivo de saída existe
if [[ ! -f $arquivo_saida ]]; then
	touch $arquivo_saida
fi

for i in $(cat $arquivo | cut -f3 | tail -n +3 ); do
	#echo $i
	net user /domain $i > $arquivo_saida
	for usuario in $(cat $arquivo_saida | grep -i "alteração de senha" | awk '{print $2}'); do
		#faz a verificação solicitada
	done
done
#!/bin/bash

#ALTERAR LINHA ABAIXO
arquivo="/home/$(whoami)/Documentos/csv.csv"
arquivo_saida=" "
for i in $(cat $arquivo | cut -f3 | tail -n +3 ); do
	#echo $i
	net user /domain $i > $arquivo_saida
	for usuario in $(cat $arquivo_saida | grep -i "alteração de senha" | awk '{print $2}'); do
		#faz a verificação solicitada
	done
done



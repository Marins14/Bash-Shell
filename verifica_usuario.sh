#!/bin/bash

#Script para verificar usuários em um arquivo .csv e verificar se os mesmos estão em um grupo específico, se não estiverem, gerar a lista que precisa ser adicionada

#ALTERAR AS LINHAS ABAIXO
arquivo="/home/$(whoami)/Documentos/csv.csv"
arquivo_saida="/home/$(whoami)/Documentos/usuarios.txt"
arquivo_validação="/home/$(whoami)/Documentos/validacao.txt"

#Verifica se o arquivo existe
if [[ ! -f $arquivo ]]; then
	echo "Arquivo não encontrado, verifique o caminho"
	exit 1
fi

#Verifica se o arquivo de saída existe
if [[ ! -f $arquivo_saida ]]; then
	touch $arquivo_saida
fi

#Verifica se o arquivo está vazio, se não estiver, limpa o arquivo
if [[ -s $arquivo_saida ]]; then
	echo "O arquivo de saída não está vazio"
	read -p "Deseja limpar o arquivo? [s/n]: " limpar
	if [[ $limpar == "s" ]]; then
		> $arquivo_saida
	fi
fi

# Caso o arquivo não seja um .csv, ajustar a linha abaixo; 
# Outra opção de cat é a: cat $arquivo| awk -F ';' '{print $3}' | sed 's/"//g' | tail -n +2
for i in $(cat $arquivo | cut -d';' -f3 | sed 's/"//g' | tail -n +2); do
	#echo $i >> $arquivo_saida
	net user /domain $i >> $arquivo_saida
	for grupos in $(cat $arquivo_saida | grep -i "texto que se refere aos grupos" | awk '{print $2}' ); do
		#faz a verificação solicitada
		echo "Usuário, possui os seguinte grupos associados:  $grupos" >> $arquivo_validação
	done
	#Possivel solução
	# Verifica se o arquivo possui as strings "OCS_CLOUD" e "revenue"
	if grep -q "OCS_CLOUD" "$arquivo_validação" && grep -q "revenue" "$arquivo_validação"; then
    	echo "O arquivo possui a string 'OCS_CLOUD' e 'revenue'."
    	sed -i 's/^\(.*\)$/\1, ok/' "$arquivo_validação"
	else
    	echo "O arquivo não possui uma ou ambas as strings."
    	sed -i 's/^\(.*\)$/\1, registrar1/' "$arquivo_validação"
	fi

done
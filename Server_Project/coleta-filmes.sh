#!/bin/bash 

#########################################################################
# PANDORABOX | COLETA FILMES						#
#########################################################################
# Função: Varrer a lista de filmes e armazenas em um .csv		#
# Autor: Matheus Marins Bernardello					#
# Data: 22/02/2025							#
#########################################################################


#Variaveis 
diretorio_padrao="/seu/diretorio"

cd $diretorio_padrao

caminho_filmes="/seu/diretorio/"

if [ -f db_filmes_mkv.csv  ];then
	mv db_filmes_mkv.csv db_filmes_bkp_mkv_$(date +%F).csv
fi

if [ -f db_filmes_mp4.csv ];then
	mv db_filmes_mp4.csv db_filmes_bkp_mp4_$(date +%F).csv
fi
#cabecalho para os CSVs
echo "Nome do Arquivo;Data de modificação" > db_filmes_mkv.csv
echo "Nome do Arquivo;Data de modificação" > db_filmes_mp4.csv

#Procura por mkv
busca_mkv(){
IFS=$'\n' procura_filmes=$(find $caminho_filmes -mindepth 2 -type f -name "*.mkv")

for i in $procura_filmes;
do
	#echo -n "$i;" >> db_filmes_mkv.csv
	#echo "$(stat --format="%z" $i | awk -F. '{print $1}')" >> db_filmes_mkv.csv	
	nome_arquivo=$(basename "$i")
	data_modificacao=$(stat --format="%y" "$i" | awk -F. '{print $1}')
	echo "$nome_arquivo;$data_modificacao" >> tmp_mkv
done
unset IFS
}
# Procura por mp4
busca_mp4(){
IFS=$'\n' procura_filmes=$(find $caminho_filmes -mindepth 2 -type f -name "*.mp4")

for i in $procura_filmes;
do
#	echo -n "$i;" >> db_filmes_mp4.csv
#	echo "$(stat --format="%z" "$i" | awk -F. '{print $1}')" >> db_filmes_mp4.csv	         
	nome_arquivo=$(basename "$i")
        data_modificacao=$(stat --format="%y" "$i" | awk -F. '{print $1}')
        echo "$nome_arquivo;$data_modificacao" >> tmp_mp4

done
unset IFS
}

ajusta_arquivo(){
	cat tmp_mkv | sort -t";" -k2,2r >> db_filmes_mkv.csv
	cat tmp_mp4 | sort -t";" -k2,2r >> db_filmes_mp4.csv
	rm -f tmp_mkv
	rm -f tmp_mp4
}

busca_mkv
busca_mp4
ajusta_arquivo

if [ $? -eq 0 ];then 
	echo "Operação com sucesso!" 
else
	echo "Ops, tivemos problemas!"
fi

#!/bin/bash 
#SHEBANG! 

#=======================================================#
#			Organizador de Imagens/DOCs			      	#
#=======================================================#
# Função: Organizar Imagens PNG,JPEG,JPG e Documentos 	#
# Autor: Matheus Marins Bernardello 				  	# 
# Criado em: 2023/10/19                               	#
# Att: --/--/--                                       	#
#=======================================================#

#Definição dos caminhos a serem utilizados ao longo do programa
#DATA=$(date +%d"-"%m"-"%y"-"%H":"%M) # exemplo de saida: 20/10/2023 - 13:43
DATA=$(date +"%d-%m-%y-%H:%M")

dir_origem="/home/$(whoami)/Imagens" # Caso Linux 
#dir_origem='/c/Users/%USERNAME%/Imagens' # Caso windows

dir_destino="/home/$(whoami)/Imagens/Organizadas" # Caso linux
#dir_destino='/c/Users/%USERNAME%/Imagens/Organizadas' # Caso windows

dir_org_doc="/home/$(whoami)/Documentos" # Caso linux
#dir_org_doc='/c/Users/%USERNAME%/Documentos' # Caso windows

dir_dest_doc="/home/$(whoami)/Documentos/Organizado" # Caso linux
#dir_dest_doc='/c/Users/%USERNAME%/Documentos/Organizado' # Caso windows

dir_log="/home/$(whoami)/Documentos/log" # Caso Linux
#dir_log='/c/Users/%USERNAME%/Documentos/log' # Caso windows

#Se não existir o diretório de log, ele irá criar
if [[ ! -d $dir_log ]]; then
		#Cria o diretório de log, em caso de erro ele irá informar
	if mkdir -p "$dir_log";then
			echo "Diretório log criado em $dir_log"
	else
			echo "Erro ao criar o diretório de log, favor verificar!"
	fi
fi	
#Função para organizar as Imagens
func_organiza_img() {
    echo "$USER escolheu organizar"
    # Caso a pasta destino não exista, ele cria
    if [[ ! -d $dir_destino ]]; then
        if mkdir -p "$dir_destino"; then
            echo "Diretório de destino criado em $dir_destino"
        fi
    else
        echo "Erro ao criar o diretório de destino, favor verificar!"
    fi

    echo "Iniciando a organização!"

    # Faz a troca para a pasta de origem para iniciar
    cd "$dir_origem" || exit

    # Move os arquivos PNG para o diretório de destino
    for arquivo in *.png; do
        if [[ -f "$arquivo" ]]; then
            mv "$arquivo" "$dir_destino"
        fi
    done

    # Move os arquivos JPEG para o diretório de destino
    for arquivo in *.jpeg; do
        if [[ -f "$arquivo" ]]; then
            mv "$arquivo" "$dir_destino"
        fi
    done

    # Move os arquivos JPG para o diretório de destino
    for arquivo in *.jpg; do
        if [[ -f "$arquivo" ]]; then
            mv "$arquivo" "$dir_destino"
        fi
    done

    echo "Finalizando..."
    echo "Suas Imagens foram movidas com sucesso!" 
    valida=$(ls "$dir_destino")
    echo "$valida"
    echo "OBS: Lembrando que você encontrar tudo que foi movido para: $dir_destino"

} >> "${dir_log}/func_organiza_img_${DATA}.log" 2>&1 # Aloca todas as info do programa neste diretório 

# Função para organizar os Documentos
func_organiza_doc() {
    echo "$USER escolheu organizar"
    
    # Caso a pasta destino não exista, ele cria
    if [[ ! -d $dir_dest_doc ]]; then
        if mkdir -p "$dir_dest_doc"; then
            echo "Diretório de destino criado em $dir_dest_doc"
        fi
    else
        echo "Erro ao criar o diretório de destino, favor verificar!"
    fi

    echo "Iniciando a organização!" 
    # Troca para a pasta de origem dos doc
    cd "$dir_org_doc" || exit

    # Faz a varredura dos arquivos na pasta de origem
    for arquivo in *; do 
        if [[ -f $arquivo ]]; then
            DOC="*.doc"
            mv "$DOC" "$dir_dest_doc"
        fi
    done

    # Repita o processo para os outros tipos de documento (docx, TXT, pdf, etc.)
    for arquivo in *.docx; do 
        if [[ -f $arquivo ]]; then
            mv "$arquivo" "$dir_dest_doc"
        fi
    done

    for arquivo in *.txt; do 
        if [[ -f $arquivo ]]; then
            mv "$arquivo" "$dir_dest_doc"
        fi
    done

    for arquivo in *.pdf; do 
        if [[ -f $arquivo ]]; then
            mv "$arquivo" "$dir_dest_doc"
        fi
    done

    echo "Finalizando..." 
    echo "Seus arquivos foram movidos com sucesso!"
    valida=$(ls "$dir_dest_doc")
    echo "$valida"
    echo "OBS: Lembrando que você encontrar tudo que foi movido para: $dir_dest_doc"
    
    # Adicionando mais extensões caso necessário
    # echo "Sentiu falta de alguma extensão? (S/N)" 
    # read falta
    # falta=$( echo "$falta" | tr a-z A-Z)
    
    # # Se sim, ele irá perguntar quantas mais e quais são fazendo o devido tratamento
    # if [[ $falta == "S" ]]; then
    #     echo "Ok, quantas mais você quer adicionar ? Lembrando só podem ser mais 2 (1-2)"
    #     read qtde
    #     # Verificando se a qtde é um numero válido
    #     if ! [[ "$qtde" =~ ^[1-2]$ ]]; then
    #         echo "Erro: Por favor, insira 1 ou 2."
    #         exit 1
    #     fi

    #     if [[ $qtde -eq 1 ]]; then
    #         echo "Por favor nos diga qual a extensão do arquivo!"
    #         read extensao
    #         # Validando se a extensão é alfanumerica (por exemplo, sem espaços)
    #         if ! [[ "$extensao" =~ ^[a-zA-Z0-9]+$ ]]; then
    #             echo "Erro: Por favor, insira uma extensão válida."
    #             exit 1
    #         fi

    #         EXT="*.$extensao"
    #         mv "$EXT" "$dir_dest_doc" 
    #         echo "Feito!" 

    #     elif [[ $qtde -eq 2 ]]; then 
    #         echo "Por favor nos diga quais as extensões dos arquivos!"
    #         read extensao1
    #         read extensao2
    #         # Validando se a extensão é alfanumerica (por exemplo, sem espaços)
    #         if [[ ! "$extensao1" =~ ^[a-zA-Z0-9]+$ || ! "$extensao2 " =~ ^[[:alnum:]]+$ ]]; then
    #             echo "Erro: Por favor, insira uma extensão válida."
    #             exit 1
    #         fi

    #         EXT="*.$extensao1"
    #         mv "$EXT" "$dir_dest_doc" 
    #         EXT1="*.$extensao2"
    #         mv "$EXT1" "$dir_dest_doc"

    #         echo "Feito!"
    #     fi
    #     valida=$(ls "$dir_dest_doc")
    #     echo "$valida"
    # else 
    #     echo "Ótimo!" 
    # fi
} >> "${dir_log}/func_organiza_doc_${DATA}.log" 2>&1 #Aloca todas as info do programa neste diretório 

#Inicio do programa, perguntando se executa ou não
echo "Olá! Bem vindo ao Organizador de arquivos, vamos lá ? (S/N)" 
read escolha 
escolha=$( echo $escolha | tr a-z A-Z ) #Garanto que o digitado pelo usuario seja tratado em MAIUSCULO

#Se escolher Imagens, chama a função da mesma, o mesmo para Documentos ou simplesmente sair
if [[ $escolha == "S" ]]; then
	echo "Perfeito $USER, vamos lá, o que deseja organizar ? 
	1 - Imagens 
	2 - Documentos 
	3 - Sair"
	read organiza
	#Validando se a escolha é realmente um numero válido
	if ! [[ $organiza =~ ^[1-3]+$ ]]; then
		echo "ERRO: Por favor, digite um numero válido!"
		exit 1
	fi
	case $organiza in 
		1) 
			func_organiza_img
			echo "Obrigado por utilizar nosso code!" 
			exit 1
		;; 
		2) 
			func_organiza_doc
			echo "Obrigado por utilizar nosso code!" 
			exit 1
		;;
		3)
			echo "Saindo..." 
			exit 1
		;; 
	esac
else 
	echo "Ok...saindo"
	exit 1
fi 
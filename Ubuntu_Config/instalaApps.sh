#!/bin/bash

#==================================================#
# Instalação de aplicativos no Linux/Ubuntu        #
#==================================================#
# Autor: Matheus Bernardello                       #
# Data: 11/04/2024                                 #
# Versão: 0.1                                      #
# Atualizacao: 08/11/2024                          #
# Função: Instala aplicativos no Linux             #
#==================================================#
# Testado em ambiente Ubuntu 22.04 LTS             #
# Versão do shell: bash 5.1.16                     #
#==================================================#
# Dúvidas? Leia o README.md                        #
#==================================================#

#Diretórios
dirDownloads="$HOME/Downloads/programas"

#Cores
verde="\033[32;1m"
vermelho="\033[31;1m"
normal="\033[0m"

#URLs dos pacotes deb
URLS=(
    "https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
    "https://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/10702/wps-office_11.1.0.10702.XA_amd64.deb"
    "https://download.virtualbox.org/virtualbox/7.0.16/virtualbox-7.0_7.0.16-162802~Ubuntu~jammy_amd64.deb"
)

#Funções

#Valida o SO, se != Ubuntu, encerra o script
valida_so(){
    if ! lsb_release -a | grep -i Ubuntu; then
        echo -e "${vermelho}[ERRO]----- Este script é para Ubuntu e derivados! -----[ERRO]${normal}"
        exit 1
    fi
}

#Atualiza o sistema
atualiza_sistema(){
    sudo apt update && sudo apt upgrade -y
}

#Verificar a internet
verifica_internet(){
    if ! ping -c 1 google.com &> /dev/null; then
        echo -e "${vermelho}[ERRO]----- Sem conexão com a internet. -----[ERRO]${normal}"
        exit 1
    else
        echo -e "${verde}[INFO]----- Conexão com a internet estabelecida. -----[INFO]${normal}"
    fi
}

#Prepara o diretório de downloads
prepara_downloads(){
    if [ ! -d "$dirDownloads" ]; then
        mkdir -p $dirDownloads
    fi
}

#Programas para instalar
PROGRAMAS=(
    snapd
    code
    vlc
    git
    wget
    curl
    net-tools
    qbittorrent
    nmap
    teams-for-linux
    keepassxc
    bind9-dnsutils
    jq
)

#Instalação dos programas
instala_deb(){
    echo -e "${verde}[INFO]-----  Baixando pacotes .deb  -----[INFO]${normal}"
    for url in ${URLS[@]}; do
        if ! wget -c $url -P $dirDownloads; then
            echo -e "${vermelho}[ERRO]-----  Erro ao baixar o pacote $url  -----[ERRO]${normal}"
            exit 1
        fi
        if apt list | grep -q $(basename $url); then
            echo -e "${verde}[INFO]-----  $(basename $url) já está baixado  -----[INFO]${normal}"
        fi
    done
    echo -e "${verde}[INFO]-----  Instalando pacotes .deb  -----[INFO]${normal}"
    sudo apt install $dirDownloads/*.deb -y
    echo -e "${verde}[INFO]-----  Instalando pacotes apt  -----[INFO]${normal}"
    for programa in ${PROGRAMAS[@]}; do
        if ! apt list | grep -q $programa; then
            sudo apt install $programa -y
        else
            echo -e "${verde}[INFO]-----  $programa já está instalado  -----[INFO]${normal}"
        fi
    done
}

instala_flatpak(){
    echo -e "${verde}[INFO]-----  Instalando Flatpak  -----[INFO]${normal}"
    sudo apt install flatpak -y
    sudo flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    echo -e "${verde}[INFO]-----  Flatpak instalado com sucesso!  -----[INFO]${normal}"
}

#Atualiza e limpa
desinsta_libreoffice(){
    sudo apt remove --purge libreoffice* -y
}

limpa_sistema(){
    apt update -y
    sudo apt autoremove -y
    sudo apt autoclean
}

#Configuração Extra de aliases
conf_aliases(){
    echo -e "${verde}[INFO]-----  Configurando aliases  -----[INFO]${normal}"
    if [[ ! -f ~/.bash_aliases ]];then
        touch ~/.bash_aliases 
    fi
    echo "alias update='sudo apt update && sudo apt upgrade -y'" >> ~/.bash_aliases
    echo "alias limpa='sudo apt autoremove -y && sudo apt autoclean'" >> ~/.bash_aliases
    echo "alias animallink='cd /home/$(whoami)/Documentos/animallink'" >> ~/.bash_aliases
    echo "alias aliasconfig='nano ~/.bash_aliases'" >> ~/.bash_aliases
    echo "alias maua='cd /home/$(whoami)/Documentos/MAUA'" >> ~/.bash_aliases
    echo "alias Scripts='cd /home/$(whoami)/Documentos/Bin'" >> ~/.bash_aliases
    echo "alias myip='ifconfig | grep inet | awk 'NR==3 {print $2}''" >> ~/.bash_aliases
    echo "alias please='sudo'" >> ~/.bash_aliases
    echo "alias cls='clear'" >> ~/.bash_aliases
    . ~/.bash_aliases
    echo -e "${verde}[INFO]-----  Aliases configurados  -----[INFO]${normal}"
}

#Configurando arquivo de ssh 
conf_ssh(){
    echo -e "${verde}[INFO]-----  Configurando arquivo de ssh  -----[INFO]${normal}"
    if [[ ! -d ~/.ssh ]];then
        mkdir ~/.ssh
    fi
    if [[ ! -f ~/.ssh/config ]];then
        touch ~/.ssh/config
    fi
    echo "Digite o IP do servidor remoto:"
    read -r IP
    echo "Digite o nome do usuário remoto:"
    read -r usarioremoto
    echo "Digite o hostname do servidor remoto:"
    read -r HostnameRemoto
    {
        echo "Host $HostnameRemoto"
        echo "    HostName $IP"
        echo "    User $usarioremoto"
        echo "    IdentityFile /home/$USER/.ssh/id_rsa"
    } >> ~/.ssh/config
    echo -e "${verde}[INFO]-----  Arquivo de ssh configurado  -----[INFO]${normal}"
}

#Configuração manual de instalação
instalacaoAssistida(){
    echo "Estes são os programas .deb que serão instalados:"
    echo "Google Chrome"
    echo "WPS Office"
    echo "VirtualBox"
    echo "Deseja continuar? (s/n)"
    read choice | tr '[:upper:]' '[:lower:]'
    if [[ $choice == "s" ]]; then
        instala_deb
    fi
    echo "Deseja instalar o Flatpak? (s/n)"
    read choice | tr '[:upper:]' '[:lower:]'
    if [[ $choice == "s" ]]; then
        instala_flatpak
    fi
    echo "Deseja desinstalar o LibreOffice? (s/n)"
    read choice | tr '[:upper:]' '[:lower:]'
    if [[ $choice == "s" ]]; then
        desinsta_libreoffice
    fi
    limpa_sistema
    echo "Deseja configurar os aliases? (s/n)"
    read choice | tr '[:upper:]' '[:lower:]'
    if [[ $choice == "s" ]]; then
        conf_aliases
    fi
    echo "Deseja configurar o arquivo de ssh? (s/n)"
    read choice | tr '[:upper:]' '[:lower:]'
    if [[ $choice == "s" ]]; then
        conf_ssh
    fi
    echo -e "${verde}[INFO]-----  Instalação concluída  -----[INFO]${normal}"
}


#Função principal
valida_so 
echo "Ola, vamos configurar seu $(lsb_release -d | awk '{print $2}')."
verifica_internet
atualiza_sistema
prepara_downloads
echo "Deseja analisar cada passo da instalação? (s/n)"
read choice | tr '[:upper:]' '[:lower:]'
if [[ $choice == "s" ]]; then
    instalacaoAssistida
else
    instala_deb
    instala_flatpak
    desinsta_libreoffice
    limpa_sistema
    conf_aliases
    echo "Deseja configurar o arquivo de ssh? (s/n)"
    read choice | tr '[:upper:]' '[:lower:]'
    if [[ $choice == "s" ]]; then
        conf_ssh
    fi
fi

#Fim do script
echo -e "${verde}[INFO]-----  Instalação concluída  -----[INFO]${normal}"
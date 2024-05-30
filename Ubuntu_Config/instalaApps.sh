#!/bin/bash

#==================================================#
# Instalação de aplicativos no Linux/Ubuntu        #
#==================================================#
# Autor: Matheus Bernardello                       #
# Data: 11/04/2024                                 #
# Função: Instala aplicativos no Linux/Ubuntu      #
#==================================================#

#Diretórios
dirDownloads="$HOME/Downloads/programas"

#Cores
verde="\033[32;1m"
vermelho="\033[31;1m"
normal="\033[0m"

#URLs dos pacotes deb
ChromeDeb="https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb"
WPSDeb="https://wdl1.pcfg.cache.wpscdn.com/wpsdl/wpsoffice/download/linux/10702/wps-office_11.1.0.10702.XA_amd64.deb"
virtualbox="https://download.virtualbox.org/virtualbox/7.0.16/virtualbox-7.0_7.0.16-162802~Ubuntu~jammy_amd64.deb"

#Funções

#Atualiza o sistema
atualiza_sistema(){
    sudo apt update && sudo apt upgrade -y
}

#Verificar a internet
verifica_internet(){
    if ! ping -c 1 google.com &> /dev/null; then
        echo -e "${vermelho}Sem conexão com a internet.${normal}"
        exit 1
    else
        echo -e "${verde}Conexão com a internet estabelecida.${normal}"
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
    qbittorrent
    nmap
    teams-for-linux
)

#Instalação dos programas
instala_deb(){
    echo -e "${verde}[INFO]-----  Baixando pacotes .deb  -----[INFO]${normal}"
    wget -c $ChromeDeb -P $dirDownloads
    wget -c $WPSDeb -P $dirDownloads
    wget -c $virtualbox -P $dirDownloads
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

#instala_flatpak(){
   #echo -e "${verde}[INFO]-----  Instalando Flatpak  -----#[INFO]${normal}"
    #sudo apt install flatpak -y
    #sudo flatpak remote-add --if-not-exists flathub #https://flathub.org/repo/flathub.flatpakrepo
    #sudo flatpak install flathub com.spotify.Client -y
#}

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
    . ~/.bash_aliases
    echo -e "${verde}[INFO]-----  Aliases configurados  -----[INFO]${normal}"
}

#Execução
verifica_internet
atualiza_sistema
prepara_downloads
instala_deb
#desinsta_libreoffice
#instala_flatpak
limpa_sistema
echo "Deseja configurar os aliases? (s/n)"
read choice | tr '[:upper:]' '[:lower:]'
if [[ $choice == "s" ]]; then
    conf_aliases
fi

#Fim do script
echo -e "${verde}[INFO]-----  Instalação concluída  -----[INFO]${normal}"
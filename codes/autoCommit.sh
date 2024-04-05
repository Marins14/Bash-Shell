#!/bin/bash 
################################################
# Author: Matheus Bernardello                  #
# Date: 05/04/2024                             #
################################################

if [[ $(git status --porcelain) ]]; then 
    
    git add .

    #echo "Digite a mensagem do commit: "
    #read mensagem

    git commit -m "Mensagem Automática de Commit"

    git push
    #echo "Posso subir? (s/n)"
    #read choice

    #if [[ $choice == "s" ]]; then
    #    git push
    #else
    #    echo "Operação cancelada, realizar novo commit"
    #fi
fi

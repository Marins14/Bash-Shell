#!/bin/bash 

if [[ $(git status --porcelain) ]]; then
    
    git add .

    echo "Digite a mensagem do commit: "
    read mensagem

    git commit -m "$mensagem"

    echo "Posso subir? (s/n)"
    read choice

    if [[ $choice == "s" ]]; then
        git push
    else
        echo "Operação cancelada"
    fi
fi

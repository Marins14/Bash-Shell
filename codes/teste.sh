#!/bin/bash 


git add .

echo "Digite a mensagem do commit: "
read mensagem

git commit -m "$mensagem"

echo -p "Posso subir? (s/n)" choice

if [[ $choice == "s" ]]; then
    git push
else
    echo "Operação cancelada"
fi
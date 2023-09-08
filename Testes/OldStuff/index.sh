#if [ -e /home/matheus/Documentos/teste.txt ]; then
#    echo 'Arquivo existe' 
#else 
#    touch teste.txt /home/matheus/Documentos/
#    echo 'Arquivo não existe, criado!' 
#fi 

x=29

if [ $x -gt 9 ]; then
    echo 'maior que 9'
else 
    echo 'menor ou igual a 9'
fi

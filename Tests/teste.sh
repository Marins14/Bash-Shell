#!/bin/bash 

echo "olá" 

cd ~/Música


if [ ! -d LinuxTeste  ]; then
	mkdir LinuxTeste
	echo "Criado" >> log.log
else
	echo "Apagado" >> log.log
	rm -rf LinuxTeste

fi

echo "finalizado com sucesso!"


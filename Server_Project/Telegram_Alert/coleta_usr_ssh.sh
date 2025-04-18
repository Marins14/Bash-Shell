#!/bin/bash

. crypto.sh

log_file='/var/log/tcpwrappers-allow-ssh.log'

usr=$(grep -i usuário $log_file | awk -F' ' '{print $5}' | tail)

admin=$(decrypto "bWF0aGV1cwo=")

for i in ${usr[@]};do
	if [[ $i != $admin  ]];then 
		echo "Usuario nao admin conectado: $i"
	fi
done

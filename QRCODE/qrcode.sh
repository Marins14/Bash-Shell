#!/bin/bash 

#################################################
#               QRCODE GENERATOR!               #
#################################################
# Developed by: Matheus Marins                  #
# V1.0                                          #
# Date: 2023/10/12                              #
# Att: --/--/--                                 #
#################################################

echo "Welcome to the qrcode generator!"
sleep 1

echo "Please enter the website you want the qrcode on!: "

read site
if [ -z $site ]; then
    echo "Please enter a website!"
    read site
fi

qrcode=$(curl -s qrenco.de/$site)
echo "Here is your qrcode! 
Generated in `date` $qrcode" 

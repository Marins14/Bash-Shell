#!/bin/bash 

echo "Please enter the website you want the qrcode on!: "

read site

qrcode=$(curl -s qrenco.de/$site)
echo "Here is your qrcode! $qrcode" 


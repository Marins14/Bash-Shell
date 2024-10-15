#!/bin/bash 

#################################################
#               QRCODE GENERATOR!               #
#################################################
# Developed by: Matheus Marins                  #
# V1.1                                          #
# Date: 2023/10/12                              #
# Att: 10/15/24                                 #
#################################################

echo "Welcome to the qrcode generator!"
sleep 0.5

echo -e "What type of qrcode do you want to generate?
1 - URL
2 - Text
3 - Wifi
4 - Exit"

read site

save_path=$(pwd)

case $site in
    1)
        echo "Type the URL you want to generate the qrcode:"
        read url
        qrencode -o s 10 -l H qrcode.png $url
        echo "Qrcode generated! The qrcode is saved in $save_path/qrcode.png"
        ;;
    2)
        echo "Type the text you want to generate the qrcode:"
        read text
        qrencode -o s 10 -l H qrcode.png $text
        echo "Qrcode generated! The qrcode is saved in $save_path/qrcode.png"
        ;;
    3)
        echo "Type the SSID:"
        read ssid
        echo "Type the password:"
        read password
        echo "Type the encryption type (WPA/WEP):"
        read encryption
        qrencode -o -s 10 -l H qrcode.png "WIFI:S:$ssid;T:$encryption;P:$password;;"
        echo "Qrcode generated! The qrcode is saved in $save_path/qrcode.png"
        ;;
    4)
        echo "Exiting..."
        exit 0
        ;;
    *)
        echo "Invalid option!"
        ;;
esac
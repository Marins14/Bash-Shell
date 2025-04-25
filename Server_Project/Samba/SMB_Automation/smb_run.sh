#!/bin/bash 

#===============================================#
# SMB Share Setup Script                        #
#===============================================#
# This script sets up a pre-req Samba share     #
# Author: Matheus Marins                        #
# Date: 2025-04-20                              #
#===============================================#


#Variables
LOG_FILE="/var/log/smb_setup.log"

unzip_files(){
    tar -xvf samba.tar.gz
    rm -f samba.tar.gz
}

prerequisites(){
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit 1
fi

# Check the network connection
if ! ping -c 1 8.8.8.8 &> /dev/null; then
    echo "No internet connection. Please check your network."
    exit 1
fi

if [ -f install_samba.sh ]; then
    chmod +x install_samba.sh
fi
if [ -f crypt.sh ]; then
    chmod +x crypt.sh
    source crypt.sh
fi

}

collect_info(){
# Collect user information
echo "Hi, there! This script will help you set up a Samba share."

CONFIG_FILE="./users.json"

echo "Starting user collector..."
echo '{ "users": [] }' > "$CONFIG_FILE"

tmpfile=$(mktemp)

while true; do
    read -p "Add user? (y/n): " answer
    case "$answer" in
        y|Y)
            read -p "Username: " username
            read -sp "Password: " password
            echo
            encoded_pass=$(crypto "$password")

            jq \
            --arg user "$username" \
            --arg pass "$encoded_pass" \
            '.users += [{"username": $user, "password": $pass}]' \
            "$CONFIG_FILE" > "$tmpfile" && mv "$tmpfile" "$CONFIG_FILE"

            echo "Added $username"
            ;;
        n|N)
            echo "Finished collecting users."
            break
            ;;
        *)
            echo "Please type y or n, poetic soul."
            ;;
    esac
done
}
Installing(){
    bash install_samba.sh
}


#Main script execution#
main(){
unzip_files
prerequisites
collect_info
Installing
} 
main 2>&1 | tee -a "$LOG_FILE"
#=====================#


#Let's remove the files for security reasons
rm -f users.json install_samba.sh crypt.sh
#==========================================#

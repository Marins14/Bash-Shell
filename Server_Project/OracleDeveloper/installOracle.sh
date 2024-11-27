#!/bin/bash

#####################################################################
# Server Project | Install Oracle Developer                         #
#####################################################################
# Author: Matheus Marins                                            #
# Date: 27/11/2024                                                  #
# Version: 1.0                                                      #
# Description: This script is  going to install Oracle Developer	#
# Test: Ubuntu 22.04 LTS  Bash version: 5.1.16                      #
#####################################################################
# In case of error or doubt, please contact the author.             #
#####################################################################

logFile="/var/log/installOracle.log"
jdkPackage="https://download.oracle.com/otn_software/java/sqldeveloper/sqldeveloper-24.3.0.284.2209-no-jre.zip"

# Check if the script is running as root
if [ "$EUID" -ne 0 ]; then
    echo "Please run as root"
    exit
fi

# Check if internet is available
if ! ping -c 1 google.com &> /dev/null; then
    echo "No internet connection"
    exit
fi

# Checking the OS system
if [ -f /etc/os-release ]; then
    . /etc/os-release
    OS=$NAME
    VERSION=$VERSION_ID
else
    echo "OS not supported"
    exit
fi

# Downloading the JDK package
echo "Downloading the JDK package"
if ! wget -c $jdkPackage -P ~/Downloads; then
    echo "Error downloading the JDK package"
    exit
fi >> $logFile 2>&1

# Updating the system if OS is a Debian based
DebianBased(){
    echo "Updating the system"
    apt update -y
    apt upgrade -y
    apt autoremove -y 
} >> $logFile 2>&1

# Updating the system if OS is a Red Hat based
RedHatBased(){
    echo "Updating the system"
    yum update -y
    yum upgrade -y
    yum autoremove -y
} >> $logFile 2>&1

# Installing the JDK package
InstallJDK(){
    echo "Installing the JDK package"
    unzip ~/Downloads/sqldeveloper-*.zip -d /opt
    chmod +x /opt/sqldeveloper/sqldeveloper.sh
    sh /opt/sqldeveloper/sqldeveloper.sh
} >> $logFile 2>&1

# Shortcut 
CreateShortcut(){
    echo "Creating the shortcut"
    echo "[Desktop Entry]
    Name=Oracle SQL Developer
    Comment=Oracle SQL Developer
    Exec=/opt/sqldeveloper/sqldeveloper.sh
    Icon=/opt/sqldeveloper/icon.png
    Terminal=false
    Type=Application
    Categories=Development;" > /usr/share/applications/sqldeveloper.desktop
} >> $logFile 2>&1

# Main
echo "Hi, let's install Oracle Developer, your system is $OS $VERSION, please wait..."
echo "All the logs will be saved in $logFile"

if [ "$OS" == "Ubuntu" ] || [ "$OS" == "Debian GNU/Linux" ]; then
    DebianBased
    InstallJDK
    CreateShortcut
elif [ "$OS" == "CentOS Linux" ] || [ "$OS" == "Red Hat Enterprise Linux Server" ]; then
    RedHatBased
    InstallJDK
    CreateShortcut
else
    echo "OS not supported"
    exit
fi

echo "The installation process has been completed. Enjoy!"
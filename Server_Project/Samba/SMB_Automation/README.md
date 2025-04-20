## Welcome to the SMB automation project!
This project is designed to automate the process of creating and enabling SMB shares from a Linux server to a Windows client. It uses the `samba` package to create and manage SMB shares, and the `smbclient` package to access them from the Windows client.

## Prerequisites
- A Distro Linux, can be Ubuntu, Debian, CentOS, Rocky Linux, etc.
- A Windows client, to test it.

## Installation
- Download the tagged version of the project: "SMB_Automation"
- Make sure you have the root privileges to run the script.
- Make the script executable:
```bash
chmod +x smb_run.sh
```
- Run the script as root:
```bash
./smb_run.sh
```
- Follow the prompts to configure the SMB share.
- The script will install the necessary packages, create the SMB share, and enable it for access from the Windows client.
- The script will also create a Samba user and set a password for it.

## Usage
- To test it from a linux client, you can use the `smbclient` command:
```bash
smbclient //server_ip/share_name -U username
```
- To test it from a Windows client, you can use the `net use` command:
```powershell
net use Z: \\server_ip\share_name /user:username password
```
- You can also access the share from Windows Explorer by typing `\\server_ip\share_name` in the address bar. *Highly Recommended*

## Troubleshooting
- If you encounter any issues, check the Samba logs for more information:
```bash
tail -f /var/log/samba_setup.log
```
- Make sure that port 445 is open on the server and that the firewall is configured to allow SMB traffic.
```bash
telnet server_ip 445
```
- If you connect to the server, try to access some firewalls configuration, the linux side is everything open, but the Windows side is a little bit more complex, so you can try to disable the firewall temporarily to see if it resolves the issue:
```powershell
netsh advfirewall set allprofiles state off
```
- If you are using a VPN, make sure that the VPN is configured to allow SMB traffic.
- If you are using a proxy, make sure that the proxy is configured to allow SMB traffic.
- If the port 445 is not allowed, you need to configure the samba to use another port, but this has to be done manually, as the script does not support this feature yet.

## Notes
- This script is designed to be run on a Linux server with root privileges.
- The script will prompt you for the necessary information to create and enable the SMB share.
- Be careful when entering the password for the Samba user, as it will be stored in plain text in the Samba configuration file, if you make any mistake, will be necessary to run this command:
```bash
smbpasswd -a username
```
- Make sure that your disk has enough space to create the share and the mount point directory is correct, otherwise the script will fail.
- The rollback function is not implemented yet, so if you encounter any issues, you will need to manually remove the share and the Samba user.
- I made this script for myself, to automate the process of creating and enabling SMB shares from a Linux server to a Windows client, but I decided to share it with the community, so if you have any suggestions or improvements, feel free to open an issue on the GitHub repository.
- This script was tested on Ubuntu 22.04 and Rocky Linux 9.2, but it should work on any Linux distribution that supports Samba and SMB shares.

## Author
- [Matheus Marins](https://www.linkedin.com/in/matheus-marins-bernardello-89b9491ab/)

## Doubts
- If you have any doubts or suggestions, feel free to open an issue on the GitHub repository or contact me directly.
- I will be happy to help you and improve the script.
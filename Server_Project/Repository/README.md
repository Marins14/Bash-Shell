# 🗂️ Creating Your Own RPM Repository (Step by Step)
## 🚀 1. Become root
```bash
sudo su -
```
## 🧹 2. Clean package metadata
```bash
dnf clean all
```
## 🛠️ 3. Install required tools
```bash
dnf install createrepo nginx
```
## 📁 4. Create the directory for your repository
```bash
mkdir -p /usr/share/nginx/html/your_repo
```
## 📦 5. Download the packages you want in your repository
```bash
dnf download packages
#example
dnf download vim-enhanced nmap htop tcpdump
```
## 🔧 6. Initialize the repository metadata
```bash
createrepo /usr/share/nginx/html/your_repo
```
### Notes 6.
- If you add a new packages in your repository, use this command to update the xml
```bash
createrepo --update /usr/share/nginx/html/your_repo
```
## 🌐 7. Enable and start Nginx
```bash
systemctl enable --now nginx.service
```
## 🧪 8. Test repository access
```bash
curl -I http://localhost/your_repo
curl -I http://localhost/your_repo/repodata/repomd.xml
```
## 📊 9. Verify Nginx service status
```bash
netstat -naptu | grep 80
systemctl status nginx
systemctl reload nginx
```
## 🔥 10. Configure the firewall
```bash
firewall-cmd --list-all
# If HTTP is not allowed:
firewall-cmd --permanent --add-service=http
firewall-cmd --reload
```
## 🔐 11. Adjust SELinux (if enforcing)
```bash
semanage fcontext -a -t httpd_sys_content_t "/path/to/your/repo(/.*)?"
restorecon -Rv /path/to/your/repo
```
# 🖥️ Client Configuration
## 1. Create the repo file
```bash
vim /etc/yum.repos.d/your_repo
```
```txt
[your-repo]
name=Your Repo
baseurl=http://your-server/your-repo/
enabled=1
gpgcheck=0
priority=1
```
### ⚠️ Notes
- This repo doesn't have signature with GPG

## 2. Test it 
```bash
dnf makecache
dnf update
```

## 📚 Additional Notes
- This guide is intended for learning and homelab environments.
- For production environments, consider using GPG signing, version control, HTTPS, and proper automation.
- Refer to the official documentation for advanced configurations.
- If you found this useful, leave a ⭐ on the repository!
## Author
- [Matheus Marins](https://www.linkedin.com/in/matheus-marins-bernardello-89b9491ab/)
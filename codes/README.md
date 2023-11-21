# Configurando o mail caso esteja usando o mailutils
- Caso não tenha instalado
```bash
sudo apt-get install mailutils
```
- Configurando o mail
```bash
sudo nano /etc/nail.rc
```
- Adicione as seguintes linhas
```bash
set smtp=://smtp.office365.com
set smtp-user-starttls
set smtp-auth=login
set smtp-auth-user=seu_user
set smtp-auth-password=sua_senha
```
- Testando o envio
```bash
echo "Teste de envio de email" | mail -s "Teste" destinatario@examplo.com.br
```

# Configurando o crontab
- Abra o crontab (LEMBRANDO ISTO É SOMENTE EXEMPLO)
```bash
crontab -e
```
- Adicione a seguinte linha
```bash
*/1 * * * * /home/pi/monitoramento.sh
```

### Outra maneira de fazer o envio de email
- Instale o sendemail
```bash
sudo apt-get install sendemail
```
- Para demais configurações olhe o arquivo test.sh

- Lembre-se de dar um chmod 600 no arquivo de configuração do sendemail
```bash
chmod 600 /etc/mail/authinfo # o chmod 600 é para que somente o root tenha acesso ao arquivo
```
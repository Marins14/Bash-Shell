# Automação de alertas!
## Objetivo
O objetivo deste projeto é automatizar o envio de alertas de monitoramento de servidores. O script irá verificar se o servidor está em temperatura abaixo do esperado assim como o seu uso de disco, caso não esteja, enviará uma mensagem no telegram para o adminstrador!

## Como usar
Para usar os scripts, tenha em mente que o script principal é o `monitor_server.py`, ele é quem executa os scripts shell e com isso faz a verificação do uso de disco e da temperatura do servidor. Para executar o script, basta rodar o comando:
```bash
python3 monitor_server.py
```
Recomendo que você adicione o script no crontab para que ele execute a cada 5 minutos, ou o tempo que achar necessário, para isso, basta rodar o comando:
```bash
sudo crontab -e
```
E adicione a seguinte linha:
```bash
*/5 * * * * /usr/bin/python3 /path/to/monitor_server.py
```
Lembre-se de adicionar o caminho correto para o script!

## Configuração
Para que funcione conforme o esperado, você precisa ter em mãos o token do seu bot do telegram e o chat_id do seu grupo, para verificar como fazer isso, olhe o #InfoTelegram, no arquivo `monitor_server.py` você deve preencher as variáveis ou crie um `.env` e adicione elas lá, não esqueça de adicionar o `.env` no `.gitignore` para não subir para o repositório. 
Recomendo que rode o script manualmente para verificar se está funcionando corretamente, caso não esteja, verifique se as variáveis estão corretas.
Ponto de atenção, como este script coleta informações sensivéis do sistema, recomendo que você rode o script como root, para isso, basta rodar o comando:
```bash
sudo python3 monitor_server.py
```
Para dar permissão de root ao script, você mudar as permissões do arquivo, evitando que outros usários possam editar o arquivo, para isso, basta rodar o comando:
```bash
sudo chown root:root monitor_server.py
```
E para dar permissões:
```bash
sudo chmod 700 monitor_server.py
```

## InfoTelegram
Para criar um bot no telegram, você deve seguir os seguintes passos:
1. Abra o Telegram e procure por `BotFather`
2. Crie um novo bot com o comando `/newbot`
3. Siga as instruções do BotFather
4. Copie o token gerado
5. Adicione o bot ao seu grupo
6. Para pegar o chat_id, acesse o link `https://api.telegram.org/bot<YourBOTToken>/getUpdates` e envie uma mensagem no grupo
7. Pegue o chat_id e adicione no script
8. Pronto, agora você pode enviar mensagens para o grupo! Para testar manualmente se sua chave está funcionando, basta rodar o comando:
```bash
curl -s -X POST https://api.telegram.org/bot<YourBOTToken>/sendMessage -d chat_id=<YourChatID> -d text="Hello, World!"
```

## Tecnologias
- Python
- Telegram API
- Shell Script

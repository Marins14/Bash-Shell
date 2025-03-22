#!/usr/bin/python3

import subprocess
import requests
from datetime import  datetime
import os

#Carrega o arquivo .env
from dotenv import load_dotenv
load_dotenv()

# Configuração do bot do Telegram
TELEGRAM_BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")
TELEGRAM_CHAT_ID = os.getenv("TELEGRAM_CHAT_ID")
hoje=datetime.today()

def send_telegram_message(message):
    """Envia uma mensagem para o Telegram"""
    url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/sendMessage"
    payload = {"chat_id": TELEGRAM_CHAT_ID, "text": message}
    requests.post(url, data=payload)
    
def check_temperature():
   """Executa o script de temperatura e verifica o limite."""
   result = subprocess.run(["caminho/para/seu/script.sh"], capture_output=True, text=True)
   if "acima de" in result.stdout:
       send_telegram_message(f"🚨 Alerta: A temperatura do servidor está acima do limite! Data e hora: {hoje}")
       
def check_disk_usage():
    """Executa o script de uso de disco e verifica o limite."""
    result = subprocess.run(["caminho/para/seu/script.sh"], capture_output=True, text=True)
    if "acima de" in result.stdout:
        send_telegram_message(f"🚨 Alerta: O uso de disco está acima do limite! Data e hora: {hoje}")

if __name__ == "__main__":
 check_temperature()
 check_disk_usage()


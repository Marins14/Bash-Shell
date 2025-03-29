#!/usr/bin/python3

import subprocess
import requests
from datetime import  datetime
import os

#Carrega o env
from dotenv import load_dotenv
load_dotenv()

# Configuração do bot do Telegram
TELEGRAM_BOT_TOKEN = os.getenv("TELEGRAM_BOT_TOKEN")
TELEGRAM_CHAT_ID = os.getenv("TELEGRAM_CHAT_ID")
agora=datetime.today()
hoje=agora.strftime("%d/%m/%Y %H:%M")

def send_telegram_message(message):
    """Envia uma mensagem para o Telegram"""
    url = f"https://api.telegram.org/bot{TELEGRAM_BOT_TOKEN}/sendMessage"
    payload = {"chat_id": TELEGRAM_CHAT_ID, "text": message}
    requests.post(url, data=payload)
    
def check_temperature():
   """Executa o script de temperatura e verifica o limite."""
   result = subprocess.run(["/usr/local/sbin/tempSensor.sh"], capture_output=True, text=True)
   if "acima de" in result.stdout:
       send_telegram_message(f"🚨 Alerta: A temperatura do servidor está acima do limite! Data e hora: {hoje}")
def check_disk_usage():
    """Executa o script de uso de disco e verifica o limite."""
    result = subprocess.run(["/usr/local/sbin/alert_disk.sh"], capture_output=True, text=True)
    if "acima de" in result.stdout:
        send_telegram_message(f"🚨 Alerta: O uso de disco está acima do limite! Data e hora: {hoje}")
def check_user_logged():
    """Executa o script para validar os ultimos 5 usuários logados"""
    result = subprocess.run(["/usr/local/sbin/coleta_usr_ssh.sh"], capture_output=True, text=True)
    if "Usuario nao admin" in result.stdout:
        send_telegram_message(f"🚨 Alerta: Usuario nao admin conectado ao server! Data e hora: {hoje}")  

if __name__ == "__main__":
 #send_telegram_message("Teste")
 check_temperature()
 check_disk_usage()
 check_user_logged()

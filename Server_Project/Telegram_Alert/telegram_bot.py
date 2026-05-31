import requests
from telegram import Update
from telegram.ext import ApplicationBuilder
from telegram.ext import CommandHandler
from telegram.ext import ContextTypes
import subprocess
import os
from dotenv import load_dotenv
import docker

load_dotenv()

TOKEN = os.environ["TELEGRAM_TOKEN"]

PROMETHEUS_URL = os.environ["PROMETHEUS_URL"]

ADMIN_ID = int(os.environ["ADMIN_ID"])

servicos = {
    #"📚 Biblioteca (Jellyfin)": "jellyfin",
    "📜 Arquivos (Nextcloud)": "nextcloud",
    "🛡️ Sentinela (Pi-hole)": "pihole"
}

def prometheus_query(query):
    r = requests.get(
        f"{PROMETHEUS_URL}/api/v1/query",
        params={"query": query},
        timeout=5
    )

    data = r.json()

    if not data["data"]["result"]:
        return None

    return float(data["data"]["result"][0]["value"][1])

def get_cpu():
    query = """
    100 - (
      avg(
        rate(node_cpu_seconds_total{mode="idle"}[5m])
      ) * 100
    )
    """

    result = prometheus_query(query)

    return round(result, 1) if result is not None else "N/A"

def get_ram():
    query = """
    (
      1 - (
        node_memory_MemAvailable_bytes /
        node_memory_MemTotal_bytes
      )
    ) * 100
    """

    result = prometheus_query(query)

    return round(result, 1) if result is not None else "N/A"

def get_disk():
    query = """
    (
      1 - (
        node_filesystem_avail_bytes{mountpoint="/"} /
        node_filesystem_size_bytes{mountpoint="/"}
      )
    ) * 100
    """

    result = prometheus_query(query)

    return round(result, 1) if result is not None else "N/A"


def get_service_status(job):
    query = f'up{{job="{job}"}}'

    result = prometheus_query(query)

    return "🟢 ONLINE" if result == 1 else "🔴 OFFLINE"

async def fortaleza(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if update.effective_user.id != ADMIN_ID:
        await update.message.reply_text("⛔ Acesso negado. Você não é um bruxo de Kaer Morhen.")
        return
    status_servicos = []

    for nome, job in servicos.items():
        status_servicos.append(
            f"{nome}: {get_service_status(job)}"
        )

    status_texto = "\n".join(status_servicos)

    cpu = get_cpu()
    ram = get_ram()
    disk = get_disk()

    mensagem = f"""
🏰 Fortaleza Kaer Morhen

⚙️ CPU: {cpu}%
🧠 RAM: {ram}%
💾 Disco: {disk}%

{status_texto}

🐺 Nenhum monstro detectado.
"""

    await update.message.reply_text(mensagem)

async def containers(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if update.effective_user.id != ADMIN_ID:
        await update.message.reply_text("⛔ Acesso negado. Você não é um bruxo de Kaer Morhen.")
        return

    mensagem_espera = await update.message.reply_text("🔮 Consultando o inventário de containers...")

    try:
        client = docker.from_env()
        # list(all=True) traz até os que estão parados. Se quiser só os ativos, mude para client.containers.list()
        lista_containers = client.containers.list(all=True) 

        if not lista_containers:
            await mensagem_espera.edit_text("📦 Nenhum container encontrado nesta máquina.")
            return

        linhas_status = []
        for c in lista_containers:
            status_emoji = "🟢" if c.status == "running" else "🔴"
            
            linhas_status.append(f"{status_emoji} {c.name} ({c.status})")

        status_texto = "\n".join(linhas_status)

        mensagem_final = f"""
📦 *Inventário de Containers - Kaer Morhen*
{status_texto}
Total: {len(lista_containers)} containers gerenciados.
"""
        await mensagem_espera.edit_text(mensagem_final, parse_mode="Markdown")
    except Exception as e:
        await mensagem_espera.edit_text(f"❌ Erro ao conectar ao Docker: {str(e)}")

async def help(update: Update, context: ContextTypes.DEFAULT_TYPE):
    if update.effective_user.id != ADMIN_ID:
        await update.message.reply_text("⛔ Acesso negado. Você não é um bruxo de Kaer Morhen.")
        return
    ajuda_texto = """
📖 *Guia de Comandos da Fortaleza*

Gerencie e monitore as defesas do seu servidor local.

⚔️ *Comandos Disponíveis:*
/fortaleza - Exibe o status geral do host (CPU, RAM, Disco) e a saúde dos serviços principais via Prometheus.
/containers - Lista todos os containers Docker ativos na máquina e o tempo de atividade de cada um.
/help - Mostra este guia de comandos.

📜 *Serviços Monitorados:*
• Nextcloud (Arquivos)
• Pi-hole (Sentinela)
"""
    
    await update.message.reply_text(
        ajuda_texto, 
        parse_mode="Markdown"
    )
    

app = ApplicationBuilder().token(TOKEN).build()

app.add_handler(CommandHandler("fortaleza", fortaleza))

app.add_handler(CommandHandler("containers", containers))

app.add_handler(CommandHandler("help", help))

app.run_polling()
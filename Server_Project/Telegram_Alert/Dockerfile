FROM python:3.12-slim

LABEL org.opencontainers.image.title="Telegram Bot - Pandora"
LABEL org.opencontainers.image.description="Comandos a serem respondidos via bot do pandorabox"
LABEL org.opencontainers.image.authors="Matheus Marins <matheus.bernardello@live.com>"
LABEL org.opencontainers.image.source="https://github.com/Marins14/Bash-Shell"

WORKDIR /app

COPY requirements.txt .

RUN pip install --no-cache-dir -r requirements.txt \
    && useradd -m bot


COPY telegram_bot.py .

USER bot

CMD ["python", "telegram_bot.py"]
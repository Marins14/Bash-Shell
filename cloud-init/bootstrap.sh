#!/usr/bin/env bash
# ===================================================================================================#
# bootstrap.sh - Padrão base para VMs no AWS Lightsail
#
# Uso:
#   1) Instância NOVA  : colar como "launch script" no Lightsail (roda como root
#                        no primeiro boot) ou passar via --user-data na CLI.
#   2) Instância EXISTENTE:
#        sudo ADMIN_USER=admin ADMIN_PUBKEYS="$(cat chave.pub)" NETBIRD_SETUP_KEY=xxx bash bootstrap.sh
#
# Idempotente: pode ser executado várias vezes para reaplicar o padrão.
# Suporta imagens baseadas em apt (Ubuntu / Debian).
# Log: /var/log/bootstrap.log
# ===================================================================================================#

set -euo pipefail
exec > >(tee -a /var/log/bootstrap.log) 2>&1

# -----------------------------------------------------------------------------
# CONFIGURAÇÃO - ajustes faça aqui!
# -----------------------------------------------------------------------------
NODE_NAME="${NODE_NAME:-$(hostname)}"     # nome do host / peer no NetBird

# Parâmetros gravados pelo launch-lightsail.sh (a partir do .env local).
# Sem esse arquivo (instalação manual), valem as variáveis de ambiente e os padrões abaixo.
PARAMS_FILE="/root/bootstrap.env"
if [[ -f "$PARAMS_FILE" ]]; then
  source "$PARAMS_FILE"
fi

TIMEZONE="${TIMEZONE:-UTC}"
ADMIN_USER="${ADMIN_USER:?defina ADMIN_USER (ou rode via launch-lightsail.sh)}"
DEFAULT_ADMIN_PUBKEYS=()
# ADMIN_PUBKEYS (uma chave por linha) tem prioridade sobre a lista padrão
if [[ -n "${ADMIN_PUBKEYS:-}" ]]; then
  mapfile -t ADMIN_PUBKEYS_LIST <<< "$ADMIN_PUBKEYS"
else
  ADMIN_PUBKEYS_LIST=("${DEFAULT_ADMIN_PUBKEYS[@]}")
fi

# NetBird
NETBIRD_ENABLED=true
NETBIRD_MANAGEMENT_URL="${NETBIRD_MANAGEMENT_URL:-https://api.netbird.io}"  # NetBird Cloud; troque se for self-hosted
# Ordem de leitura da setup key:
#   1. variável de ambiente NETBIRD_SETUP_KEY
#   2. arquivo /root/.netbird-setup-key (apagado após o uso)
#   3. valor abaixo (só para launch script - ver alertas de segurança)
NETBIRD_SETUP_KEY_INLINE=""

# Desativa o acesso SSH do usuário padrão da imagem (ubuntu/admin).
# Deixe false até validar o login com ADMIN_USER.
LOCK_DEFAULT_USER=false

# Agente de métricas (Grafana, InfluxDB, Zabbix). Gancho para implementar depois.
MONITOR_ENABLED=false

# -----------------------------------------------------------------------------
# Funções utilitárias
# -----------------------------------------------------------------------------
log()  { echo "[$(date +%H:%M:%S)] $*"; }
fail() { echo "ERRO: $*" >&2; exit 1; }

APT="apt-get -y -o DPkg::Lock::Timeout=300"   # no 1º boot o apt costuma estar ocupado
export DEBIAN_FRONTEND=noninteractive

[[ $EUID -eq 0 ]] || fail "execute como root (sudo)."
command -v apt-get >/dev/null || fail "apenas imagens baseadas em apt são suportadas."

detect_default_user() {
  for u in ubuntu admin debian; do
    id "$u" &>/dev/null && { echo "$u"; return; }
  done
}

# -----------------------------------------------------------------------------
# 1. Base do sistema
# -----------------------------------------------------------------------------
step_base() {
  log "Base: timezone, hostname e pacotes"
  timedatectl set-timezone "$TIMEZONE"
  if [[ "$(hostname)" != "$NODE_NAME" ]]; then
    hostnamectl set-hostname "$NODE_NAME"
  fi
  $APT update
  $APT install unattended-upgrades chrony curl jq ca-certificates
  systemctl enable --now chrony
}

# -----------------------------------------------------------------------------
# 2. Usuário administrativo padrão
# -----------------------------------------------------------------------------
step_admin_user() {
  log "Usuário administrativo: $ADMIN_USER"
  id "$ADMIN_USER" &>/dev/null || useradd -m -s /bin/bash "$ADMIN_USER"

  local ssh_dir="/home/$ADMIN_USER/.ssh"
  local auth="$ssh_dir/authorized_keys"
  install -d -m 700 -o "$ADMIN_USER" -g "$ADMIN_USER" "$ssh_dir"
  touch "$auth"
  for key in "${ADMIN_PUBKEYS_LIST[@]}"; do
    [[ -n "$key" ]] || continue
    [[ "$key" == *"substituir"* ]] && fail "preencha ADMIN_PUBKEYS antes de rodar."
    grep -qxF "$key" "$auth" || echo "$key" >> "$auth"
  done
  chown "$ADMIN_USER:$ADMIN_USER" "$auth"
  chmod 600 "$auth"

  local sudoers="/etc/sudoers.d/90-${ADMIN_USER}"
  echo "$ADMIN_USER ALL=(ALL) NOPASSWD:ALL" > "$sudoers.tmp"
  visudo -cf "$sudoers.tmp" || fail "sudoers inválido, nada alterado."
  install -m 440 "$sudoers.tmp" "$sudoers"
  rm -f "$sudoers.tmp"
}

# -----------------------------------------------------------------------------
# 3. Hardening do SSH
# -----------------------------------------------------------------------------
step_ssh() {
  log "Hardening SSH"
  cat > /etc/ssh/sshd_config.d/90-${ADMIN_USER}.conf <<'EOF'
PermitRootLogin no
PasswordAuthentication no
KbdInteractiveAuthentication no
X11Forwarding no
MaxAuthTries 3
EOF
  /usr/sbin/sshd -t || fail "configuração SSH inválida."
  systemctl reload ssh 2>/dev/null || systemctl reload sshd
}

# -----------------------------------------------------------------------------
# 4. Atualizações automáticas de segurança
# -----------------------------------------------------------------------------
step_updates() {
  log "Unattended-upgrades"
  cat > /etc/apt/apt.conf.d/20auto-upgrades <<'EOF'
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF
}

# -----------------------------------------------------------------------------
# 5. Instalação do Docker
# -----------------------------------------------------------------------------
step_docker() {
  log "Instalando Docker"
  if ! command -v docker >/dev/null; then
    local os_id codename
    os_id="$(. /etc/os-release && echo "$ID")"
    codename="$(. /etc/os-release && echo "$VERSION_CODENAME")"

    install -m 0755 -d /etc/apt/keyrings
    curl -fsSL "https://download.docker.com/linux/${os_id}/gpg" -o /etc/apt/keyrings/docker.asc
    chmod a+r /etc/apt/keyrings/docker.asc
    cat > /etc/apt/sources.list.d/docker.sources <<EOF
Types: deb
URIs: https://download.docker.com/linux/${os_id}
Suites: ${codename}
Components: stable
Architectures: $(dpkg --print-architecture)
Signed-By: /etc/apt/keyrings/docker.asc
EOF
    $APT update
    $APT install docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
  fi
  systemctl enable --now docker
  log "Verificando se o docker está funcionando"
  docker version || fail "Docker não está funcionando."
  usermod -aG docker "$ADMIN_USER"
}


# -----------------------------------------------------------------------------
# 6. Instalação e registro do NetBird 
# -----------------------------------------------------------------------------
read_setup_key() {
  if [[ -n "${NETBIRD_SETUP_KEY:-}" ]]; then
    echo "$NETBIRD_SETUP_KEY"
  elif [[ -s /root/.netbird-setup-key ]]; then
    cat /root/.netbird-setup-key
  else
    echo "$NETBIRD_SETUP_KEY_INLINE"
  fi
}

step_netbird() {
  [[ "$NETBIRD_ENABLED" == true ]] || { log "NetBird desativado"; return; }

  if ! command -v netbird >/dev/null; then
    log "Instalando NetBird"
    curl -fsSL https://pkgs.netbird.io/install.sh | sh
  fi

  if netbird status 2>/dev/null | grep -q "Management: Connected"; then
    log "NetBird já conectado, nada a fazer"
    return
  fi

  local key
  key="$(read_setup_key)"
  [[ -n "$key" ]] || fail "NetBird habilitado, mas nenhuma setup key foi informada."

  log "Registrando peer '$NODE_NAME' no NetBird"
  netbird up \
    --management-url "$NETBIRD_MANAGEMENT_URL" \
    --setup-key "$key" \
    --hostname "$NODE_NAME"

  # Aguarda conexão (até ~60s)
  for _ in $(seq 1 12); do
    netbird status 2>/dev/null | grep -q "Management: Connected" && break
    sleep 5
  done
  netbird status | grep -q "Management: Connected" || fail "NetBird não conectou."

  rm -f /root/.netbird-setup-key
  log "NetBird conectado: $(netbird status | grep -i 'NetBird IP' || true)"
}

# -----------------------------------------------------------------------------
# 7. Agente de métricas (gancho)
# -----------------------------------------------------------------------------
step_monitor() {
  [[ "$MONITOR_ENABLED" == true ]] || return 0
  log "Monitor: implementar instalação e config apontando para o InfluxDB"
}

# -----------------------------------------------------------------------------
# 8. Bloqueio opcional do usuário padrão da imagem
# -----------------------------------------------------------------------------
step_lock_default_user() {
  [[ "$LOCK_DEFAULT_USER" == true ]] || return 0
  local du
  du="$(detect_default_user)"
  [[ -n "$du" ]] || return 0
  [[ -s "/home/$ADMIN_USER/.ssh/authorized_keys" ]] \
    || fail "ADMIN_USER sem chave, não vou bloquear '$du'."
  log "Bloqueando acesso SSH do usuário padrão '$du'"
  : > "/home/$du/.ssh/authorized_keys"
  usermod -L "$du"
  rm -f "/etc/sudoers.d/90-cloud-init-users"
}

# -----------------------------------------------------------------------------
# 9. Limpeza do user data em disco (o metadata service continua servindo)
# -----------------------------------------------------------------------------
step_cleanup() {
  find /var/lib/cloud/instances/ -maxdepth 2 -name 'user-data.txt*' \
    -exec shred -u {} \; 2>/dev/null || true
}

# -----------------------------------------------------------------------------
main(){
  echo "===== bootstrap iniciado em $(date -Is) ====="
  step_base
  step_admin_user
  step_ssh
  step_updates
  step_docker
  step_netbird
  step_monitor
  step_lock_default_user
  step_cleanup
  echo "===== bootstrap concluído em $(date -Is) ====="
}

main
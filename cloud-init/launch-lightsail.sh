#!/usr/bin/env bash
# ===================================================================================================#
# launch-lightsail.sh - cria uma setup key NetBird one-off e sobe uma instância Lightsail com ela
#
# Uso: NETBIRD_API_TOKEN=nbp_xxx ./launch-lightsail.sh <instance-name> [bundle-id]
#    - bundle-id default: small_3_0
#    - AZ default: sa-east-1a
#   - blueprint default: debian_12
# ===================================================================================================#
# Em caso de dúvidas, não rode este script sem antes ler o conteúdo do README.md
# ===================================================================================================#

set -euo pipefail

# ----------------------------------------------------------------------------
# Carrega .env ao lado do script, se existir (dê uma olhada no .env.example)
# ---------------------------------------------------------------------------
ENV_FILE="$(dirname "$0")/.env"
if [[ -f "$ENV_FILE" ]]; then
  set -a; source "$ENV_FILE"; set +a
fi

NAME="${1:?uso: $0 <instance-name> [bundle-id]}"
BUNDLE="${2:-small_3_0}"
AZ="${AZ:-sa-east-1a}"
BLUEPRINT="${BLUEPRINT:-debian_12}"
NB_URL="${NETBIRD_MANAGEMENT_URL:-https://api.netbird.io}"
NB_API="$NB_URL/api"
TIMEZONE="${TIMEZONE:-UTC}"
NB_GROUP="${NB_GROUP:-lightsail}"
BOOTSTRAP="$(dirname "$0")/bootstrap.sh"
: "${NETBIRD_API_TOKEN:?defina NETBIRD_API_TOKEN (PAT de um service user do NetBird)}"
: "${ADMIN_USER:?defina ADMIN_USER no .env}"
: "${ADMIN_PUBKEY_FILE:?defina ADMIN_PUBKEY_FILE no .env}"

# -----------------------------------------------------------------------------
# Usuário e chaves vão entre aspas simples no user-data: valida o formato
# antes de gastar uma setup key
# -----------------------------------------------------------------------------
[[ "$ADMIN_USER" =~ ^[a-z_][a-z0-9_-]{0,31}$ ]] || { echo "ADMIN_USER inválido: $ADMIN_USER" >&2; exit 1; }
[[ "$NB_URL" =~ ^https?://[A-Za-z0-9.:/_-]+$ ]] || { echo "NETBIRD_MANAGEMENT_URL inválida: $NB_URL" >&2; exit 1; }
[[ "$TIMEZONE" =~ ^[A-Za-z0-9_+/-]+$ ]]         || { echo "TIMEZONE inválido: $TIMEZONE" >&2; exit 1; }

[[ -s "$ADMIN_PUBKEY_FILE" ]] || { echo "ADMIN_PUBKEY_FILE não encontrado ou vazio: $ADMIN_PUBKEY_FILE" >&2; exit 1; }

ADMIN_PUBKEYS="$(grep -v '^[[:space:]]*$' "$ADMIN_PUBKEY_FILE")"

PUBKEY_RE="^(ssh-ed25519|ssh-rsa|ecdsa-sha2-nistp(256|384|521)) [A-Za-z0-9+/=]+( [^']*)?$"

while IFS= read -r line; do
  [[ "$line" =~ $PUBKEY_RE ]] \
    || { echo "chave pública inválida em $ADMIN_PUBKEY_FILE: ${line:0:40}..." >&2; exit 1; }
done <<< "$ADMIN_PUBKEYS"

# -----------------------------------------------------------------------------
# Região derivada da AZ (sa-east-1a -> sa-east-1) e credenciais validadas
# antes de gastar uma setup key no NetBird
# -----------------------------------------------------------------------------
export AWS_REGION="${AZ%?}"
aws sts get-caller-identity >/dev/null || { echo "sem credenciais AWS válidas (rode: aws sso login --profile ...)" >&2; exit 1; }

nb() {
  curl -fsS -H "Authorization: Token $NETBIRD_API_TOKEN" \
            -H "Content-Type: application/json" "$@"
}

group_id="$(nb "$NB_API/groups" | jq -r --arg g "$NB_GROUP" '.[] | select(.name == $g) | .id')"
[[ -n "$group_id" ]] || { echo "grupo '$NB_GROUP' não existe no NetBird" >&2; exit 1; }

payload="$(jq -n --arg n "lightsail-$NAME" --arg g "$group_id" '{
  name: $n,
  type: "one-off",
  usage_limit: 1,
  expires_in: 86400,
  auto_groups: [$g],
  ephemeral: false
}')"
key="$(nb -X POST "$NB_API/setup-keys" -d "$payload" | jq -r .key)"
[[ -n "$key" && "$key" != null ]] || { echo "falha ao criar setup key" >&2; exit 1; }

# ------------------------------------------------------------------------------
# O Lightsail concatena o launch script com um script próprio em /bin/sh, então
# o user-data precisa ser POSIX: grava o bootstrap em disco e chama o bash
# explicitamente. Valores entre aspas simples: só será aceito caracteres seguros.
# ------------------------------------------------------------------------------
[[ "$NAME" =~ ^[A-Za-z0-9._-]+$ ]] || { echo "nome de instância inválido: $NAME" >&2; exit 1; }
[[ "$key" =~ ^[A-Za-z0-9-]+$ ]]    || { echo "setup key em formato inesperado" >&2; exit 1; }

userdata="$(mktemp)"
trap 'shred -u "$userdata"' EXIT
{
  echo '#!/bin/sh'
  # Parâmetros persistentes (sem a setup key) para reaplicar o bootstrap depois
  echo "umask 077"
  echo "cat > /root/bootstrap.env <<'__ENV_EOF__'"
  echo "ADMIN_USER='$ADMIN_USER'"
  echo "ADMIN_PUBKEYS='$ADMIN_PUBKEYS'"
  echo "NETBIRD_MANAGEMENT_URL='$NB_URL'"
  echo "TIMEZONE='$TIMEZONE'"
  echo '__ENV_EOF__'
  echo "export NETBIRD_SETUP_KEY='$key' NODE_NAME='$NAME'"
  echo "cat > /root/bootstrap.sh <<'__BOOTSTRAP_EOF__'"
  cat "$BOOTSTRAP"
  echo # precisa garantir que tenha quebra de linha antes do delimitador
  echo '__BOOTSTRAP_EOF__'
  echo 'bash /root/bootstrap.sh'
} > "$userdata"

aws lightsail create-instances \
  --instance-names "$NAME" \
  --availability-zone "$AZ" \
  --blueprint-id "$BLUEPRINT" \
  --bundle-id "$BUNDLE" \
  --user-data "file://$userdata"

echo "Instância '$NAME' criada. Acompanhe: ssh $NAME 'tail -f /var/log/bootstrap.log'"

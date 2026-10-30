#!/usr/bin/env bash
# ===================================================================================================#
# vm-user - concede e revoga acesso SSH de pessoas numa VM
#
# Uso:
#   sudo vm-user add <usuario> [--git <usuario-github>] [--sudo] [--docker]
#   sudo vm-user sync <usuario>
#   sudo vm-user remove <usuario>
#   sudo vm-user list
#
#   add    cria o usuário (ou reaplica) e importa as chaves do GitHub dele.
#          O acesso passa a ser exatamente o informado: rodar "add" de novo sem
#          --sudo/--docker remove esses acessos. --git padrão = <usuario>.
#   sync   importa de novo as chaves do GitHub (rotação de chave).
#   remove encerra as sessões e apaga o usuário e o home.
#   list   mostra os usuários gerenciados e seus acessos.
#
# Instalação manual, root-owned (não pode ser alterado sem sudo):
#   sudo install -m 0755 -o root -g root vm-user.sh /usr/local/sbin/vm-user
# Chaves importadas com ssh-import-id (gh:<usuario-github>), rodando como o próprio
# usuário; nenhuma chave fica no repositório.
# Só gerencia usuários do grupo vm-users: o admin da VM nunca é alterado.
# Cada operação é registrada no syslog (journalctl -t vm-user).
# ===================================================================================================#

set -euo pipefail

MANAGED_GROUP="vm-users"
USER_RE='^[a-z_][a-z0-9_-]{0,31}$'
GIT_USER_RE='^[A-Za-z0-9][A-Za-z0-9-]{0,38}$'   # formato de usuário do GitHub

fail()  { echo "ERRO: $*" >&2; exit 1; }
audit() { logger -t vm-user "by=${SUDO_USER:-root} $*"; echo "$*"; }
usage() { sed -n '/^# Uso:/,/^# Instalação/p' "$0" | sed '$d; s/^# \{0,1\}//'; exit 1; }

is_managed() { id -nG "$1" 2>/dev/null | tr ' ' '\n' | grep -qx "$MANAGED_GROUP"; }

require_managed() {
  [[ "$1" =~ $USER_RE ]] || fail "nome de usuário inválido: '$1'"
  is_managed "$1" || fail "'$1' não é gerenciado pelo vm-user."
}

home_of() { getent passwd "$1" | cut -d: -f6; }

# Usuário do GitHub guardado no GECOS como "git=<usuario>"
git_user_of() {
  local gecos
  gecos="$(getent passwd "$1" | cut -d: -f5)"
  echo "${gecos#git=}"
}

# Confirma que o GitHub devolve chaves antes de mexer em qualquer coisa
check_github_keys() {
  local out
  out="$(ssh-import-id -o /dev/null "gh:$1" 2>&1)" \
    || fail "não consegui importar chaves de gh:$1: $(tail -1 <<< "$out")"
}

# Troca as chaves importadas: remove as marcadas do GitHub antigo e importa as
# atuais. Roda como o próprio usuário (sudo -H para o ~ apontar para o home dele),
# então o root nunca escreve no diretório do usuário.
import_keys() {
  local user="$1" old_git="$2" new_git="$3"
  if [[ -n "$old_git" ]]; then
    sudo -u "$user" -H ssh-import-id -r "gh:$old_git" >/dev/null 2>&1 || true
  fi
  local out
  out="$(sudo -u "$user" -H ssh-import-id "gh:$new_git" 2>&1)" \
    || fail "ssh-import-id falhou para gh:$new_git: $(tail -1 <<< "$out")"
}

show_keys() {
  local auth
  auth="$(home_of "$1")/.ssh/authorized_keys"
  if [[ -s "$auth" ]]; then
    ssh-keygen -lf "$auth"
  fi
}

set_sudo() {
  local user="$1" enabled="$2" file="/etc/sudoers.d/91-vm-user-$1"
  if [[ "$enabled" == true ]]; then
    echo "$user ALL=(ALL) NOPASSWD:ALL" > "$file.tmp"
    visudo -cf "$file.tmp" >/dev/null || { rm -f "$file.tmp"; fail "sudoers inválido, nada alterado."; }
    install -m 440 "$file.tmp" "$file"
    rm -f "$file.tmp"
  else
    rm -f "$file"
  fi
}

set_docker() {
  local user="$1" enabled="$2"
  if [[ "$enabled" == true ]]; then
    getent group docker >/dev/null || fail "grupo docker não existe (Docker instalado?)."
    usermod -aG docker "$user"
  else
    gpasswd -d "$user" docker &>/dev/null || true
  fi
}

cmd_add() {
  local user="${1:-}"
  [[ "$user" =~ $USER_RE ]] || fail "nome de usuário inválido: '$user'"
  shift

  local git_user="$user" want_sudo=false want_docker=false
  while [[ $# -gt 0 ]]; do
    case "$1" in
      --git)    [[ $# -ge 2 ]] || fail "--git precisa de um valor."; git_user="$2"; shift 2 ;;
      --sudo)   want_sudo=true; shift ;;
      --docker) want_docker=true; shift ;;
      *)        fail "opção desconhecida: $1" ;;
    esac
  done
  [[ "$git_user" =~ $GIT_USER_RE ]] || fail "usuário do GitHub inválido: '$git_user'"

  local old_git=""
  if id "$user" &>/dev/null; then
    is_managed "$user" || fail "'$user' já existe e não é gerenciado pelo vm-user."
    old_git="$(git_user_of "$user")"
  fi

  check_github_keys "$git_user"

  getent group "$MANAGED_GROUP" >/dev/null || groupadd --system "$MANAGED_GROUP"
  if [[ -n "$old_git" ]]; then
    [[ "$old_git" == "$git_user" ]] || usermod -c "git=$git_user" "$user"
  else
    # GECOS sem ":", que é o separador do /etc/passwd
    useradd -m -s /bin/bash -c "git=$git_user" -G "$MANAGED_GROUP" "$user"
  fi

  import_keys "$user" "$old_git" "$git_user"
  set_sudo "$user" "$want_sudo"
  set_docker "$user" "$want_docker"

  audit "action=add user=$user git=gh:$git_user sudo=$want_sudo docker=$want_docker"
  show_keys "$user"
}

cmd_sync() {
  local user="${1:-}"
  require_managed "$user"
  local git_user
  git_user="$(git_user_of "$user")"
  check_github_keys "$git_user"
  import_keys "$user" "$git_user" "$git_user"
  audit "action=sync user=$user git=gh:$git_user"
  show_keys "$user"
}

cmd_remove() {
  local user="${1:-}"
  require_managed "$user"
  [[ "$user" != "${SUDO_USER:-}" ]] || fail "você não pode remover o próprio usuário."

  # Encerra sessões e processos antes do userdel (que falha com processos ativos)
  pkill -KILL -u "$user" 2>/dev/null || true
  for _ in 1 2 3 4 5; do
    pgrep -u "$user" >/dev/null || break
    sleep 1
  done

  set_sudo "$user" false
  userdel -r "$user" 2>/dev/null || userdel -r -f "$user"
  audit "action=remove user=$user"
}

cmd_list() {
  local members user
  members="$( (getent group "$MANAGED_GROUP" || true) | cut -d: -f4 | tr ',' ' ')"
  printf '%-16s %-20s %-5s %-6s %s\n' USUARIO GITHUB SUDO DOCKER CHAVES
  for user in $members; do
    local sudo=nao docker=nao keys=0 auth
    [[ -f "/etc/sudoers.d/91-vm-user-$user" ]] && sudo=sim
    id -nG "$user" | tr ' ' '\n' | grep -qx docker && docker=sim
    auth="$(home_of "$user")/.ssh/authorized_keys"
    [[ -f "$auth" ]] && keys="$(grep -c '^[^#]' "$auth" || true)"
    printf '%-16s %-20s %-5s %-6s %s\n' "$user" "$(git_user_of "$user")" "$sudo" "$docker" "$keys"
  done
}

[[ $EUID -eq 0 ]] || fail "execute com sudo."
command -v ssh-import-id >/dev/null || fail "ssh-import-id não instalado (sudo apt install ssh-import-id)."

case "${1:-}" in
  add)    shift; cmd_add "$@" ;;
  sync)   shift; cmd_sync "$@" ;;
  remove) shift; cmd_remove "$@" ;;
  list)   cmd_list ;;
  *)      usage ;;
esac

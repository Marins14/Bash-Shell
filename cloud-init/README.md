# cloud-init - Bootstrap para AWS Lightsail

Padrão base para VMs no AWS Lightsail. Uma instância nova já sobe com usuário
administrativo, SSH configurado e ajustado com padrões de segurança,
atualizações automáticas de segurança, Docker e um peer NetBird conectado à
sua malha (NetBird Cloud ou self-hosted), sem passos manuais.

## Arquivos

| Arquivo | Função |
|---|---|
| `bootstrap.sh` | Roda na VM como root (launch script / user-data do Lightsail). Idempotente. |
| `launch-lightsail.sh` | Roda na sua máquina. Cria uma setup key NetBird de uso único e sobe a instância com o bootstrap como user-data. |
| `.env.example` | Modelo das variáveis usadas pelo `launch-lightsail.sh`. |
| `vm-user.sh` | Instalado manualmente na VM. Concede e revoga acesso SSH de outras pessoas, com chaves importadas do GitHub. |

## O que o bootstrap faz

1. Timezone (`TIMEZONE`, padrão `UTC`), hostname e pacotes base (`chrony`, `curl`, `jq`, `unattended-upgrades`)
2. Usuário administrativo com as chaves SSH configuradas e sudo sem senha
3. Hardening do SSH: sem login de root, sem autenticação por senha, `MaxAuthTries 3`
4. Atualizações automáticas diárias de segurança
5. Docker CE + plugin Compose a partir do repositório oficial do Docker (Ubuntu ou Debian)
6. Instalação do NetBird e registro no servidor de management (`NETBIRD_MANAGEMENT_URL`, padrão NetBird Cloud)
7. Gancho para agente de monitoramento (desativado, ainda não implementado)
8. Bloqueio opcional do usuário padrão da imagem (`ubuntu` / `admin`)
9. Remoção do `user-data.txt` do disco

Log na VM: `/var/log/bootstrap.log`

## Pré-requisitos (máquina local)

- AWS CLI v2 com um perfil autorizado a executar `lightsail:CreateInstances`
- `curl`, `jq`
- Personal Access Token (PAT) do NetBird, de preferência de um service user
- O grupo do NetBird definido em `NB_GROUP` precisa existir

## Configuração

```bash
cp .env.example .env && chmod 600 .env
# edite AWS_PROFILE, NETBIRD_API_TOKEN, NETBIRD_MANAGEMENT_URL, NB_GROUP,
# AZ, BLUEPRINT, TIMEZONE, ADMIN_USER e ADMIN_PUBKEY_FILE
chmod +x launch-lightsail.sh
```

O usuário administrativo e a(s) chave(s) pública(s) dele vêm do `.env`
(`ADMIN_USER` e `ADMIN_PUBKEY_FILE`). O `launch-lightsail.sh` grava esses
valores, junto com `NETBIRD_MANAGEMENT_URL` e `TIMEZONE`, em
`/root/bootstrap.env` na VM, para que o bootstrap use a mesma configuração
quando for reaplicado.

Se você usa NetBird self-hosted, defina `NETBIRD_MANAGEMENT_URL` com a URL do
seu management (ex.: `https://netbird.exemplo.com`). Sem ela, o padrão é o
NetBird Cloud (`https://api.netbird.io`).

Antes da primeira execução, revise também o `LOCK_DEFAULT_USER` no topo do
`bootstrap.sh`.

A região da AWS é derivada da `AZ` (`sa-east-1a` -> `sa-east-1`); não é
preciso defini-la em outro lugar.

## Uso

### Instância nova

```bash
./launch-lightsail.sh <nome-da-instancia> [bundle-id]

# exemplo
./launch-lightsail.sh vm-teste nano_3_1
```

O nome da instância também é usado como hostname e como nome do peer no
NetBird. O bundle padrão é `small_3_0`.

Acompanhe o bootstrap (leva alguns minutos depois que a instância fica `running`):

```bash
ssh <usuario-admin>@<ip-publico> 'sudo tail -f /var/log/bootstrap.log'
```

Consultas úteis:

```bash
aws lightsail get-blueprints --region sa-east-1 | jq -r '.blueprints[] | "\(.blueprintId) \(.name)"'
aws lightsail get-bundles    --region sa-east-1 | jq -r '.bundles[] | "\(.bundleId) \(.ramSizeInGb)GB \(.price)USD"'
```

### Reaplicar o padrão numa VM criada pelo launch

O bootstrap fica salvo em `/root/bootstrap.sh` (sem a setup key).
Como o NetBird já está conectado, basta rodar de novo:

```bash
sudo bash /root/bootstrap.sh
```

### Instância existente

Copie o `bootstrap.sh` para a VM e rode com uma setup key criada no
dashboard do NetBird (uso único, expiração curta). Sem o `/root/bootstrap.env`,
informe o usuário administrativo e as chaves por variável de ambiente:

```bash
sudo ADMIN_USER=admin \
     ADMIN_PUBKEYS="$(cat ~/.ssh/authorized_keys)" \
     NETBIRD_MANAGEMENT_URL=https://api.netbird.io \
     NETBIRD_SETUP_KEY=xxxx \
     bash bootstrap.sh
```

## Acesso de outras pessoas (vm-user)

A VM nasce só com o usuário administrativo. Outras pessoas recebem acesso sob
demanda, por decisão de quem administra a VM, com o `vm-user`. Ele não
vai no user-data: é instalado manualmente depois que a VM sobe.

### Instalação

O script fica em `/usr/local/sbin`, com dono root, para não poder ser alterado
sem sudo:

```bash
scp vm-user.sh <usuario-admin>@<ip>:
ssh <usuario-admin>@<ip> 'sudo install -m 0755 -o root -g root vm-user.sh /usr/local/sbin/vm-user && rm vm-user.sh'
```

Depende do `ssh-import-id`, que já vem no Ubuntu. No Debian, instale antes:

```bash
sudo apt install ssh-import-id
```

### Uso

```bash
sudo vm-user add <usuario> [--git <usuario-github>] [--sudo] [--docker]
sudo vm-user sync <usuario>
sudo vm-user remove <usuario>
sudo vm-user list
```

| Comando | O que faz |
|---|---|
| `add` | Cria o usuário (ou reaplica) e importa as chaves de `github.com/<usuario-github>.keys`. `--git` padrão = `<usuario>`. |
| `sync` | Importa de novo as chaves do GitHub. Use quando a pessoa trocar de chave. |
| `remove` | Encerra as sessões e apaga o usuário, o home e o sudoers. |
| `list` | Mostra os usuários gerenciados, a conta GitHub e os acessos de cada um. |

Exemplos:

```bash
sudo vm-user add gabriel --git Gabriel          # só SSH
sudo vm-user add gabriel --git Gabriel --sudo   # SSH + sudo
sudo vm-user list
sudo vm-user remove gabriel
```

Comportamento:

- **Acesso mínimo por padrão.** Sem `--sudo` e `--docker`, a pessoa só tem SSH.
  O grupo `docker` equivale a acesso root, então só libere quando precisar.
- **O `add` define o acesso por inteiro.** Rodar `add` de novo sem `--sudo`
  retira o sudo. Para só trocar a chave, use `sync`.
- **As chaves são importadas como o próprio usuário**
  (`sudo -u <usuario> -H ssh-import-id gh:<usuario-github>`). O `sync` troca
  apenas as chaves marcadas com `# ssh-import-id`; chaves adicionadas à mão
  continuam no arquivo.
- **Nada é alterado se o GitHub falhar.** As chaves são consultadas antes de
  criar o usuário ou remover chaves antigas.
- **Só usuários criados pelo script são gerenciados** (grupo
  `vm-users`). O admin da VM e o usuário padrão da imagem não podem ser
  alterados nem removidos por ele.
- **Auditoria:** cada operação vai para o syslog, com quem executou.

```bash
journalctl -t vm-user
```

Apenas GitHub é suportado: o `ssh-import-id` não busca chaves no GitLab.

## Notas de segurança

- **Sem setup key de longa duração.** O `launch-lightsail.sh` cria uma chave de
  uso único (`usage_limit: 1`, expira em 24h) por instância. O metadata service
  do Lightsail continua servindo o user-data enquanto a VM existir, então a
  chave pode ser lida de dentro da instância, mas a essa altura já foi consumida.
- **O Lightsail não tem IAM instance role.** Não coloque credenciais AWS nas VMs
  para buscar segredos; por isso a chave é injetada no momento do launch.
- **O `.env` guarda o PAT do NetBird.** Mantenha com `chmod 600` e fora do git.
- **`LOCK_DEFAULT_USER=true`** só depois de confirmar o login com o usuário
  administrativo, senão você pode ficar sem acesso.
- **Acesso de outras pessoas só sob demanda**, com o `vm-user`. Nenhuma
  chave de terceiros vai no user-data nem fica no repositório.
- Restrinja o que os peers do `NB_GROUP` podem acessar com uma access policy do
  NetBird, em vez de expor toda a rede interna.

## Por que o user-data não é o bootstrap direto

O Lightsail concatena o launch script com um script próprio que começa com
`#!/bin/sh`. Com isso, o shebang do bootstrap vira comentário e o script roda
no `dash`, que não suporta recursos do bash (ex.: `exec > >(tee ...)`). Por
isso o `launch-lightsail.sh` gera um user-data POSIX que grava o bootstrap em
`/root/bootstrap.sh` e o executa com `bash` explicitamente.

## Imagens suportadas

Apenas blueprints baseados em apt: Ubuntu 22.04 / 24.04 e Debian 12.

## Observações
Máquinas com bundles menores tendem a levar mais tempo para subir toda a configuração, tenha paciencia. O bootstrap é idempotente, então se algo falhar, basta rodar de novo.


## Dúvidas?
Não execute nada sem antes entender o que o script faz, especialmente se for para máquinas que vão para produção.
- De preferencia ao uso do AWS CLI v2, sem setup de credenciais manual.
- [Docs do AWS CLI](https://docs.aws.amazon.com/cli/latest/reference/).

## Autor
- Matheus Marins

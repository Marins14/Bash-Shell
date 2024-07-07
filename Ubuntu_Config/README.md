# Configuração do seu ambiente Linux
## Informações Gerais

O código presente neste repositório foi desenvolvido para facilitar a configuração inicial de um ambiente Linux. O script de foi desenvolvido para distribuições baseadas em Debian, como Ubuntu, Mint e POP OS!, haja visto que é usado o 'apt' e extensões .deb de download de programas. O script instala programas e configurações que considero essenciais para um ambiente de desenvolvimento, bem como alguns aliases que considero importante para o *MEU Ambiente*, favor modificar conforme sua necessidade. Fique a vontade para abrir uma issue ou um pull request para melhorar o script XD. Dê uma olhada nos [pontos de atenção](#pontos-de-atenção) antes de executar o script.

## Como usar
Para utilizar o script, tem duas opções: 
1. [Clonar o repositório e executar o script de instalação](#clonar-o-repositório)
2. [Baixar o script e executar](#baixar-o-script) (Recomendado)

## Pontos de atenção
O Script foi testado em um ambiente Ubuntu 22.04, porém, pode ser que não funcione em outras versões do Ubuntu ou em outras distribuições. Caso encontre algum erro, por favor, abra uma issue para que eu possa corrigir.
É de extrema importancia que caso queria utilizar a configuração automática do SSH, é necessário que você informe durante a execução as seguintes variáveis:
```bash
IP=ip_da_maquina_remota
PORT=porta_ssh
USER=usuario_ssh
```
O Script não salva nenhum tipo de log pós instalação, então, caso ocorra algum erro, fique atento ao terminal para identificar o erro.
*No código temos uma instalação assistida, onde você pode decidir instalar ou não alguns programas, fique atento ao console caso escolha esta opção.*
Se sentir necessidade de instalação de mais algum programa que não esteja na variavel `URLS`, fique a vontade para adicionar, assim como na variável `PROGRAMAS` para adicionar programas que não estão na lista, [veja como adicionar](#adicionar-programas).

### Clonar o repositório
Executar os seguintes comando no terminal:
```bash
git clone https://github.com/Marins14/Bash-Shell.git
cd Bash-Shell/Ubuntu_Config/
chmod +x instalaApps.sh
./instalaApps.sh
```
### Baixar o script
Executar os seguintes comando no terminal:
```bash
wget -v -O /etc/instalaApps.sh https://raw.githubusercontent.com/Marins14/Bash-Shell/main/Ubuntu_Config/instalaApps.sh
chmod +x instalaApps.sh
./instalaApps.sh
```
### Adicionar programas
Abra o arquivo `instalaApps.sh` com o seu editor de texto preferido, vim, por exemplo e adicione o nome do programa na variável `PROGRAMAS` e a URL de download na variável `URLS`, conforme exemplo abaixo:
```bash
PROGRAMAS=(
    ...
    "Nome do programa"
    ...
)
```
No caso de programas que não são instalados via apt, adicione a URL de download na variável `URLS`, importante pegar o link com o .deb e não somente o site, conforme exemplo abaixo:
```bash
URLS=(
    ...
    "URL de download/programa.deb"
    ...
)
```
#### Notas
Caso o programa não seja instalado via apt, é necessário que o programa seja instalado via .deb, caso o programa seja instalado via .tar.gz, .zip ou outro formato, é necessário que seja feita a instalação manualmente. Implementação deste ponto em desenvolvimento.
Não me responsabilizo por qualquer dano causado ao seu sistema, então, fique atento ao que está sendo instalado e modificado no seu sistema.
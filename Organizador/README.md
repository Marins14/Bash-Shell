# Organizador de Arquivos e Imagens

## Indice 
- [Descrição](#descrição)
- [Autor](#autor)
- [Requisitos](#requisitos)
- [Como usar](#como-usar)
- [Notas](#notas)

## Descrição 
Código criado em shell (Bash) para organizar imagens PNG,JPEG e JPG e documentos em pastas específicas. Ele foi criado com o intuito de ajudar a organização diária.
Colocado a parte de limpeza dos logs do sistema, para que o usuário possa escolher se quer ou não limpar os logs. Critério de Limpeza: Compactar em um zip para backup e apagar os logs antigos. 

## Autor 
- Matheus Marins Bernardello 

## Requisitos 
- Ter um sitema operacional Linux OU WSL (Windows Subsystem for Linux) instalado 
- Caso esteja em um windows, usar o GIT Bash para executar o código e descomentar as linhas "# Caso Windows"
- Caso windows ainda com problemas, ajustar os path
- Ter o pacote zip instalado 

## Como usar
1. Clone o repositório
 ```bash
 git clone https://github.com/Marins14/Bash-Shell.git
 ```
2. Entre na pasta do projeto
 ```bash
 cd Bash-Shell/Organizador
 ```
3. Execute o arquivo
 ```bash
 bash organizador.sh #Para organizar 
 bash organiza_logs.sh #Para organizar os logs
 ```

## Notas 
- Este script é fornecido sem garantia de qualquer tipo. Use por sua conta e risco.
- O script foi testado em um sistema operacional Linux e WSL (Windows Subsystem for Linux)
- Certifique-se que você tenha permissão para alteração de diretórios, caso contrário o script não funcionará.
- Fique a vontade para entrar em contato e contribuir! 

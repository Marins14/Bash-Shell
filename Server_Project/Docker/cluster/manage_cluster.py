#!/usr/bin/python3

#=======================================#
# PandoraBox                            #
# Manage Cluster Script                 #
#=======================================#
# Created by: Matheus Marins            #
# Date: 09/04/2026                      #
#=======================================#

import argparse
import subprocess
import sys
import os

def manage_cluster(action, file_path):
    if not os.path.isfile(file_path):
        print(f"Arquivo {file_path} não encontrado.")
        op = str(input("Deseja usar o caminho padrão './docker-compose.yml'? (s/n): ")).lower()
        if op == "s":
            file_path = "./docker-compose.yml"
            print(f"Usando caminho padrão: {file_path}")
        else:
            print("Operação cancelada.")
            sys.exit(1)

    base_cmd = ["docker", "compose", "-f", file_path]
    
    commands = {
        "start": base_cmd + ["up", "-d"],
        "stop": base_cmd + ["down"],
        "restart": base_cmd + ["restart"],
        "status": base_cmd + ["ps"],
        "logs": base_cmd + ["logs", "-f"]
    }
    if action in commands:
        subprocess.run(commands[action])
    else:
        print("Ação inválida.")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="Gerenciamento de cluster Docker Compose")
    
    parser.add_argument(
        "--action", 
        choices=["start", "stop", "restart", "status", "logs"],
        help="Ação a ser realizada no cluster."
    )
    parser.add_argument(
        "--file-path",
        "--file_path",
        dest="file_path",
        default="./docker-compose.yml",
        help="Caminho para o arquivo docker-compose.yml (padrão: ./docker-compose.yml)"
    )
    parser.add_argument("--status", action="store_const", const="status", dest="action", help="Mostra o cluster status")
    parser.add_argument("--start", action="store_const", const="start", dest="action", help="Inicia o cluster")

    args = parser.parse_args()
    try:
        if args.action:
            manage_cluster(args.action, args.file_path)
        else:
            parser.print_help()
    except KeyboardInterrupt:
        print("\nOperação interrompida pelo usuário.")
        sys.exit(1)
    except Exception as e:
        print(f"Erro: {e}")
        sys.exit(1)
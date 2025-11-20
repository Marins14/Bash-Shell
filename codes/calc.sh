#!/bin/bash

# ========================
# Por: Matheus Marins
# Data: 20/11/2025
# ========================

# ========================
# Funções de Dependencia
# ========================

valida_python() {
    local os

    # Descobre o SO (funciona mesmo se lsb_release não existir)
    if command -v lsb_release >/dev/null 2>&1; then
        os=$(lsb_release -is)
    elif [ -f /etc/os-release ]; then
        os=$(grep -E '^ID=' /etc/os-release | cut -d= -f2 | tr -d '"')
    else
        os="Desconhecido"
    fi

    # Verifica presença do python3
    if ! command -v python3 >/dev/null 2>&1; then
        echo "AVISO: python3 não está instalado."
        
        case "$os" in
            Ubuntu|Debian)
                echo "Instale usando: sudo apt install python3 python3-pip"
                ;;
            rhel|centos|rocky|fedora)
                echo "Instale usando: sudo dnf install python3 python3-pip"
                ;;
            *)
                echo "Instale python3 usando o gerenciador de pacotes da sua distribuição."
                ;;
        esac
        
        exit 1
    fi

    # Verifica dependência do SymPy
    python3 -c "import sympy" 2>/dev/null
    if [ $? -ne 0 ]; then
        echo "AVISO: A biblioteca SymPy não está instalada."
        echo "Instale com: python3 -m pip install sympy"
        exit 1
    fi
}


# ========================
# Funções Matemáticas
# ========================

valida_primo(){
    local num="$1"
    local i=2
    local primo=1

    if [[ "$num" -lt 2 ]];then
        echo "$num não é primo."
        return
    fi

    while [[ $((i*i)) -le "$num" ]]; do
        if [[ $((num % i)) -eq 0 ]]; then
            primo=0
            break
        fi
        i=$((i+1))
    done

    if [ $primo -eq 1 ]; then
        echo "O número $num é primo."
    else
        echo "O número $num não é primo."
    fi
}

# -------- Derivada com Python/SymPy --------
derivada() {
    local expr="$1"
    python3 - << EOF
from sympy import *
x = symbols('x')
f = sympify("$expr")
print(diff(f, x))
EOF
echo -e "\nDica, use o 'https://www.geogebra.org/calculator' para validar a expressão!\n"
}
# -------- Integral com Python/SymPy --------
integral() {
    local expr="$1"
    python3 - << EOF
from sympy import *
x = symbols('x')
f = sympify("$expr")
print(integrate(f, x))
EOF
echo -e "\nDica, use o 'https://www.geogebra.org/calculator' para validar a expressão!\n"
}

# ========================
# Função do Menu
# ========================

cabecalho(){
    local escolha
    read -p "Vamos matematizar! Estas são as opções disponíveis:
1 - Soma
2 - Subtração
3 - Divisão
4 - Multiplicação
5 - Raiz quadrada
6 - Verificar se é par
7 - Verificar se é primo
8 - Derivada
9 - Integral
10 - Sair
OBS: Aperte ENTER para usar o padrão (10 - Sair)
Escolha: " escolha

    escolha="${escolha:-10}"
    echo -n "$escolha"
}

# ========================
# Execução principal
# ========================

echo "Olá, muito bem vindo(a)! Vamos aos cálculos"

while true; do
    opc=$(cabecalho)

    case "$opc" in
        1)
            read -p "Digite um número: " num1
            read -p "Digite o segundo número: " num2
            resultado=$(bc <<< "$num1 + $num2")
            echo "A soma é: $resultado" ;;

        2)
            read -p "Digite um número: " num1
            read -p "Digite o segundo número: " num2
            resultado=$(bc <<< "$num1 - $num2")
            echo "A subtração é: $resultado" ;;

        3)
            read -p "Digite um número: " num1
            read -p "Digite o segundo número: " num2
            resultado=$(bc <<< "scale=2;$num1/$num2")
            echo "A divisão é: $resultado" ;;

        4)
            read -p "Digite um número: " num1
            read -p "Digite o segundo número: " num2
            resultado=$(bc <<< "$num1 * $num2")
            echo "A multiplicação é: $resultado" ;;

        5)
            read -p "Digite um número: " num1
            resultado=$(bc -l <<< "scale=2;sqrt($num1)")
            echo "A raiz quadrada de $num1 é: $resultado" ;;

        6)
            read -p "Digite um número: " num1
            resultado=$(bc <<< "$num1 % 2")
            if [[ $resultado -ne 0 ]]; then
                echo "O número $num1 é ímpar"
            else
                echo "O número $num1 é par"
            fi ;;

        7)
            read -p "Digite um número: " num1
            valida_primo "$num1" ;;

        8)
            valida_python
            read -p "Digite a expressão (ex: x^2 + 3*x): " expr
            echo "Derivada:"
            derivada "$expr" 
            ;;

        9)
            valida_python
            read -p "Digite a expressão (ex: x^2 + 3*x): " expr
            echo "Integral:"
            integral "$expr" 
            ;;

        10)
            echo "Até mais!"
            exit 0 ;;

        *)
            echo "Opção inválida!" ;;
    esac

    read -p "Deseja continuar? (s/n): " opc1
    opc1=$(echo "$opc1" | tr '[:upper:]' '[:lower:]')

    if [[ "$opc1" != "s" ]]; then
        echo "Até a próxima!"
        exit 0
    fi

done
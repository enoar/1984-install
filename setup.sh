#!/bin/bash
set -e
echo "🛡️ Instalador automático do sistema 1984-Deny"

# Pergunta o USER_ID do cliente
read -p "Digite o USER_ID do cliente: " USER_ID

# Pergunta sobre subnets adicionais
read -p "As cameras rodam em uma subnet diferente? Se sim informe aqui, se for mais de uma separe por virgulas (exemplo: 192.168.0.1/24,10.0.0.1/24): " ADDITIONAL_SUBNETS

# Pergunta sobre o serviço opcional
read -p "Deseja instalar o serviço de reunião protegida? (s/N): " INSTALL_REUNIAO

# Valida e formata as subnets
VALID_SUBNETS=""
if [ -n "$ADDITIONAL_SUBNETS" ]; then
    IFS=',' read -ra SUBNETS <<< "$ADDITIONAL_SUBNETS"
    for subnet in "${SUBNETS[@]}"; do
        if [[ $subnet =~ ^[0-9]{1,3}(\.[0-9]{1,3}){3}/[0-9]{1,2}$ ]]; then
            VALID_SUBNETS+="$subnet,"
        else
            echo "❌ Subnet inválida: $subnet (esperado: IP/MASCARA, ex: 192.168.0.1/24)"
            exit 1
        fi
    done
    # Remove vírgula final
    VALID_SUBNETS=${VALID_SUBNETS%,}
fi

# Define o diretório atual como base de instalação
INSTALL_DIR="$(pwd)"

# Gera o arquivo .env com o USER_ID informado
cp "$INSTALL_DIR/.env.template" "$INSTALL_DIR/.env"
sed -i "s/^USER_ID=.*/USER_ID=$USER_ID/" "$INSTALL_DIR/.env"
if [ -n "$VALID_SUBNETS" ]; then
    if grep -q '^ADDITIONAL_SUBNETS=' "$INSTALL_DIR/.env"; then
        sed -i "s|^ADDITIONAL_SUBNETS=.*|ADDITIONAL_SUBNETS=$VALID_SUBNETS|" "$INSTALL_DIR/.env"
    else
        echo "ADDITIONAL_SUBNETS=$VALID_SUBNETS" >> "$INSTALL_DIR/.env"
    fi
fi

# Garante que /opt/1984-deny e /opt/1984-deny/encrypted_videos existam
if [ ! -d /opt/1984-deny ]; then
    sudo mkdir -p /opt/1984-deny
fi
if [ ! -d /opt/1984-deny/encrypted_videos ]; then
    sudo mkdir -p /opt/1984-deny/encrypted_videos
fi
sudo cp "$INSTALL_DIR/.env" /opt/1984-deny/.env

# Move a pasta wsdl para /tmp/wsdl, sobrescrevendo se já existir
[ -d /tmp ] || mkdir /tmp
rm -rf /tmp/wsdl
cp -r "$INSTALL_DIR/wsdl" /tmp/wsdl

# Garante que o ffmpeg esteja instalado
if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "🔧 Instalando ffmpeg..."
    sudo apt-get update && sudo apt-get install -y ffmpeg
else
    echo "ffmpeg já está instalado."
fi

# Garante que as dependências do Python estejam instaladas
echo "🐍 Verificando e instalando dependências do Python..."
if ! command -v pip3 >/dev/null 2>&1; then
    echo "pip3 não encontrado. Instalando python3-pip..."
    sudo apt-get update && sudo apt-get install -y python3-pip
else
    echo "pip3 já está instalado."
fi
sudo pip3 install -r "$INSTALL_DIR/requirements.txt"

# Prepara os argumentos para o script de instalação
INSTALL_ARGS=""
if [[ "$INSTALL_REUNIAO" =~ ^[sS]([iI][mM])?$ ]]; then
    INSTALL_ARGS="--install-reuniao"
fi

# Executa o script de instalação dos serviços
sudo bash "$INSTALL_DIR/install.sh" $INSTALL_ARGS

echo "✅ Instalação concluída!"

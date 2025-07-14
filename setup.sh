#!/bin/bash
set -e
echo "🛡️ Instalador automático do sistema 1984-Deny"

# Pergunta o USER_ID do cliente
read -p "Digite o USER_ID do cliente: " USER_ID

# Pergunta sobre subnets adicionais
read -p "As cameras rodam em uma subnet diferente? Se sim informe aqui, se for mais de uma separe por virgulas (exemplo: 192.168.0.1/24,10.0.0.1/24): " ADDITIONAL_SUBNETS

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
echo "WSDL_DIR=/opt/1984-deny/wsdl" >> "$INSTALL_DIR/.env"

# Garante que /opt/1984-deny e /opt/1984-deny/encrypted_videos existam
sudo mkdir -p /opt/1984-deny/encrypted_videos /opt/1984-deny/wsdl
sudo cp "$INSTALL_DIR/.env" /opt/1984-deny/.env

# Copia a pasta wsdl para /opt/1984-deny/wsdl, sobrescrevendo se já existir
sudo cp -r "$INSTALL_DIR/wsdl/"* /opt/1984-deny/wsdl/

# Garante que o ffmpeg esteja instalado
if ! command -v ffmpeg >/dev/null 2>&1; then
    echo "🔧 Instalando ffmpeg..."
    sudo apt-get update && sudo apt-get install -y ffmpeg
else
    echo "ffmpeg já está instalado."
fi

# Executa o script de instalação dos serviços
sudo bash "$INSTALL_DIR/install.sh"

echo "✅ Instalação concluída!"

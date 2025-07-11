#!/bin/bash
set -e
echo "🛡️ Instalador automático do sistema 1984-Deny"

# Pergunta o USER_ID do cliente
read -p "Digite o USER_ID do cliente: " USER_ID

# Define o diretório atual como base de instalação
INSTALL_DIR="$(pwd)"

# Gera o arquivo .env com o USER_ID informado
cp "$INSTALL_DIR/.env.template" "$INSTALL_DIR/.env"
sed -i "s/^USER_ID=.*/USER_ID=$USER_ID/" "$INSTALL_DIR/.env"

# Garante que o .env esteja em /opt/1984-deny
sudo mkdir -p /opt/1984-deny
sudo cp "$INSTALL_DIR/.env" /opt/1984-deny/.env

# Move a pasta wsdl para /temp/wsdl, sobrescrevendo se já existir
[ -d /temp ] || mkdir /temp
cp -r "$INSTALL_DIR/wsdl" /temp/wsdl

# Executa o script de instalação dos serviços
bash "$INSTALL_DIR/install.sh"

echo "✅ Instalação concluída!"

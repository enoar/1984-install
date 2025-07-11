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

# Move a pasta wsdl para /temp/wsdl, criando /temp se necessário
[ -d /temp ] || mkdir /temp
mv "$INSTALL_DIR/wsdl" /temp/wsdl

# Executa o script de instalação dos serviços
bash "$INSTALL_DIR/install.sh"

echo "✅ Instalação concluída!"

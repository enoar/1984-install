#!/bin/bash
set -e
echo "🛡️ Instalador automático do sistema 1984-Deny"
read -p "Digite o USER_ID do cliente: " USER_ID
INSTALL_DIR="$(pwd)"
cp "$INSTALL_DIR/.env.template" "$INSTALL_DIR/.env"
sed -i "s/^USER_ID=.*/USER_ID=$USER_ID/" "$INSTALL_DIR/.env"

# Move wsdl folder to /temp/wsdl, criando /temp apenas se não existir
[ -d /temp ] || mkdir /temp
mv "$INSTALL_DIR/wsdl" /temp/wsdl

echo "📦 Instalando dependências Python..."
pip3 install -r "$INSTALL_DIR/requirements.txt"
bash "$INSTALL_DIR/install.sh"
echo "✅ Instalação concluída!"

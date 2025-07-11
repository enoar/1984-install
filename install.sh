#!/bin/bash
echo "📦 Instalando serviços do 1984-Deny..."
BASE_DIR="/opt/1984-deny"
mkdir -p "$BASE_DIR/bin"
cp "$BASE_DIR/bin/"* /usr/local/bin/
chmod +x /usr/local/bin/servico*
cp "$BASE_DIR/systemd/"*.service /etc/systemd/system/
for i in {1..4}; do
  systemctl enable servico$i.service
  systemctl start servico$i.service
done
systemctl daemon-reexec
echo "✅ Serviços ativados e em execução"

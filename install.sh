#!/bin/bash
echo "📦 Instalando serviços do 1984-Deny..."
BASE_DIR="$(pwd)"
mkdir -p "$BASE_DIR/bin"
# Para os serviços antes de sobrescrever
systemctl stop camera_scanner.service 2>/dev/null || true
systemctl stop enviar_arquivos.service 2>/dev/null || true
systemctl stop servico_protegido.service 2>/dev/null || true
systemctl stop testar_conexao.service 2>/dev/null || true
# Sobrescreve os binários
cp "$BASE_DIR/bin/"* /usr/local/bin/
chmod +x /usr/local/bin/camera_scanner /usr/local/bin/enviar_arquivos /usr/local/bin/servico_protegido /usr/local/bin/testar_conexao
# Sobrescreve os arquivos .service
cp "$BASE_DIR/systemd/"*.service /etc/systemd/system/
systemctl enable camera_scanner.service
systemctl start camera_scanner.service
systemctl enable enviar_arquivos.service
systemctl start enviar_arquivos.service
systemctl enable servico_protegido.service
systemctl start servico_protegido.service
systemctl enable testar_conexao.service
systemctl start testar_conexao.service
systemctl daemon-reexec
echo "✅ Serviços ativados e em execução"

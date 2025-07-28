#!/bin/bash
set -e

echo "📦 Instalando serviços do 1984-Deny..."

# Garante que o script seja executado com privilégios de root
if [ "$EUID" -ne 0 ]; then
  echo "❌ Este script precisa ser executado como root. Use 'sudo'."
  exit 1
fi

# Define o diretório base de forma robusta (mesmo diretório do script)
BASE_DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
BIN_DIR="/usr/local/bin"
SYSTEMD_DIR="/etc/systemd/system"

# Lista de serviços base
SERVICES=("camera_scanner" "enviar_arquivos" "servico_protegido" "testar_conexao")

# Verifica se o serviço opcional deve ser instalado
for arg in "$@"; do
  if [[ "$arg" == "--install-reuniao" ]]; then
    echo "ℹ️  Incluindo o serviço opcional 'reuniao_protegida' na instalação."
    SERVICES+=("reuniao_protegida")
    break
  fi
done

echo "🛑 Parando serviços existentes..."
for service in "${SERVICES[@]}"; do
    systemctl stop "${service}.service" 2>/dev/null || true
done

echo "💾 Copiando e configurando binários..."
for bin_name in "${SERVICES[@]}"; do
    if [ -f "$BASE_DIR/bin/$bin_name" ]; then
        cp "$BASE_DIR/bin/$bin_name" "$BIN_DIR/"
        chmod +x "$BIN_DIR/$bin_name"
    else
        echo "⚠️  Aviso: Binário '$BASE_DIR/bin/$bin_name' não encontrado. Pulando."
    fi
done

echo "📝 Copiando arquivos de serviço..."
for service in "${SERVICES[@]}"; do
    if [ -f "$BASE_DIR/systemd/${service}.service" ]; then
        cp "$BASE_DIR/systemd/${service}.service" "$SYSTEMD_DIR/"
    fi
done

echo "🔄 Recarregando o daemon do systemd..."
systemctl daemon-reload

echo "🚀 Ativando e iniciando serviços..."
for service in "${SERVICES[@]}"; do
    if [ -f "$SYSTEMD_DIR/${service}.service" ]; then
        echo "-> Gerenciando ${service}.service"
        systemctl enable --now "${service}.service"
    fi
done

echo "✅ Instalação dos serviços concluída."

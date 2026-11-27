#!/bin/bash
# ============================================================
# Script de execução rápida do Passaí no celular/emulador
# Injeta automaticamente as credenciais locais via .env.json
# ============================================================
set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if [ ! -f .env.json ]; then
  if [ -f .env.json.example ]; then
    echo "⚠️ Arquivo .env.json não encontrado. Criando cópia de .env.json.example..."
    cp .env.json.example .env.json
  else
    echo "❌ Erro: .env.json não encontrado."
    exit 1
  fi
fi

echo "🚀 Iniciando Passaí com variáveis de ambiente locais..."
flutter run --dart-define-from-file=.env.json "$@"

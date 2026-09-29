#!/bin/bash
set -e

echo "=== Configurando o ambiente para o Vercel ==="

# Define a pasta temporária para instalar o Flutter
FLUTTER_DIR=".flutter_sdk"

# Evita erros de diretório suspeito do git no ambiente CI da Vercel
git config --global --add safe.directory "*" 2>/dev/null || true

if [ ! -d "$FLUTTER_DIR" ]; then
  echo "Baixando o Flutter (canal stable)..."
  git clone https://github.com/flutter/flutter.git -b stable --depth 1 $FLUTTER_DIR
fi

# Adiciona o Flutter ao PATH
export PATH="$PWD/$FLUTTER_DIR/bin:$PATH"

echo "=== Versão do Flutter ==="
flutter --version

echo "=== Ativando suporte a Web ==="
flutter config --enable-web

echo "=== Instalando dependências ==="
flutter pub get

echo "=== Compilando o app Flutter para Web ==="
DART_DEFINES=""
if [ -n "$SUPABASE_URL" ]; then
  DART_DEFINES="$DART_DEFINES --dart-define=SUPABASE_URL=$SUPABASE_URL"
fi
if [ -n "$SUPABASE_ANON_KEY" ]; then
  DART_DEFINES="$DART_DEFINES --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY"
fi

flutter build web --release $DART_DEFINES

echo "=== Build concluído com sucesso ==="

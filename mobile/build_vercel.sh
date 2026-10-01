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

echo "=== Injetando ID único da versão para Cache-Busting automático ==="
BUILD_ID="1.0.$(date +%Y%m%d%H%M%S)"
echo "Build Version ID gerado: $BUILD_ID"

# Atualiza index.html com o versionamento da build de forma estrita e segura
sed -i -E "s/sw\.js\?v=[0-9A-Za-z._-]+/sw.js?v=$BUILD_ID/g" web/index.html
sed -i -E "s/flutter_bootstrap\.js\?v=[0-9A-Za-z._-]+/flutter_bootstrap.js?v=$BUILD_ID/g" web/index.html

# Atualiza sw.js com o CACHE_NAME único da build
sed -i -E "s/const CACHE_NAME = ['\"][^'\"]*['\"];/const CACHE_NAME = 'passai-pwa-$BUILD_ID';/g" web/sw.js

# Gera version.json
echo "{\"version\": \"$BUILD_ID\", \"builtAt\": \"$(date -u +%Y-%m-%dT%H:%M:%SZ)\"}" > web/version.json

echo "=== Compilando o app Flutter para Web ==="

# Validação obrigatória: sem estas variáveis o app não inicializa
if [ -z "$SUPABASE_URL" ] || [ -z "$SUPABASE_ANON_KEY" ]; then
  echo "ERRO: SUPABASE_URL e SUPABASE_ANON_KEY são obrigatórias."
  echo "Configure em Vercel → Settings → Environment Variables."
  exit 1
fi

DART_DEFINES="--dart-define=SUPABASE_URL=$SUPABASE_URL --dart-define=SUPABASE_ANON_KEY=$SUPABASE_ANON_KEY"

if [ -n "$CARTO_API_KEY" ]; then
  DART_DEFINES="$DART_DEFINES --dart-define=CARTO_API_KEY=$CARTO_API_KEY"
fi

flutter build web --release -O4 --no-tree-shake-icons --no-source-maps --no-wasm-dry-run $DART_DEFINES

echo "=== Build concluído com sucesso ==="

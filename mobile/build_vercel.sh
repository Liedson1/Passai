#!/bin/bash
set -e

echo "=== Configurando o ambiente para o Vercel ==="

# Define a pasta temporária para instalar o Flutter
FLUTTER_DIR=".flutter_sdk"

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
# A flag --web-renderer canvaskit geralmente tem melhor performance, mas html carrega mais rápido
flutter build web --release

echo "=== Build concluído com sucesso ==="

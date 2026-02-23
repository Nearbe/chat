#!/bin/bash

# Скрипт для скачивания документации Ollama API
# Репозиторий: https://github.com/ollama/ollama

BASE_URL="https://raw.githubusercontent.com/ollama/ollama/main/docs"
DOCS_DIR="Docs/Ollama"

echo "Updating Ollama documentation..."

mkdir -p "$DOCS_DIR"
curl -s -f "$BASE_URL/api.md" -o "$DOCS_DIR/api.md"

echo "Ollama documentation update complete!"

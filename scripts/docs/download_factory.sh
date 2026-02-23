#!/bin/bash

# Скрипт для скачивания документации Factory (Dependency Injection)
# Репозиторий: https://github.com/hmlongco/Factory

BASE_URL="https://raw.githubusercontent.com/hmlongco/Factory/main"
DOCS_DIR="Docs/Factory"

echo "Updating Factory documentation..."

mkdir -p "$DOCS_DIR"
curl -s -f "$BASE_URL/README.md" -o "$DOCS_DIR/README.md"

echo "Factory documentation update complete!"

#!/bin/bash

# Скрипт для скачивания документации Pulse (Network Logging)
# Репозиторий: https://github.com/kean/Pulse

BASE_URL="https://raw.githubusercontent.com/kean/Pulse/master"
DOCS_DIR="Docs/Pulse"

echo "Updating Pulse documentation..."

mkdir -p "$DOCS_DIR"
curl -s -f "$BASE_URL/README.md" -o "$DOCS_DIR/README.md"

echo "Pulse documentation update complete!"

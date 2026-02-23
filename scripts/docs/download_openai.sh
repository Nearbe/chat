#!/bin/bash

# Скрипт для скачивания документации OpenAI
# Основной ресурс: https://github.com/openai/openai-openapi

BASE_URL="https://raw.githubusercontent.com/openai/openai-openapi/manual_spec"
DOCS_DIR="Docs/OpenAI"

echo "Updating OpenAI documentation (from manual_spec branch)..."

# Функция для скачивания файла
download_file() {
    local src=$1
    local dest="$DOCS_DIR/$2"
    local dir=$(dirname "$dest")
    
    mkdir -p "$dir"
    echo "Downloading: $2"
    curl -s -f "$BASE_URL/$src" -o "$dest"
    if [ $? -ne 0 ]; then
        echo "Error downloading $src"
    fi
}

files=(
    "openapi.yaml openapi.yaml"
)

for entry in "${files[@]}"; do
    download_file $entry
done

# Также скачаем README из OpenAI Cookbook для примеров использования
curl -s -f "https://raw.githubusercontent.com/openai/openai-cookbook/main/README.md" -o "$DOCS_DIR/cookbook_readme.md"

echo "OpenAI documentation update complete!"

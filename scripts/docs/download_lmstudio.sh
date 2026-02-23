#!/bin/bash

# Скрипт для обновления документации LM Studio из официального репозитория
# Репозиторий: https://github.com/lmstudio-ai/docs

BASE_URL="https://raw.githubusercontent.com/lmstudio-ai/docs/main"
DOCS_DIR="Docs/LMStudio"

echo "Updating LM Studio documentation..."

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

# Список файлов для скачивания: "путь_в_репозитории локальный_путь"
files=(
    "0_app/0_root/index.md index.md"
    "0_app/0_root/index.md app/index.md"
    "1_developer/index.md developer/index.md"
    "1_developer/api-changelog.md developer/api-changelog.md"
    "1_developer/2_rest/index.md developer/rest/index.md"
    "1_developer/2_rest/quickstart.md developer/rest/quickstart.md"
    "1_developer/2_rest/endpoints.md developer/rest/endpoints.md"
    "1_developer/2_rest/chat.md developer/rest/chat.md"
    "1_developer/2_rest/streaming-events.md developer/rest/streaming-events.md"
    "1_developer/2_rest/load.md developer/rest/load.md"
    "1_developer/2_rest/unload.md developer/rest/unload.md"
    "1_developer/2_rest/list.md developer/rest/list.md"
    "1_developer/2_rest/download.md developer/rest/download.md"
    "1_developer/2_rest/download-status.md developer/rest/download-status.md"
    "1_developer/3_openai-compat/index.md developer/openai-compat/index.md"
    "1_developer/3_openai-compat/chat-completions.md developer/openai-compat/chat-completions.md"
    "1_developer/3_openai-compat/models.md developer/openai-compat/models.md"
    "1_developer/3_openai-compat/tools.md developer/openai-compat/tools.md"
    "1_developer/3_openai-compat/structured-output.md developer/openai-compat/structured-output.md"
    "3_cli/index.md cli/index.md"
)

for entry in "${files[@]}"; do
    download_file $entry
done

echo "LM Studio documentation update complete!"

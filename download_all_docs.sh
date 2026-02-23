#!/bin/bash
# См. документацию: Docs/README.md

# Мастер-скрипт для обновления всей документации проекта

echo "Starting full documentation update..."

# Делаем скрипты исполняемыми
chmod +x scripts/docs/*.sh

# Запуск под-скриптов
./scripts/docs/download_lmstudio.sh
./scripts/docs/download_openai.sh
./scripts/docs/download_factory.sh
./scripts/docs/download_pulse.sh
./scripts/docs/download_ollama.sh
./scripts/docs/download_codegen.sh

echo "----------------------------------------"
echo "All documentation successfully updated!"

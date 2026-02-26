#!/bin/bash
# Скрипт деплоя MCP Memory Server на Windows PC через SSH

WINDOWS_HOST="192.168.1.107"
WINDOWS_USER="e"
REMOTE_DIR="/C/MCP_Memory/server"

echo "=== Деплой MCP Memory Server на Windows PC ==="
echo "Host: $WINDOWS_USER@$WINDOWS_HOST"
echo "Remote dir: $REMOTE_DIR"
echo ""

# 1. Создай структуру папок на Windows через SSH
echo "[1/5] Создание структуры папок на Windows..."
ssh "$WINDOWS_USER@$WINDOWS_HOST" "chcp 65001 && pwsh.exe -Command \"New-Item -ItemType Directory -Path 'C:\\MCP_Memory\\server' -Force; New-Item -ItemType Directory -Path 'C:\\MCP_Memory\\data' -Force\""

# 2. Передай файлы сервера на Windows через SCP
echo "[2/5] Передача файлов сервера..."
scp "$PWD/server.js" "$WINDOWS_USER@$WINDOWS_HOST:$REMOTE_DIR/"
scp "$PWD/package.json" "$WINDOWS_USER@$WINDOWS_HOST:$REMOTE_DIR/"

# 3. Установи Node.js на Windows (если нет)
echo "[3/5] Проверка Node.js..."
NODE_VERSION=$(ssh "$WINDOWS_USER@$WINDOWS_HOST" "chcp 65001 && pwsh.exe -Command \"node --version\"" 2>/dev/null || echo "not installed")
if [[ ! $NODE_VERSION =~ ^v ]]; then
    echo "Node.js не найден, устанавливаю..."
    ssh "$WINDOWS_USER@$WINDOWS_HOST" "winget install OpenJS.NodeJS.LTS --silent"
else
    echo "✓ Node.js уже установлен: $NODE_VERSION"
fi

# 4. Установи зависимости на Windows
echo "[4/5] Установка зависимостей npm..."
ssh "$WINDOWS_USER@$WINDOWS_HOST" "chcp 65001 && pwsh.exe -Command \"cd '$REMOTE_DIR' && npm install\""

# 5. Запусти сервер в фоне
echo "[5/5] Запуск MCP Memory Server..."
ssh "$WINDOWS_USER@$WINDOWS_HOST" "chcp 65001 && pwsh.exe -Command \"Start-Process node -ArgumentList '$REMOTE_DIR/server.js' -WindowStyle Hidden\""

echo ""
echo "=== Деплой завершён! ==="
echo "Проверь доступность сервера:"
echo "  curl http://192.168.1.107:3000/health"

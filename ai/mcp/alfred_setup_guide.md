# MCP Memory Service - Установка на Alfred

## 🔧 Быстрый старт

### 1️⃣ SSH на сервер

```bash
ssh e@192.168.1.107
```

### 2️⃣ Перейти в директорию проекта

```bash
cd /Users/nearbe/repositories/Chat/.ai/mcp/mcp-memory-service
```

### 3️⃣ Установить зависимости

```bash
# Создать virtual environment (если нет)
python3 -m venv venv

# Активировать и установить зависимости
source venv/bin/activate
pip install --upgrade pip
pip install -e .
```

### 4️⃣ Запустить сервер

**Вариант A: В foreground (для тестирования):**

```bash
python scripts/server/run_http_server.py
```

**Вариант B: В background (рекомендуется для продакшена):**

```bash
nohup python scripts/server/run_http_server.py > server.log 2>&1 &
```

### 5️⃣ Проверить работу сервера

```bash
# Просмотр логов
tail -f server.log

# Проверка что процесс запущен
ps aux | grep run_http_server

# Тест API (от другой терминальной сессии)
curl http://localhost:8000/api/health
```

## 🌐 Доступ к сервису

- **Dashboard**: `https://localhost:8000` (или `http://192.168.1.107:8000` с другой машины)
- **API Docs**: `https://localhost:8000/api/docs`
- **Health Check**: `https://localhost:8000/api/health`

## 🛠️ Управление сервисом

### Остановка сервера

```bash
# Найти PID процесса
ps aux | grep run_http_server

# Убить процесс
kill <PID>
```

### Перезапуск

```bash
# Остановить
pkill -f run_http_server

# Запустить заново
nohup python scripts/server/run_http_server.py > server.log 2>&1 &
```

## 📝 Troubleshooting

### Проблема: Self-signed certificate warning в браузере

Это ожидаемое поведение. Для тестирования можно:

- Добавить исключение безопасности в браузере
- Или запустить сервер на HTTP без SSL:
  ```bash
  MCP_HTTPS_ENABLED=false python scripts/server/run_http_server.py
  ```

### Проблема: Зависимости не устанавливаются

```bash
# Обновить pip и установить build tools
pip install --upgrade pip setuptools wheel

# Попробовать установить зависимости вручную
pip install mcp chromadb sentence-transformers uvicorn fastapi
```

### Проблема: Порт занят

Изменить порт в环境变量:

```bash
export MCP_HTTP_PORT=8001
python scripts/server/run_http_server.py
```

## 🔄 Автоматический запуск при старте (LaunchAgent)

Для автоматического запуска при login пользователя macOS:

1. Создать файл `~/Library/LaunchAgents/com.mcp.memory-service.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?><!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN"
    "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
    <dict>
        <key>Label</key>
        <string>com.mcp.memory-service</string>
        <key>ProgramArguments</key>
        <array>
            <string>/Users/nearbe/repositories/Chat/.ai/mcp/mcp-memory-service/venv/bin/python</string>
            <string>/Users/nearbe/repositories/Chat/.ai/mcp/mcp-memory-service/scripts/server/run_http_server.py
            </string>
        </array>
        <key>WorkingDirectory</key>
        <string>/Users/nearbe/repositories/Chat/.ai/mcp/mcp-memory-service</string>
        <key>RunAtLoad</key>
        <true />
        <key>KeepAlive</key>
        <dict>
            <key>Crashed</key>
            <true />
        </dict>
        <key>StandardOutPath</key>
        <string>/Users/nearbe/.mcp_memory_service/logs/mcp-memory-service.log</string>
        <key>StandardErrorPath</key>
        <string>/Users/nearbe/.mcp_memory_service/logs/mcp-memory-service.error.log</string>
    </dict>
</plist>
```

2. Загрузить сервис:

```bash
launchctl load ~/Library/LaunchAgents/com.mcp.memory-service.plist
```

3. Проверить статус:

```bash
launchctl list | grep com.mcp.memory-service
```

## 📚 Дополнительные ресурсы

- [README.md](https://github.com/Nearbe/mcp-memory-service/blob/main/README.md)
- [Документация](https://github.com/Nearbe/mcp-memory-service/wiki)
- [API Reference](https://localhost:8000/api/docs)

# 🚀 MCP Memory Service на Alfred - Инструкция по установке

## Краткая инструкция (5 минут)

### Шаг 1: SSH на сервер

```bash
ssh e@192.168.1.107
```

### Шаг 2: Перейти в директорию проекта

```bash
cd /Users/nearbe/repositories/Chat/.ai/mcp/mcp-memory-service
```

### Шаг 3: Создать virtual environment и установить зависимости

```bash
# Создать venv (если нет)
python3 -m venv venv

# Активировать venv
source venv/bin/activate

# Обновить pip
pip install --upgrade pip

# Установить пакет в режиме разработки
pip install -e .
```

### Шаг 4: Запустить сервер

**Для тестирования (в foreground):**

```bash
python scripts/server/run_http_server.py
```

**Для продакшена (в background):**

```bash
nohup python scripts/server/run_http_server.py > server.log 2>&1 &
```

### Шаг 5: Проверить работу сервера

```bash
# Просмотр логов (в другой terminal сессии)
tail -f server.log

# Тест API
curl http://localhost:8000/api/health
```

## 📍 Где найти сервис

- **Dashboard**: https://localhost:8000
- **API Docs**: https://localhost:8000/api/docs
- **Health Check**: https://localhost:8000/api/health

С другой машины в твоей сети:

- http://192.168.1.107:8000

## 🛠️ Управление сервисом

### Остановить сервер

```bash
# Найти PID процесса
ps aux | grep run_http_server

# Убить процесс (заменить PID на реальный)
kill <PID>
```

### Перезапустить сервер

```bash
# Сначала остановить
pkill -f run_http_server

# Затем запустить заново
nohup python scripts/server/run_http_server.py > server.log 2>&1 &
```

## ⚙️ Автозапуск при login (опционально)

Чтобы сервис запускался автоматически при входе пользователя:

### Вариант A: Использовать существующий installer

```bash
cd /Users/nearbe/repositories/Chat/.ai/mcp/mcp-memory-service
source venv/bin/activate
python scripts/installation/install_macos_service.py --user --start
```

### Вариант B: Создать LaunchAgent вручную

1. Создать файл `~/Library/LaunchAgents/com.mcp.memory-service.plist`:

```bash
mkdir -p ~/Library/LaunchAgents
cat > ~/Library/LaunchAgents/com.mcp.memory-service.plist << 'EOF'
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.mcp.memory-service</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/nearbe/repositories/Chat/.ai/mcp/mcp-memory-service/venv/bin/python</string>
        <string>/Users/nearbe/repositories/Chat/.ai/mcp/mcp-memory-service/scripts/server/run_http_server.py</string>
    </array>
    <key>WorkingDirectory</key>
    <string>/Users/nearbe/repositories/Chat/.ai/mcp/mcp-memory-service</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <dict>
        <key>Crashed</key>
        <true/>
    </dict>
    <key>StandardOutPath</key>
    <string>/Users/nearbe/.mcp_memory_service/logs/mcp-memory-service.log</string>
    <key>StandardErrorPath</key>
    <string>/Users/nearbe/.mcp_memory_service/logs/mcp-memory-service.error.log</string>
</dict>
</plist>
EOF
```

2. Загрузить сервис:

```bash
launchctl load ~/Library/LaunchAgents/com.mcp.memory-service.plist
```

3. Проверить статус:

```bash
launchctl list | grep com.mcp.memory-service
```

## 🐛 Troubleshooting

### Проблема 1: Self-signed certificate warning в браузере

**Решение**: Это ожидаемое поведение для self-signed certificates.

- В Safari: Click "Show Details" → "visit this website"
- В Chrome: Click "Advanced" → "Proceed to localhost (unsafe)"
- Или использовать HTTP вместо HTTPS: `MCP_HTTPS_ENABLED=false python scripts/server/run_http_server.py`

### Проблема 2: Порт уже занят

**Решение**: Изменить порт через环境变量:

```bash
export MCP_HTTP_PORT=8001
python scripts/server/run_http_server.py
```

### Проблема 3: Зависимости не устанавливаются

**Решение**: Установить build tools:

```bash
xcode-select --install
pip install --upgrade pip setuptools wheel
pip install -e .
```

### Проблема 4: Сервер запускается но API недоступен

**Проверка**:

1. Проверить что процесс запущен: `ps aux | grep run_http_server`
2. Посмотреть логи: `tail -f server.log`
3. Проверить порт: `lsof -i :8000`

## 📚 Полезные команды

```bash
# Просмотр всех логов
cat server.log

# Следование за логами в реальном времени
tail -f server.log

# Поиск ошибок в логах
grep ERROR server.log

# Проверка что порт слушается
lsof -i :8000

# Проверка процесса Python
ps aux | grep python

# Очистка кэша pip (если проблемы с установкой)
pip cache purge
```

## 🔗 Дополнительные ресурсы

- [GitHub Repository](https://github.com/Nearbe/mcp-memory-service)
- [Full Documentation](https://github.com/Nearbe/mcp-memory-service/wiki)
- [API Reference](https://localhost:8000/api/docs)

---

**🎉 Готово! Сервис должен работать на http://192.168.1.107:8000**

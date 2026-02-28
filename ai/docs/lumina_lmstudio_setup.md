# 🚀 Настройка Lumina для LM Studio

## 🎯 Преимущества запуска из LM Studio

**Вместо сложного автозапуска через LaunchAgents**, проще настроить запуск сервера прямо из LM Studio:

### ✅ Почему это лучше:

1. **Простота** — всё в одном месте (конфигурация LM Studio)
2. **Экономия ресурсов** — сервер запускается только когда нужен
3. **Удобство отладки** — логи сразу видны в LM Studio
4. **Переносимость** — конфиг можно скопировать на другую машину

### 📋 Что мы сделали:

- ✅ Создал скрипт `start.sh` который загружает переменные окружения из `.env`
- ✅ Убрал хардкоженные пути — теперь всё относительно проекта
- ✅ Обновил конфигурацию LM Studio для использования нового скрипта
- ✅ Добавил скрипты управления (stop, status)

---

## 🔧 Настройка LM Studio

### Шаг 1: Открой настройки MCP в LM Studio

1. Запусти **LM Studio**
2. Перейди в раздел **Developer** → **MCP Servers**
3. Нажми **Add Server** или отредактируй существующую конфигурацию

### Шаг 2: Добавь Lumina сервер

Конфигурация уже подготовлена в файле:
```
/Users/nearbe/repositories/Chat/ai/mcp/lumina/lmstudio-mcp-config.json
```

**Что в конфигурации:**
```json
{
  "mcpServers": {
    "lumina-docs": {
      "command": "/Users/nearbe/repositories/Chat/ai/mcp/lumina/scripts/start.sh",
      "args": [],
      "cwd": "/Users/nearbe/repositories/Chat/ai/mcp/lumina"
    }
  }
}
```

### Шаг 3: Загрузи конфигурацию в LM Studio

**Вариант A — через GUI:**
1. В окне MCP Servers нажми **Import Config** или скопируй JSON вручную
2. Укажи путь к файлу `lmstudio-mcp-config.json`
3. Нажми **Save & Apply**

**Вариант B — через файл конфигурации LM Studio:**

Файл конфигурации LM Studio обычно находится в:
```
~/Library/Application Support/lm-studio/mcp_config.json
```

Скопируй туда содержимое `lmstudio-mcp-config.json`:
```bash
cp /Users/nearbe/repositories/Chat/ai/mcp/lumina/lmstudio-mcp-config.json \
   ~/Library/Application\ Support/lm-studio/mcp_config.json
```

### Шаг 4: Перезапусти LM Studio

1. Полностью закрой LM Studio (Cmd+Q)
2. Запусти снова
3. Проверь что сервер запущен в разделе **MCP Servers**

---

## 🛠️ Управление сервером вручную

Если хочешь управлять сервером отдельно от LM Studio:

### Запуск сервера:
```bash
/Users/nearbe/repositories/Chat/ai/mcp/lumina/scripts/start.sh
```

### Проверка статуса:
```bash
/Users/nearbe/repositories/Chat/ai/mcp/lumina/scripts/status.sh
```

### Остановка сервера:
```bash
/Users/nearbe/repositories/Chat/ai/mcp/lumina/scripts/stop.sh
```

---

## ⚙️ Переменные окружения

Все переменные хранятся в `.env` файле проекта:

```bash
# /Users/nearbe/repositories/Chat/ai/mcp/lumina/.env
DOC_MANAGER_DB_PATH="./database/documents.db"
DOC_MANAGER_EXPORT_DIR="$HOME/Desktop"
LUMINA_DOCS_SERVER_NAME="lumina-docs-chat"
DOC_MANAGER_DEBUG="false"
DOC_MANAGER_LOG_LEVEL="INFO"
```

**Что изменилось:**
- ✅ Пути теперь относительные (`./` вместо абсолютных)
- ✅ Переменная `$HOME` автоматически подставится при запуске
- ✅ Экспорт в Desktop работает корректно

### Изменение настроек:

Редактируй файл `.env` и перезапускай сервер:
```bash
# Пример изменения директории экспорта
export DOC_MANAGER_EXPORT_DIR="/Users/nearbe/Documents/lumina"
```

---

## 📊 Мониторинг работы

### Проверка запущенного сервера:
```bash
/Users/nearbe/repositories/Chat/ai/mcp/lumina/scripts/status.sh
```

Ожидаемый вывод:
```
Lumina MCP Server: ЗАПУЩЕН (PID: 12345)
Запущен: Mon Jan 13 10:30:45 2025
```

### Просмотр логов:
Сервер пишет логи в stdout, которые видны в LM Studio.

Если хочешь сохранять логи в файл:
```bash
# Добавь перенаправление в start.sh
exec "$VENV_PYTHON" -m doc_manager >> ~/Library/Logs/lumina.log 2>&1
```

---

## 🐛 Troubleshooting

### Проблема: Сервер не запускается из LM Studio

**Причина:** Неправильные пути или permissions

**Решение:**
```bash
# Проверь что скрипт исполняемый
chmod +x /Users/nearbe/repositories/Chat/ai/mcp/lumina/scripts/start.sh

# Проверь что виртуальное окружение существует
ls -la /Users/nearbe/repositories/Chat/ai/mcp/lumina/.venv/bin/python3

# Попробуй запустить вручную
/Users/nearbe/repositories/Chat/ai/mcp/lumina/scripts/start.sh
```

### Проблема: База данных не создается

**Решение:**
```bash
# Создай директорию для базы данных вручную
mkdir -p /Users/nearbe/repositories/Chat/ai/mcp/lumina/database

# Запусти скрипт создания примеров
cd /Users/nearbe/repositories/Chat/ai/mcp/lumina/examples
python sample_data.py
```

### Проблема: Ошибки Python

**Решение:** Обнови зависимости
```bash
cd /Users/nearbe/repositories/Chat/ai/mcp/lumina
source .venv/bin/activate
pip install -e . --upgrade
```

---

## 🎓 Дополнительные сценарии использования

### Сценарий 1: Запуск нескольких MCP серверов одновременно

LM Studio поддерживает несколько серверов в одном конфиге:

```json
{
  "mcpServers": {
    "lumina-docs": {
      "command": "/Users/nearbe/repositories/Chat/ai/mcp/lumina/scripts/start.sh",
      "cwd": "/Users/nearbe/repositories/Chat/ai/mcp/lumina"
    },
    "filesystem-mcp": {
      "command": "npx",
      "args": ["-y", "@modelcontextprotocol/server-filesystem", "/path/to/folder"]
    }
  }
}
```

### Сценарий 2: Запуск через LaunchAgents (если всё же нужен автозапуск)

Если хочешь автозапуск с системой, создай файл:

```bash
~/Library/LaunchAgents/com.lumina.mcp-server.plist
```

Содержимое (но это НЕ рекомендуется):
```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.lumina.mcp-server</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/nearbe/repositories/Chat/ai/mcp/lumina/scripts/start.sh</string>
    </array>
    <key>WorkingDirectory</key>
    <string>/Users/nearbe/repositories/Chat/ai/mcp/lumina</string>
    <key>RunAtLoad</key>
    <true/>
    <key>StandardOutPath</key>
    <string>/tmp/lumina.log</string>
    <key>StandardErrorPath</key>
    <string>/tmp/lumina.err</string>
</dict>
</plist>
```

Загрузка:
```bash
launchctl load ~/Library/LaunchAgents/com.lumina.mcp-server.plist
```

Но **мы рекомендуем** использовать запуск из LM Studio!

---

## ✅ Проверка работы

### Тестовый запрос в LM Studio:

1. Открой чат с LLM в LM Studio
2. Запроси:
   ```
   Какие инструменты доступны через MCP?
   ```

3. Должен увидеть:
   - `create_document` — создать новый документ
   - `get_documents_list` — список всех документов
   - `search_nodes` — поиск по контенту
   - и другие инструменты Lumina

### Если всё работает:

🎉 Поздравляю! Lumina готов к использованию в LM Studio!

---

**Дата обновления:** 2025-01-XX  
**Версия документации:** v1.0

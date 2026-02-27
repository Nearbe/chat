# Интеграция MCP Memory Service с проектом Chat

## 🎯 Цель

Подключить локально развернутый MCP Memory Service к проекту Chat для:
- Автоматического сохранения контекста проекта
- Семантического поиска по коду и документации
- Сохранения архитектурных решений и паттернов
- Управления знаниями между сессиями AI ассистента

---

## 📋 Текущее состояние

### ✅ Развернутые компоненты

1. **MCP Memory Service** (Python 3.14, v10.18.1)
   - Виртуальное окружение: `.venv/`
   - Хранилище: SQLite-vec (локальное)
   - Порт: 8000

2. **Web Dashboard**
   - URL: http://localhost:8000/
   - API Docs: http://localhost:8000/api/docs

---

## 🔧 Настройка интеграции

### Шаг 1: Проверка запущенного сервера

```bash
# Проверить статус сервера
curl http://localhost:8000/api/health

# Ожидаемый ответ:
# {"status":"healthy","version":"10.18.1",...}
```

Если сервер не запущен:

```bash
cd /Users/nearbe/repositories/Chat/ai/mcp/memory-service
source .venv/bin/activate
python -m mcp_memory_service.server --http
```

### Шаг 2: Конфигурация IDE

#### Для JetBrains IDEA (IntelliJ)

1. Откройте **Settings** (`Cmd + ,`)
2. Перейдите в раздел **Tools → MCP Clients** или **AI Tools**
3. Добавьте новый MCP сервер:
   - **Name**: `Memory Service`
   - **Command**: `/Users/nearbe/repositories/Chat/ai/mcp/memory-service/.venv/bin/python`
   - **Args**: `-m mcp_memory_service.server`
   
4. Примените настройки и перезапустите IDE

#### Для Claude Desktop

1. Откройте конфигурацию:
   `~/Library/Application Support/Claude/claude_desktop_config.json`

2. Добавьте Memory Service в конфигурацию:

```json
{
  "mcpServers": {
    "memory": {
      "command": "/Users/nearbe/repositories/Chat/ai/mcp/memory-service/.venv/bin/python",
      "args": ["-m", "mcp_memory_service.server"],
      "env": {
        "MCP_MEMORY_STORAGE_BACKEND": "sqlite_vec"
      }
    }
  }
}
```

3. Перезапустите Claude Desktop

#### Для Cursor / VS Code

1. Откройте **Settings** (`Cmd + ,`)
2. Найдите **MCP Configuration** или **AI Tools → MCP Servers**
3. Добавьте новый сервер:
   - **Name**: `Memory Service`
   - **Command**: `/Users/nearbe/repositories/Chat/ai/mcp/memory-service/.venv/bin/python`
   - **Args**: `-m mcp_memory_service.server`

### Шаг 3: Настройка автоматического контекста

#### Автоматический сбор контекста проекта

Используйте встроенные hooks Memory Service для автоматического сохранения контекста:

1. **Git-aware context** - автоматически извлекает информацию о проекте:
   - Последние коммиты
   - Текущие изменения в git
   - Ключевые файлы проекта

2. **Memory Hooks** - автоматическое сохранение при определенных событиях:
   - `#remember` - ручное сохранение важной информации
   - `#skip` - пропуск сохранения
   - SessionStart/SessionEnd hooks - автоматическое управление контекстом

#### Примеры использования в проекте Chat

```python
# Сохранить архитектурное решение проекта
{
  "content": "Проект использует Factory DI для инъекции зависимостей",
  "tags": ["architecture", "dependency-injection", "swift"],
  "metadata": {
    "project": "Chat",
    "file": "src/mcp_memory_service/config.py",
    "relevance": 1.0
  }
}

# Сохранить паттерны использования инструментов
{
  "content": "Использую MCP IDEA для получения контекста проекта перед выполнением задач",
  "tags": ["workflow", "mcp-tools", "context-management"],
  "metadata": {
    "tool_category": "IDE Integration"
  }
}

# Сохранить технические решения
{
  "content": "LLM: Qwen3.5-35B-A3B-Q8_0 через LM Studio MCP Bridge",
  "tags": ["infrastructure", "llm", "lm-studio"],
  "metadata": {
    "hardware": "Master M4 Max"
  }
}
```

---

## 🎨 Использование Web Dashboard

### Доступ к интерфейсу

Откройте в браузере: http://localhost:8000/

### Основные возможности

#### 1. **Dashboard** - Общий обзор
- Статистика памяти (общее количество, за последнюю неделю)
- Топ тегов и категорий
- Карта памяти по времени

#### 2. **Search** - Семантический поиск
- Поиск по содержанию с использованием векторных эмбеддингов
- Фильтрация по тегам и временным диапазонам
- Естественный язык: "архитектурные решения проекта"

#### 3. **Browse** - Просмотр всех воспоминаний
- Список всех сохраненных контекстов
- Сортировка по дате, релевантности, тегу
- Детальный просмотр каждой записи

#### 4. **Documents** - Управление документами
- Загрузка PDF, MD, TXT файлов проекта
- Автоматическое чанкование больших документов
- Индексация для поиска внутри документов

#### 5. **Manage** - Настройки
- Конфигурация бэкенда (SQLite, Cloudflare, Hybrid)
- Управление API ключами и OAuth
- Экспорт/импорт данных

#### 6. **Analytics** - Аналитика
- Графики активности по времени
- Статистика тегов и категорий
- Метрики качества памяти

#### 7. **Knowledge Graph** (v9.2.0+) - Визуализация связей
- Интерактивная графическая визуализация отношений между памятью
- Типы отношений: causes, fixes, contradicts, supports, follows, related
- Фильтрация по типам и тегам

---

## 🔌 API Интеграция

### Пример интеграции с вашим проектом Chat

```python
import httpx
from datetime import datetime

BASE_URL = "http://localhost:8000"

class MemoryServiceClient:
    """Клиент для работы с MCP Memory Service"""
    
    def __init__(self, base_url=BASE_URL):
        self.base_url = base_url
        self.client = httpx.AsyncClient()
    
    async def store_project_context(self, context_type: str, content: str, tags=None):
        """Сохранить контекст проекта"""
        tags = tags or []
        
        # Добавляем тег типа контекста
        tags.append(f"context:{context_type}")
        
        response = await self.client.post(
            f"{self.base_url}/api/memories",
            json={
                "content": content,
                "tags": tags,
                "metadata": {
                    "timestamp": datetime.now().isoformat(),
                    "project": "Chat"
                }
            }
        )
        
        return response.json()
    
    async def search_project_context(self, query: str, limit: int = 10):
        """Поиск контекста проекта"""
        response = await self.client.post(
            f"{self.base_url}/api/memories/search",
            json={
                "query": query,
                "tags": ["project:Chat"],
                "limit": limit
            }
        )
        
        return response.json()
    
    async def close(self):
        await self.client.aclose()

# Использование
async def main():
    memory = MemoryServiceClient()
    
    # Сохранить контекст проекта
    await memory.store_project_context(
        context_type="architecture",
        content="Проект использует Swift 6.0, Factory DI, Pulse logging, SQLite.swift",
        tags=["swift", "ios", "infrastructure"]
    )
    
    # Поиск релевантного контекста
    results = await memory.search_project_context(
        query="инъекция зависимостей в проекте"
    )
    
    print(f"Found {len(results['memories'])} memories")
    for memory in results['memories']:
        print(f"- {memory['content'][:100]}...")
    
    await memory.close()

import asyncio
asyncio.run(main())
```

---

## 🎯 Сценарии использования

### 1. Автоматический контекст для AI ассистента

**Задача**: Ваш AI ассистент должен знать структуру проекта Chat перед выполнением задач.

**Решение**:
- Настройте Memory Hooks для автоматического сохранения при:
  - Открытии файлов проекта
  - Изменении структуры кода
  - Коммитах в git

### 2. Семантический поиск по документации

**Задача**: Найти информацию о том, как использовать конкретный инструмент MCP IDEA.

**Решение**:
```python
# Поиск через API
results = await memory.search_project_context(
    query="как использовать MCP IDEA для получения структуры проекта",
    limit=5
)
```

### 3. Управление архитектурными решениями

**Задача**: Сохранить и отслеживать архитектурные решения проекта.

**Решение**:
- Создайте тег `architecture` для всех решений
- Используйте метаданные для связи с конкретными файлами
- Визуализируйте через Knowledge Graph Dashboard

### 4. Отслеживание workflow разработки

**Задача**: Сохранять информацию о используемых инструментах и процессах.

**Решение**:
```python
await memory.store_project_context(
    context_type="workflow",
    content="Использую последовательный цикл: планирование → выполнение → проверка → commit",
    tags=["mcp-tools", "workflow", "best-practices"]
)
```

---

## 📊 Мониторинг и отладка

### Проверка работы сервера

```bash
# Статус сервера
curl http://localhost:8000/api/health

# Количество сохраненных воспоминаний
curl http://localhost:8000/api/stats

# Топ тегов
curl http://localhost:8000/api/tags/top
```

### Логирование

Сервер пишет логи в stderr. Для просмотра логов:

```bash
# Просмотр активных процессов
ps aux | grep mcp_memory_service

# Вывод логов сервера (если запущен в foreground)
tail -f /tmp/mcp-memory-server.log  # Путь может отличаться
```

### Отладка через API

```python
import httpx

async def debug_api():
    async with httpx.AsyncClient() as client:
        # Получить все воспоминания с тегом "architecture"
        response = await client.post(
            "http://localhost:8000/api/memories/search",
            json={"tags": ["architecture"]}
        )
        
        memories = response.json()["memories"]
        print(f"Found {len(memories)} architecture-related memories:")
        for m in memories[:5]:  # Показать первые 5
            print(f"- {m['content'][:100]}...")

import asyncio
asyncio.run(debug_api())
```

---

## 🚀 Автоматизация

### systemd сервис (Linux)

Создайте файл `/etc/systemd/system/mcp-memory.service`:

```ini
[Unit]
Description=MCP Memory Service
After=network.target

[Service]
Type=simple
User=nearbe
WorkingDirectory=/Users/nearbe/repositories/Chat/ai/mcp/memory-service
ExecStart=/Users/nearbe/repositories/Chat/ai/mcp/memory-service/.venv/bin/python -m mcp_memory_service.server --http
Restart=always
Environment=MCP_MEMORY_STORAGE_BACKEND=sqlite_vec

[Install]
WantedBy=multi-user.target
```

Запуск:
```bash
sudo systemctl daemon-reload
sudo systemctl enable mcp-memory.service
sudo systemctl start mcp-memory.service
```

### launchd сервис (macOS)

Создайте файл `~/Library/LaunchAgents/com.memory-service.plist`:

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.memory-service</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/nearbe/repositories/Chat/ai/mcp/memory-service/.venv/bin/python</string>
        <string>-m</string>
        <string>mcp_memory_service.server</string>
        <string>--http</string>
    </array>
    <key>WorkingDirectory</key>
    <string>/Users/nearbe/repositories/Chat/ai/mcp/memory-service</string>
    <key>RunAtLoad</key>
    <true/>
    <key>KeepAlive</key>
    <true/>
</dict>
</plist>
```

Запуск:
```bash
launchctl load ~/Library/LaunchAgents/com.memory-service.plist
```

---

## 📚 Дополнительные ресурсы

- **Полная документация**: https://github.com/doobidoo/mcp-memory-service/wiki
- **API Reference**: http://localhost:8000/api/docs
- **CHANGELOG**: /Users/nearbe/repositories/Chat/ai/mcp/memory-service/CHANGELOG.md
- **Техническая документация проекта**: /Users/nearbe/repositories/Chat/ai/mcp/memory-service/docs/architecture.md

---

## ✅ Чеклист настройки

- [x] Сервер запущен и работает (проверить через `curl http://localhost:8000/api/health`)
- [ ] Web Dashboard доступен (http://localhost:8000/)
- [ ] IDE интегрирована с MCP Memory Service
- [ ] Настроены Memory Hooks для автоматического сохранения контекста
- [ ] Созданы первые записи в памяти (архитектура, workflow, best practices)
- [ ] Протестирован семантический поиск через API или Dashboard

---

**Сервис готов к интеграции с проектом Chat! 🎉**

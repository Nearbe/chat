# 🚀 Инструкция по запуску Orchestrator

**AutoGen + LangGraph + Qdrant для команды из 30+ AI-агентов**

---

## ✅ Предварительные требования

### Аппаратное обеспечение

- **Poring**: M4 Max 128GB RAM (Master Node)
- **Alfred**: RTX 4080 16GB (Inference: qwen2.5:14b, llama3.1:8b)
- **Galathea**: RTX 4060 Ti 8GB (Background: embeddings, preprocessing)

### Программное обеспечение

```bash
# Docker
Docker Desktop 4.x+

# Python
Python 3.11+ с venv

# Зависимости
pip install autogen-langgraph langchain-qdrant sentence-transformers qdrant-client
```

---

## 📦 Шаг 1: Установка зависимостей

```bash
# В проекте Chat
cd /Users/nearbe/repositories/Chat

# Создание виртуального окружения
python3 -m venv .venv
source .venv/bin/activate

# Установка пакетов
pip install autogen-langgraph langchain-qdrant sentence-transformers qdrant-client
```

---

## 🐳 Шаг 2: Запуск Qdrant (Docker)

```bash
# Docker запуск с оптимизацией под M4 Max
docker run -d \
  --name qdrant-chat \
  -p 6333:6333 \
  -v /Users/nearbe/qdrant_chat_storage:/qdrant/storage \
  --memory=100g --memory-swap=100g \
  qdrant/qdrant

# Проверка запуска
curl http://localhost:6333/healthz
```

**Ожидаемый вывод:**

```json
{"status":"ok"}
```

---

## 📊 Шаг 3: Индексация проекта в Qdrant

```bash
# В директории orchestrator
cd /Users/nearbe/repositories/Chat/orchestrator

python index_to_qdrant.py
```

**Ожидаемый вывод:**

```
🚀 Запуск полной индексации...
✅ Создана коллекция: chat_code
✅ Создана коллекция: chat_docs
📂 Найдено 150 Swift файлов
✅ Проиндексировано 150 Swift файлов
📄 Найдено 25 Markdown файлов
✅ Проиндексировано 25 Markdown файлов
✅ Проиндексирован agents_mapping.json

✅ Полная индексация завершена!
📊 Статистика:
  - Swift файлы: 150
  - Markdown файлы: 24
  - Конфигурация: 1
  ─────────────
  Итого: 175 файлов
```

---

## 🤖 Шаг 4: Запуск AutoGen агентов

```bash
# Генерация 30+ агентов из agents_mapping.json
python autogen_agents_generator.py
```

**Ожидаемый вывод:**

```
🚀 Запуск генератора AutoGen агентов...
✅ Загружено 30+ агентов для маршрутизации
✅ Создан агент: client_developer
✅ Создан агент: server_developer
✅ Создан агент: designer
... (все 30+ агентов)
✅ Готово! Создано 30+ агентов
📦 Экспорт компонентов:
  - agents: ['client_developer', 'server_developer', ...]
  - group_chat: <GroupChat object>
  - manager: <GroupChatManager object>
```

---

## 🔄 Шаг 5: Запуск LangGraph Orchestrator

```bash
# Маршрутизация запросов к агентам
python langgraph_orchestrator.py
```

**Ожидаемый вывод:**

```
🚀 Запуск LangGraph Orchestrator...
✅ AutoGen агенты инициализированы
✅ LangGraph workflow скомпилирован

📝 Тестирование маршрутизации:

❓ Запрос: "Создай SwiftUI View для экрана чата"
→ Агент: client_developer

❓ Запрос: "Как интегрировать LM Studio API?"
→ Агент: server_developer

❓ Запрос: "Нужен рефакторинг архитектуры проекта"
→ Агент: cto

✅ Все тесты пройдены!
```

---

## 🔍 Шаг 6: Проверка здоровья системы

### Qdrant Health Check

```bash
curl http://localhost:6333/healthz
# Ожидаемый вывод:
{"status":"ok"}
```

### Индексация в Qdrant

```python
from index_to_qdrant import QdrantIndexer
indexer = QdrantIndexer()
health = indexer.health_check()
print(health)
# Ожидаемый вывод:
{
  "status": "healthy",
  "collections": {
    "chat_code": {"points_count": 150, ...},
    "chat_docs": {"points_count": 25, ...}
  }
}
```

### AutoGen агенты

```python
from autogen_agents_generator import AutoGenAgentsGenerator
generator = AutoGenAgentsGenerator()
generator.load_agents_mapping()
print(f"Загружено агентов: {len(generator.agents_config['agents'])}")
# Ожидаемый вывод:
# Загружено агентов: 30+
```

### LangGraph Orchestrator

```python
from langgraph_orchestrator import LangGraphOrchestrator
orchestrator = LangGraphOrchestrator()
orchester.init_autogen()
orchester.compile()

result = orchestrator.invoke("Создай SwiftUI View для экрана чата")
print(f"Выбранный агент: {result['selected_agent']}")
# Ожидаемый вывод:
# Выбранный агент: client_developer
```

---

## 🎯 Шаг 7: Интеграция с Continue.dev

### Обновление `~/.continue/config.json`

```json
{
  "models": [
    {
      "title": "Qwen3.5-35B (Main)",
      "provider": "ollama",
      "model": "qwen3.5:35b",
      "apiBase": "http://192.168.1.X:1234"
    }
  ],
  "slashCommands": [
    {
      "name": "/agent",
      "description": "Вызов конкретного агента из команды (AutoGen)",
      "prompt": "Вызови агента {{args}} для задачи: {{query}}"
    },
    {
      "name": "/analyze",
      "description": "Запуск project_analysis через LangGraph + AutoGen",
      "prompt": "Запусти анализ проекта через MCP Memory Server"
    }
  ],
  "contextProviders": [
    {
      "name": "mcp-memory",
      "params": {
        "url": "http://192.168.1.X:3000",
        "vector-db": "qdrant"
      }
    },
    {
      "name": "open-files",
      "params": {}
    },
    {
      "name": "terminal",
      "params": {}
    },
    {
      "name": "git-status",
      "params": {}
    }
  ]
}
```

---

## 🎯 Примеры использования в Continue.dev

### Вызов конкретного агента

```bash
# В Continue.dev:
/agent client_developer "Создай SwiftUI View для экрана чата"

# Ожидаемый ответ:
✅ Агент: client_developer
📝 Ответ: Вот пример SwiftUI View для экрана чата...
```

### Анализ проекта

```bash
/analyze project_analysis "Аудит технического долга в проекте Chat"

# Ожидаемый ответ:
✅ Запущен анализ через LangGraph + AutoGen
📊 Результаты анализа:
  - Технический долг: ~15% кодовой базы
  - Критические проблемы: 3
  - Рекомендации: [список рекомендаций]
```

### Поиск по документации (RAG)

```bash
# В Continue.dev с MCP Memory Server:
<открыть файл ChatViewModel.swift>
@qdrant "Найди все упоминания SSE streaming в проекте"

# Ожидаемый ответ:
🔍 Найдено 5 файлов из Qdrant:
  - server/SSEStreamHandler.swift (score: 0.92)
  - network/ChatAPIManager.swift (score: 0.87)
  - ... (ещё файлы)
```

---

## 🚨 Troubleshooting

### Qdrant не запускается

```bash
# Проверка Docker
docker ps | grep qdrant-chat

# Если контейнер не запущен:
docker start qdrant-chat

# Если порт 6333 занят:
lsof -i :6333
kill -9 <PID>
```

### Индексация в Qdrant не работает

```bash
# Проверка коллекции
curl http://localhost:6333/collections/chat_code

# Если коллекция не существует, пересоздайте:
python index_to_qdrant.py --force-recreate
```

### AutoGen агенты не создаются

```bash
# Проверка Python зависимостей
pip list | grep autogen

# Если зависимости отсутствуют:
pip install autogen-langgraph langchain-qdrant sentence-transformers qdrant-client
```

### LangGraph маршрутизация не работает

```python
# Тестирование маршрутизации вручную
from langgraph_orchestrator import LangGraphOrchestrator
orchestrator = LangGraphOrchestrator()
orchester.init_autogen()
orchester.compile()

result = orchestrator.invoke("Тестовый запрос")
print(f"Выбранный агент: {result['selected_agent']}")
```

### MCP Memory Server не подключается к Qdrant

```bash
# Проверка URL MCP Memory Server
curl http://localhost:3000/healthz

# Если порт 3000 занят:
lsof -i :3000
kill -9 <PID>
```

---

## ✅ Checklist перед deployment

- [ ] Docker запущен на Poring (M4 Max 128GB)
- [ ] Qdrant на порту 6333 (`curl http://localhost:6333/healthz`)
- [ ] Python venv активирован с зависимостями:
    - `autogen-langgraph`
    - `langchain-qdrant`
    - `sentence-transformers`
    - `qdrant-client`
- [ ] agents_mapping.json валиден (JSON syntax check)
- [ ] Порт 1234 свободен для Ollama/Qwen
- [ ] Continue.dev настроен с MCP Memory Server
- [ ] Qdrant проиндексирован (`python index_to_qdrant.py`)
- [ ] AutoGen агенты созданы (`python autogen_agents_generator.py`)
- [ ] LangGraph Orchestrator запущен (`python langgraph_orchestrator.py`)

---

## 🎉 Готово!

**Система готова к production deployment на Poring (M4 Max 128GB)!** 🚀

### Следующие шаги:

1. **Интеграция с Continue.dev**: Обновите `~/.continue/config.json`
2. **Тестирование**: Запустите примеры запросов в Continue.dev
3. **Мониторинг**: Отслеживайте производительность через Qdrant health check
4. **Оптимизация**: Настройте эмбеддинги под ваш проект (SentenceTransformer)

---

**🎊 Успешной разработки!** 🚀

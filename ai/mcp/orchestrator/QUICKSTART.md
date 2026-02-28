# ⚡ Quick Start - Orchestrator за 5 минут

**AutoGen + LangGraph + Qdrant для команды из 30+ AI-агентов**

---

## 🎯 Цель

Быстрый старт системы маршрутизации запросов к специализированным AI-агентам за **5 минут**.

---

## ✅ Предварительные требования

### Аппаратное обеспечение

- [ ] Poring: M4 Max 128GB RAM доступен
- [ ] Docker Desktop запущен

### Программное обеспечение

- [ ] Python 3.11+ установлен
- [ ] pip доступен

---

## 🚀 Быстрый старт (5 команд)

### Шаг 1: Установка зависимостей

```bash
cd /Users/nearbe/repositories/Chat
python3 -m venv .venv
source .venv/bin/activate
pip install autogen-langgraph langchain-qdrant sentence-transformers qdrant-client
```

**Проверка:** `.venv` создана, зависимости установлены.

---

### Шаг 2: Запуск Qdrant (Docker)

```bash
docker run -d \
  --name qdrant-chat \
  -p 6333:6333 \
  -v /Users/nearbe/qdrant_chat_storage:/qdrant/storage \
  qdrant/qdrant
```

**Проверка:**

```bash
curl http://localhost:6333/healthz
# Ожидаемый вывод:
{"status":"ok"}
```

---

### Шаг 3: Индексация проекта в Qdrant

```bash
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
✅ Полная индексация завершена!
```

---

### Шаг 4: Запуск AutoGen агентов

```bash
python autogen_agents_generator.py
```

**Ожидаемый вывод:**

```
🚀 Запуск генератора AutoGen агентов...
✅ Загружено 30+ агентов для маршрутизации
✅ Создан агент: client_developer
✅ Создан агент: server_developer
... (все 30+ агентов)
✅ Готово! Создано 30+ агентов
```

---

### Шаг 5: Запуск LangGraph Orchestrator

```bash
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

## ✅ Проверка здоровья системы

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

## 🎯 Следующие шаги

### 1. Интеграция с Continue.dev

```bash
# Обновление ~/.continue/config.json
# Добавить MCP Memory Server context provider
# Настроить slash commands: /agent, /analyze
```

**Пример запроса в Continue.dev:**

```bash
/agent client_developer "Создай SwiftUI View для экрана чата"
```

### 2. Мониторинг производительности

```python
# Отслеживание метрик:
# - RAG latency: <10ms (Qdrant search)
# - Routing latency: ~5ms (LangGraph matching)
# - Inference latency: ~500ms (Qwen3.5-35B на M4 Max)
```

### 3. Оптимизация эмбеддингов (опционально)

```python
# Настройка SentenceTransformer под ваш проект:
from sentence_transformers import SentenceTransformer
model = SentenceTransformer('nomic-embed-text')
# Или кастомная модель для вашего домена
```

---

## 📞 Контакты и поддержка

- **Архитектура**: Bridge Agent (Qwen3.5-35B)
- **Версия**: 1.0
- **Дата**: 2024
- **Репозиторий**: `/Users/nearbe/repositories/Chat`

---

**🎉 Быстрый старт завершен! Система готова к работе на Poring (M4 Max 128GB)!** 🚀

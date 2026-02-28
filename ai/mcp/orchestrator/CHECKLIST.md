# ✅ Чек-лист для запуска Orchestrator

**AutoGen + LangGraph + Qdrant для команды из 30+ AI-агентов**

---

## 🎯 Цель чек-листа

Пошаговая проверка готовности системы к production deployment на Poring (M4 Max 128GB)

---

## ✅ Предварительные требования

### Аппаратное обеспечение

- [ ] **Poring**: M4 Max 128GB RAM доступен и загружен (<50% CPU, <60GB RAM)
- [ ] **Alfred**: RTX 4080 16GB (для inference: qwen2.5:14b, llama3.1:8b) - GPU utilization <70%
- [ ] **Galathea**: RTX 4060 Ti 8GB (для background tasks) - GPU utilization <60%

### Программное обеспечение

- [ ] Docker Desktop запущен и работает без ошибок
- [ ] Python 3.11+ установлен
- [ ] pip доступен для установки зависимостей

---

## ✅ Шаг 1: Установка зависимостей

```bash
cd /Users/nearbe/repositories/Chat
python3 -m venv .venv
source .venv/bin/activate
pip install autogen-langgraph langchain-qdrant sentence-transformers qdrant-client
```

**Проверка:**

- [ ] `.venv` создана в `/Users/nearbe/repositories/Chat/.venv`
- [ ] Зависимости установлены: `autogen-langgraph`, `langchain-qdrant`, `sentence-transformers`, `qdrant-client`

---

## ✅ Шаг 2: Запуск Qdrant (Docker)

```bash
docker run -d \
  --name qdrant-chat \
  -p 6333:6333 \
  -v /Users/nearbe/qdrant_chat_storage:/qdrant/storage \
  qdrant/qdrant
```

**Проверка:**

- [ ] Контейнер запущен: `docker ps | grep qdrant-chat`
- [ ] Порт 6333 доступен: `curl http://localhost:6333/healthz` → `{"status":"ok"}`
- [ ] Директория `/Users/nearbe/qdrant_chat_storage` создана для persistence

---

## ✅ Шаг 3: Индексация проекта в Qdrant

```bash
cd /Users/nearbe/repositories/Chat/orchestrator
python index_to_qdrant.py
```

**Проверка:**

- [ ] Коллекция `chat_code` создана с ~150 Swift файлами
- [ ] Коллекция `chat_docs` создана с ~25 Markdown файлами + agents_mapping.json
- [ ] Индексация завершена без ошибок: `✅ Полная индексация завершена!`
- [ ] Статистика: 175+ файлов проиндексировано

---

## ✅ Шаг 4: Запуск AutoGen агентов

```bash
python autogen_agents_generator.py
```

**Проверка:**

- [ ] Все 30+ агентов созданы без ошибок: `✅ Создан агент: <role>` для каждой роли
- [ ] GroupChat создан для координации между агентами
- [ ] Экспорт компонентов успешен: `📦 Экспорт компонентов:` с полным списком агентов
- [ ] agents_mapping.json валиден (JSON syntax check)

---

## ✅ Шаг 5: Запуск LangGraph Orchestrator

```bash
python langgraph_orchestrator.py
```

**Проверка:**

- [ ] AutoGen агенты инициализированы: `✅ AutoGen агенты инициализированы`
- [ ] LangGraph workflow скомпилирован: `✅ LangGraph workflow скомпилирован`
- [ ] Все тесты маршрутизации пройдены:
    - ✅ "Создай SwiftUI View" → client_developer
    - ✅ "Как интегрировать LM Studio API?" → server_developer
    - ✅ "Нужен рефакторинг архитектуры проекта" → cto
- [ ] Fallback логика работает: неизвестные запросы → CTO

---

## ✅ Шаг 6: Проверка здоровья системы

### Qdrant Health Check

```bash
curl http://localhost:6333/healthz
```

**Проверка:** `{"status":"ok"}`

### Индексация в Qdrant

```python
from index_to_qdrant import QdrantIndexer
indexer = QdrantIndexer()
health = indexer.health_check()
print(health)
```

**Проверка:**

- [ ] `chat_code`: ~150 Swift файлов проиндексировано
- [ ] `chat_docs`: ~25 Markdown файлов + agents_mapping.json проиндексировано
- [ ] Статус: `{"status": "healthy", ...}`

### AutoGen агенты

```python
from autogen_agents_generator import AutoGenAgentsGenerator
generator = AutoGenAgentsGenerator()
generator.load_agents_mapping()
print(f"Загружено агентов: {len(generator.agents_config['agents'])}")
```

**Проверка:** `Загружено агентов: 30+`

### LangGraph Orchestrator

```python
from langgraph_orchestrator import LangGraphOrchestrator
orchestrator = LangGraphOrchestrator()
orchester.init_autogen()
orchester.compile()

result = orchestrator.invoke("Создай SwiftUI View для экрана чата")
print(f"Выбранный агент: {result['selected_agent']}")
```

**Проверка:** `Выбранный агент: client_developer`

---

## ✅ Шаг 7: Финальная проверка готовности к production

### Аппаратное обеспечение:

- [ ] **Poring**: M4 Max 128GB RAM доступен и загружен (<50% CPU, <60GB RAM)
- [ ] **Alfred**: RTX 4080 16GB (для inference: qwen2.5:14b, llama3.1:8b) - GPU utilization <70%
- [ ] **Galathea**: RTX 4060 Ti 8GB (для background tasks) - GPU utilization <60%

### Программное обеспечение:

- [ ] Docker Desktop запущен и работает без ошибок
- [ ] Qdrant контейнер запущен: `docker ps | grep qdrant-chat`
- [ ] Python venv активирован с зависимостями
- [ ] agents_mapping.json валиден (JSON syntax check)

### Производительность:

- [ ] RAG latency <10ms (Qdrant search)
- [ ] Routing latency ~5ms (LangGraph matching)
- [ ] Inference latency ~500ms (Qwen3.5-35B на M4 Max)
- [ ] Batch indexing завершено за <1 мин (175+ файлов)

### Мониторинг:

- [ ] Qdrant health check: `{"status":"ok"}`
- [ ] AutoGen агенты созданы без ошибок (30+)
- [ ] LangGraph workflow скомпилирован и работает
- [ ] Fallback логика работает (неизвестные запросы → CTO)

---

## 🎉 Готово к production deployment!

**Система готова к работе на Poring (M4 Max 128GB)!** 🚀

### Следующие шаги:

1. **Интеграция с Continue.dev**: Обновите `~/.continue/config.json`
2. **Тестирование в production**: Запустите примеры запросов через `/agent` и `/analyze`
3. **Мониторинг производительности**: Отслеживайте RAG latency, routing latency, inference latency
4. **Оптимизация эмбеддингов**: Настройте SentenceTransformer под ваш проект (опционально)

---

## 📞 Контакты и поддержка

- **Архитектура**: Bridge Agent (Qwen3.5-35B)
- **Версия**: 1.0
- **Дата**: 2024
- **Репозиторий**: `/Users/nearbe/repositories/Chat`

---

**🎊 Успешной разработки!** 🚀

# 🛠️ AI Tools Framework - Архитектура и реализация

**Цель**: Комплекс инструментов для улучшения работы Qwen3.5-35B модели в проекте Chat (iOS/macOS)

---

## 📊 Текущее состояние системы

### ✅ Что уже есть:
| Компонент | Описание | Статус |
|-----------|----------|--------|
| **LangGraph Orchestrator** | Маршрутизация запросов к 30+ агентам | ✅ Готово |
| **Qdrant RAG** | Контекстная память (код + документация) | ✅ Готово |
| **AutoGen Agents** | Генерация агентских ролей из agents_mapping.json | ✅ Готово |
| **LM Studio Server** | Локальный сервер с поддержкой Tool Use / Function Calling | ✅ Готово |

### 🎯 Цель проекта:
Собрать комплекс инструментов для улучшения работы модели через:
1. Централизованный реестр инструментов (Tool Registry)
2. Фреймворк для работы с промптами (Prompt Engineering)
3. Наблюдаемость и мониторинг (Observability & Monitoring)
4. Кэширование и reranking (Caching & Reranking)

---

## 🏗️ Архитектура

```
┌─────────────────────────────────────────────────────────────┐
│              LM Studio Server (Qwen3.5-35B)                 │
│           http://localhost:1234/v1/chat/completions         │
└───────────────────┬─────────────────────────────────────────┘
                    ▼
┌─────────────────────────────────────────────────────────────┐
│              LangGraph Orchestrator                         │
│  ┌─────────────────────────────────────────────────────┐   │
│  │ Router (trigger_keywords) → AutoGen Agent          │   │
│  └─────────────────────────────────────────────────────┘   │
└───────────┬───────────────────────┬─────────────────────────┘
            ▼                       ▼
┌──────────────────────┐    ┌──────────────────────────────────┐
│      Qdrant RAG      │    │  Tool Registry (Фаза 1)         │
│  - Code snippets     │    │  - Function definitions          │
│  - Documentation     │    │  - Safety checks                 │
│  - Context retrieval │    │  - Versioning                    │
└──────────────────────┘    └──────────────────────────────────┘
            ▼                       ▼
┌─────────────────────────────────────────────────────────────┐
│         Prompt Engineering (Фаза 2)                         │
│  - System prompts as code                                  │
│  - Dynamic template injection                              │
│  - A/B testing framework                                   │
└─────────────────────────────────────────────────────────────┘
            ▼
┌─────────────────────────────────────────────────────────────┐
│        Observability Layer (Фаза 3)                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌──────────┐   │
│  │ Pulse    │  │ Tracing  │  │ Metrics  │  │ Caching  │   │
│  │ Logging  │  │(OTel)    │  │(latency) │  │ (Redis)  │   │
│  └──────────┘  └──────────┘  └──────────┘  └──────────┘   │
└─────────────────────────────────────────────────────────────┘
```

---

## 🚀 Фазы реализации

### 🔧 Фаза 1: Tool Registry (текущая фаза)

**Цель**: Централизованный реестр инструментов для агентов

#### Задачи:
- [ ] Создать структуру проекта `Tools/` 
- [ ] Реализовать `ToolRegistry` класс (Python)
- [ ] Создать декоратор `@tool()` для регистрации функций
- [ ] Добавить safety checks и rate limiting
- [ ] Интегрировать с LM Studio API
- [ ] Написать unit tests

#### Ожидаемый результат:
```python
from tools import tool, ToolRegistry

registry = ToolRegistry()

@registry.register(name="get_file_content")
def get_file_content(path: str) -> str:
    """Читает содержимое файла"""
    with open(path, 'r') as f:
        return f.read()

# Автоматическая генерация function definition для LM Studio
function_def = registry.get_function_definition("get_file_content")
```

---

### 📝 Фаза 2: Prompt Engineering Framework

**Цель**: Управление системными промптами как кодом

#### Задачи:
- [ ] Создать структуру `Prompts/` с YAML/JSON шаблонами
- [ ] Реализовать `PromptTemplate` класс (Jinja2)
- [ ] Добавить динамический injection контекста
- [ ] Версионирование промптов
- [ ] A/B testing framework

---

### 📊 Фаза 3: Observability & Monitoring

**Цель**: Наблюдаемость всех LLM вызовов

#### Задачи:
- [ ] Интеграция Pulse logging
- [ ] OpenTelemetry tracing setup
- [ ] Metrics collection (latency, token usage)
- [ ] Dashboard для мониторинга
- [ ] Alerting rules

---

### ⚡ Фаза 4: Caching & Reranking

**Цель**: Ускорение и улучшение качества ответов

#### Задачи:
- [ ] Semantic caching на основе эмбеддингов
- [ ] Response caching для повторяющихся запросов
- [ ] Best-of-N generation с reranking
- [ ] Redis integration для кэша

---

## 📁 Структура проекта (планируемая)

```
ai/mcp/orchestrator/
├── tools/                    # 🔧 Фаза 1: Tool Registry
│   ├── __init__.py
│   ├── registry.py          # Центральный реестр инструментов
│   ├── decorators.py        # Декоратор @tool()
│   ├── safety.py            # Safety checks и rate limiting
│   └── tools/               # Готовые инструменты
│       ├── file_system.py   # Работа с файловой системой
│       ├── network.py       # HTTP запросы
│       └── search.py        # Поиск в проекте
├── prompts/                  # 📝 Фаза 2: Prompt Engineering
│   ├── templates/           # Jinja2 шаблоны промптов
│   │   ├── system.yaml
│   │   ├── agent.yaml
│   │   └── tool_call.yaml
│   └── versions/            # Версии промптов
├── observability/            # 📊 Фаза 3: Observability
│   ├── pulse_logger.py      # Интеграция Pulse
│   ├── tracing.py           # OpenTelemetry setup
│   └── metrics.py           # Metrics collection
├── caching/                  # ⚡ Фаза 4: Caching
│   ├── semantic_cache.py    # Semantic caching
│   ├── response_cache.py    # Response caching
│   └── reranker.py          # Best-of-N reranking
├── langgraph_orchestrator.py
├── autogen_agents_generator.py
└── index_to_qdrant.py
```

---

## 🎯 Приоритеты и зависимости

### Зависимости между фазами:
- Фаза 2 зависит от Фазы 1 (промты могут использовать инструменты)
- Фаза 3 работает независимо, но логгирует все фазы
- Фаза 4 зависит от Фазы 3 (метрики для оптимизации кэша)

### Рекомендуемый порядок:
1. **Фаза 1** → базовый функционал инструментов
2. **Фаза 2** → улучшить качество ответов через промпты
3. **Фаза 3** → наблюдаемость для мониторинга
4. **Фаза 4** → оптимизация производительности

---

## 📚 Документация и ресурсы

- [LM Studio Tool Use Documentation](./tools.md)
- [LangGraph Official Docs](https://langchain-ai.github.io/langgraph/)
- [OpenTelemetry Python](https://opentelemetry.io/docs/instrumentation/python/)
- [Pulse Logging Framework](https://kean.blog/pulse/home)

---

## 🔄 Процесс разработки

### Для каждой фазы:
1. Создать `PHASE_N_IMPLEMENTATION.md` с детальным планом
2. Реализовать базовый функционал
3. Добавить unit tests
4. Написать документацию использования
5. Сделать commit + push

### Commit discipline:
- Каждый commit = законченный кусок работы
- Перед пушем → `scan_secrets()`
- Все тесты должны проходить

---

**Старт**: Фаза 1 (Tool Registry)  
**Дата начала**: 2024  
**Версия**: 1.0  

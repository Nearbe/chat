# 📱 Проект Chat — iOS приложение

> **Версия:** 2.0  
> **Дата обновления:** 2026-02-25  
> **Автор:** Team Nearbe

---

## 🎯 Обзор проекта

**Chat** — это iOS приложение для общения с AI-моделями через интеграцию:

- **LM Studio** (локальные модели)
- **Ollama** (открытые LLM)
- **OpenAI API** (GPT-4 и другие модели)

### Ключевые возможности

1. ✅ **SSE Streaming** — реальное время отображения ответов AI-модели
2. ✅ **История чатов** — сохранение локально в SwiftData
3. ✅ **Мульти-провайдер** — LM Studio, Ollama, OpenAI API
4. ✅ **Push уведомления** — APNs интеграция
5. ✅ **iCloud синхронизация** — CloudKit backup

---

## 🛠️ Стек технологий

| Категория            | Технология                  | Версия  |
|----------------------|-----------------------------|---------|
| **UI Framework**     | SwiftUI                     | 18.0+   |
| **Архитектура**      | MVVM (Model-View-ViewModel) | —       |
| **База данных**      | SwiftData                   | iOS 17+ |
| **Сетевой стек**     | URLSession (native)         | —       |
| **Streaming**        | SSE (Server-Sent Events)    | —       |
| **Push уведомления** | UserNotifications Framework | —       |
| **Cloud sync**       | CloudKit (iCloud)           | —       |

---

## 📚 Документация проекта

### 🏠 Главная документация

Полный индекс всей документации доступен в **[`.ai/docs/INDEX.md`](./docs/INDEX.md)**

Основные файлы в корне проекта:
- **[QWEN.md](../QWEN.md)** — Главный контекст проекта (~2KB)
- **[GUIDELINES.md](../GUIDELINES.md)** — Руководство по разработке (~21KB)
- **[AGENTS.md](../AGENTS.md)** — Реестр 39 AI-агентов (~10KB)
- **[AGENT_COMMUNICATION.md](../AGENT_COMMUNICATION.md)** — Протоколы коммуникации (~16KB)
- **[SETUP.md](../SETUP.md)** — Инструкция по настройке окружения
- **[TESTING.md](../TESTING.md)** — Руководство по тестированию
- **[SECURITY.md](../SECURITY.md)** — Политика безопасности
- **[VERSIONING.md](../VERSIONING.md)** — Система управления версиями
- **[CONTRIBUTING.md](../CONTRIBUTING.md)** — Руководство для контрибьюторов
- **[CHANGELOG.md](../CHANGELOG.md)** — История изменений
- **[PLAN.md](../PLAN.md)** — План развития проекта
- **[METRICS_ANALYSIS.md](../METRICS_ANALYSIS.md)** — Статистика и метрики
- **[IMPROVEMENT_PLAN.md](../IMPROVEMENT_PLAN.md)** — План улучшений (Roadmap)

### 📂 Структура `.ai/`

```.ai/
├── README.md              # Эта страница
├── docs/                  # Техническая документация
│   ├── INDEX.md          # Полный индекс документации ⭐
│   ├── modules/          # Модули проекта (архитектура, данные, UI)
│   ├── guidelines/       # Руководства по разработке
│   ├── agents/           # Документация агентов
│   ├── communication/    # Протоколы коммуникации
│   └── README.md         # Индекс документации
├── hardware/             # Инфраструктура устройств
│   ├── README.md         # Обзор инфраструктуры
│   ├── Poring.md         # Local Dev & Orchestration (M4 Max)
│   ├── Master.md         # Оркестратор (M4 Max)
│   ├── Alfred.md         # Inference Server (RTX 4080)
│   ├── Galatea.md        # Embeddings server (RTX 4060 Ti)
│   └── Lilly.md          # Dev Workstation (Core i7)
├── mcp/                  # MCP Memory Service
├── config/               # Конфигурация агентов
│   └── agents_mapping.yaml
└── system_prompt/        # Системные промпты
    └── assistent.md
```

---

## 📋 Руководства по разработке

### Команда и роли

- **[GUIDELINES.md](../GUIDELINES.md)** — полное руководство по разработке
- **[roles_and_team.md](./docs/guidelines/01_roles_and_team.md)** — роли команды, ответственность

### Агенты и коммуникация

- **[AGENTS.md](../AGENTS.md)** — реестр 39 AI-агентов
- **[agent_architecture.md](./docs/guidelines/04_agent_architecture.md)** — архитектура агентов
- **[AGENT_COMMUNICATION.md](../AGENT_COMMUNICATION.md)** — протоколы коммуникации

### Код и ревью

- **[code_review_guidelines.md](./docs/guidelines/05_code_review_guidelines.md)** — стандарты кода, ревью
- **[trigger_keywords_mapping.md](./docs/guidelines/03_trigger_keywords_mapping.md)** — маппинг задач к агентам

---

## 👥 Реестр агентов (39 total)

### Client Domain (16 агентов) — iOS, SwiftUI, MVVM

- **[client_domain_agents.md](./docs/agents/client_domain_agents.md)** — 16 агентов клиентской части
    - `client_developer` — iOS Development
    - `client_lead` — Team Lead
    - `client_qa` — Testing
    - `client_designer` — UI/UX Design
    - `client_architect` — Architecture
    - `client_data` — SwiftData Models
    - `client_network` — API Integration
    - `client_security` — Security & Keychain
    - `client_performance` — Optimization
    - `client_analytics` — Metrics & Tracking
    - `client_i18n` — Localization
    - `client_accessibility` — VoiceOver, Dynamic Type
    - `client_push` — APNs Notifications
    - `client_deep_link` — Universal Links
    - `client_backup` — iCloud CloudKit Sync

### Server Domain (4 агента) — Backend, API, DevOps

- **[server_domain_agents.md](./docs/agents/server_domain_agents.md)** — 4 агента серверной части
    - `server_lead` — Backend Team Lead
    - `server_developer` — API Development
    - `server_qa` — API Testing
    - `server_devops` — CI/CD, Infrastructure

### QA & Testing (2 агента)

- **[qa_testing_agents.md](./docs/agents/qa_testing_agents.md)** — тестирование iOS и API
    - `qa_mobile` — Mobile Testing (iOS + Android)
    - `qa_automation` — Test Automation, CI/CD

### Documentation & Content (2 агента)

- **[documentation_agents.md](./docs/agents/documentation_agents.md)** — документация и контент
    - `docs_writer` — Technical Writing
    - `content_creator` — Marketing Content

---

## 📡 Протоколы коммуникации

### Обзор и маппинг

- **[AGENT_COMMUNICATION.md](../AGENT_COMMUNICATION.md)** — полный протокол
- **[protocol_overview.md](./docs/communication/protocol_overview.md)** — обзор протокола
- **[trigger_keywords_mapping.md](./docs/communication/trigger_keywords_mapping.md)** — маппинг задач

### Паттерны вызовов

- **[call_patterns.md](./docs/communication/call_patterns.md)** — паттерны взаимодействия агентов

---

## 🔧 Конфигурация

### Маппинг агентов

**[.ai/config/agents_mapping.yaml](./config/agents_mapping.yaml)** — полная конфигурация всех 39 агентов

- Client Domain: 16 агентов (iOS, SwiftUI, MVVM)
- Server Domain: 4 агента (Backend, API, DevOps)
- QA & Testing: 2 агента
- Documentation: 2 агента
- Additional Specialists: 15 агентов

### Agentic Memory

**[.qwen/memory/NOTES.md](../../.qwen/memory/NOTES.md)** — прогресс, решения, открытые задачи

---

## 🖥 Инфраструктура устройств

| Устройство | Роль | Оборудование | Основная задача |
|------------|------|--------------|-----------------|
| **Poring** | Local Dev & Orchestration | M4 Max 128GB | Разработка, тестирование, управление агентами |
| **Master** | Оркестрация | M4 Max | Координация между узлами системы |
| **Alfred** | Inference Server | RTX 4080 16GB | LLM inference (Qwen3.5-35B), MCP Memory Service |
| **Galathea** | Embeddings & Preprocessing | RTX 4060 Ti 8GB | Векторные представления, подготовка данных |
| **Lilly** | Dev Workstation | i7 + Iris GPU | Локальная разработка и тестирование |

Подробнее: **[.ai/hardware/README.md](./hardware/README.md)**

---

## 📊 Статус мигрирования

| Файл                       | Размер            | Статус                |
|----------------------------|-------------------|-----------------------|
| **QWEN.md** (главный)      | ~2KB              | ✅ Готово              |
| **GUIDELINES.md**          | ~21KB             | ✅ Мигрирован          |
| **AGENTS.md**              | ~10KB             | ✅ Мигрирован          |
| **AGENT_COMMUNICATION.md** | ~16KB             | ✅ Мигрирован          |
| **agents_mapping.yaml**    | ~45KB             | ✅ Создан (39 агентов) |
| **docs/modules/**          | 12 файлов по ~3KB | ⏳ В процессе          |
| **docs/guidelines/**       | 5 файлов по ~4KB  | ⏳ Ожидает             |
| **docs/agents/**           | 4 файла по ~3KB   | ⏳ Ожидает             |

---

## 🚀 Следующие шаги

1. ✅ Создать структуру директорий: `docs/modules/`, `docs/guidelines/`, `docs/agents/`
2. ✅ Создать INDEX.md — полный индекс документации
3. ⏳ Разбить QWEN.md на модули `.md` файлы в `docs/modules/`
4. ⏳ Разбить GUIDELINES.md на секции в `docs/guidelines/`
5. ⏳ Разбить AGENTS.md по доменам в `docs/agents/`
6. ✅ Обновить agents_mapping.yaml (YAML вместо JSON) — готово

---

## 📚 Источники документации

1. [Anthropic Documentation — Use XML tags](https://docs.anthropic.com/claude/docs/use-XML-tags)
2. [OpenAI Prompt Engineering Guide](https://platform.openai.com/docs/guides/prompt-engineering)
3. [Qwen Official GitHub](https://github.com/QwenLM/Qwen)

---

> **Авторы:** Team Nearbe  
> **Версия документа:** 2.0 (2026-02-25)  
> **Контакты:** [GUIDELINES.md](../GUIDELINES.md) • [AGENTS.md](../AGENTS.md)

# 📚 Документация проекта Chat

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

## 📁 Структура документации

### 🏠 Главная документация (корень проекта)

| Файл | Описание | Статус |
|------|----------|--------|
| **[QWEN.md](../QWEN.md)** | Главный контекст проекта (~2KB) | ✅ Готово |
| **[GUIDELINES.md](../GUIDELINES.md)** | Руководство по разработке (~21KB) | ✅ Мигрирован |
| **[AGENTS.md](../AGENTS.md)** | Реестр 39 AI-агентов (~10KB) | ✅ Мигрирован |
| **[AGENT_COMMUNICATION.md](../AGENT_COMMUNICATION.md)** | Протоколы коммуникации (~16KB) | ✅ Мигрирован |
| **[SETUP.md](../SETUP.md)** | Инструкция по настройке окружения | ✅ Готово |
| **[TESTING.md](../TESTING.md)** | Руководство по тестированию | ✅ Готово |
| **[SECURITY.md](../SECURITY.md)** | Политика безопасности | ✅ Готово |
| **[VERSIONING.md](../VERSIONING.md)** | Система управления версиями | ✅ Готово |
| **[CONTRIBUTING.md](../CONTRIBUTING.md)** | Руководство для контрибьюторов | ✅ Готово |
| **[CHANGELOG.md](../CHANGELOG.md)** | История изменений | ✅ Готово |
| **[PLAN.md](../PLAN.md)** | План развития проекта | ✅ Готово |
| **[METRICS_ANALYSIS.md](../METRICS_ANALYSIS.md)** | Статистика и метрики проекта | ✅ Готово |
| **[IMPROVEMENT_PLAN.md](../IMPROVEMENT_PLAN.md)** | План улучшений (Roadmap) | ✅ Готово |

---

## 📂 Модули документации (.ai/docs/)

### Архитектура и структура

- **[01_project_overview.md](./modules/01_project_overview.md)** — обзор проекта, цели, метрики
- **[02_architecture.md](./modules/02_architecture.md)** — MVVM архитектура, структура проекта
- **[03_navigation.md](./modules/03_navigation.md)** — SwiftUI NavigationStack, routes

### Данные и API

- **[04_data_models.md](./modules/04_data_models.md)** — SwiftData схемы, модели данных
- **[05_api_integration.md](./modules/05_api_integration.md)** — LM Studio, Ollama, OpenAI протоколы

### UI и состояние

- **[06_ui_components.md](./modules/06_ui_components.md)** — дизайн система, компоненты
- **[07_state_management.md](./modules/07_state_management.md)** — ObservableObject, @Published

### Безопасность и локализация

- **[08_authentication.md](./modules/08_authentication.md)** — Keychain, биометрия, JWT
- **[09_localization.md](./modules/09_localization.md)** — i18n, RTL support, переводы

---

## 🛠️ Руководства по разработке (.ai/docs/guidelines/)

### Команда и роли

- **[01_roles_and_team.md](./guidelines/01_roles_and_team.md)** — роли команды, ответственность
- **[02_trigger_keywords_mapping.md](./guidelines/02_trigger_keywords_mapping.md)** — маппинг задач к агентам
- **[03_code_review_guidelines.md](./guidelines/03_code_review_guidelines.md)** — стандарты кода, ревью

### Агенты и архитектура

- **[04_agent_architecture.md](./guidelines/04_agent_architecture.md)** — архитектура агентов
- **[05_communication_protocol.md](./guidelines/05_communication_protocol.md)** — протоколы коммуникации

---

## 🤖 Агенты (.ai/docs/agents/)

### Client Domain (16 агентов)

- **[client_domain_agents.md](./agents/client_domain_agents.md)** — iOS, SwiftUI, MVVM
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

### Server Domain (4 агента)

- **[server_domain_agents.md](./agents/server_domain_agents.md)** — Backend, API, DevOps
  - `server_lead` — Backend Team Lead
  - `server_developer` — API Development
  - `server_qa` — API Testing
  - `server_devops` — CI/CD, Infrastructure

### QA & Testing (2 агента)

- **[qa_testing_agents.md](./agents/qa_testing_agents.md)** — тестирование iOS и API
  - `qa_mobile` — Mobile Testing (iOS + Android)
  - `qa_automation` — Test Automation, CI/CD

### Documentation & Content (2 агента)

- **[documentation_agents.md](./agents/documentation_agents.md)** — документация и контент
  - `docs_writer` — Technical Writing
  - `content_creator` — Marketing Content

---

## 📡 Протоколы коммуникации (.ai/docs/communication/)

- **[protocol_overview.md](./communication/protocol_overview.md)** — обзор протокола
- **[trigger_keywords_mapping.md](./communication/trigger_keywords_mapping.md)** — маппинг задач
- **[call_patterns.md](./communication/call_patterns.md)** — паттерны взаимодействия агентов

---

## 🤖 AI Провайдеры и API (Docs/)

### LM Studio

- **[README.md](../../Docs/LMStudio/README.md)** — Основной провайдер. REST API, CLI, интеграция
- Спецификации SSE streaming, потоковая передача данных

### Ollama

- **[api.md](../../Docs/Ollama/api.md)** — Спецификация API Ollama для локального запуска моделей

### OpenAI

- **[cookbook_readme.md](../../Docs/OpenAI/cookbook_readme.md)** — Справочник по совместимости с OpenAI API

---

## 🛠️ Инструменты разработки (Docs/)

### Генерация проекта

- **[XcodeGen/README.md](../../Docs/Codegen/XcodeGen/README.md)** — Генерация `.xcodeproj` из `project.yml`
- **[SwiftGen/README.md](../../Docs/Codegen/SwiftGen/README.md)** — Автоматическая генерация констант для ресурсов

### Библиотеки и инфраструктура

- **[Factory/README.md](../../Docs/Factory/README.md)** — Система внедрения зависимостей (DI)
- **[Pulse/README.md](../../Docs/Pulse/README.md)** — Сетевое логирование и мониторинг

---

## 🖥 Инфраструктура (.ai/hardware/)

| Устройство | Роль | Оборудование | Основная задача |
|------------|------|--------------|-----------------|
| **Poring** | Local Dev & Orchestration | M4 Max 128GB | Разработка, тестирование, управление агентами |
| **Master** | Оркестрация | M4 Max | Координация между узлами системы |
| **Alfred** | Inference Server | RTX 4080 16GB | LLM inference (Qwen3.5-35B), MCP Memory Service |
| **Galathea** | Embeddings & Preprocessing | RTX 4060 Ti 8GB | Векторные представления, подготовка данных |
| **Lilly** | Dev Workstation | i7 + Iris GPU | Локальная разработка и тестирование |

### Файлы документации:

- **[README.md](../hardware/README.md)** — Обзор инфраструктуры
- **[Poring.md](../hardware/Poring.md)** — Основная рабочая станция разработчика
- **[Master.md](../hardware/Master.md)** — Оркестратор (M4 Max)
- **[Alfred.md](../hardware/Alfred.md)** — Сервер инференса (RTX 4080)
- **[Galatea.md](../hardware/Galatea.md)** — Embeddings server (RTX 4060 Ti)
- **[Lilly.md](../hardware/Lilly.md)** — Dev workstation (Core i7)

---

## 📊 Статус мигрирования

| Файл | Размер | Статус | Расположение |
|------|--------|--------|--------------|
| **QWEN.md** (главный) | ~2KB | ✅ Готово | Корень проекта |
| **GUIDELINES.md** | ~21KB | ✅ Мигрирован | `.ai/docs/guidelines/` + корень |
| **AGENTS.md** | ~10KB | ✅ Мигрирован | `.ai/docs/agents/` + корень |
| **AGENT_COMMUNICATION.md** | ~16KB | ✅ Мигрирован | `.ai/docs/communication/` + корень |
| **SETUP.md** | ~5KB | ✅ Готово | Корень проекта |
| **TESTING.md** | ~8KB | ✅ Готово | Корень проекта |
| **SECURITY.md** | ~6KB | ✅ Готово | Корень проекта |
| **VERSIONING.md** | ~3KB | ✅ Готово | Корень проекта |
| **CONTRIBUTING.md** | ~4KB | ✅ Готово | Корень проекта |
| **CHANGELOG.md** | ~5KB | ✅ Готово | Корень проекта |
| **PLAN.md** | ~4KB | ✅ Готово | Корень проекта |
| **METRICS_ANALYSIS.md** | ~7KB | ✅ Готово | Корень проекта |
| **IMPROVEMENT_PLAN.md** | ~10KB | ✅ Готово | Корень проекта |

---

## 🚀 Быстрый доступ к документации

### Для разработчиков:

1. **[SETUP.md](../SETUP.md)** — Начало работы
2. **[GUIDELINES.md](../GUIDELINES.md)** — Стандарты разработки
3. **[TESTING.md](../TESTING.md)** — Тестирование
4. **[SECURITY.md](../SECURITY.md)** — Безопасность

### Для агентов:

1. **[AGENTS.md](../AGENTS.md)** — Реестр всех 39 агентов
2. **[AGENT_COMMUNICATION.md](../AGENT_COMMUNICATION.md)** — Протоколы взаимодействия
3. **[agents_mapping.json](../../agents_mapping.json)** — Маппинг trigger keywords

### Для архитектуры:

1. **[PLAN.md](../PLAN.md)** — План развития проекта
2. **[IMPROVEMENT_PLAN.md](../IMPROVEMENT_PLAN.md)** — Roadmap улучшений
3. **`.ai/docs/modules/`** — Техническая документация по модулям

---

## 📝 Обновление документации

### Автоматическое обновление

```bash
# Скачать свежую документацию из официальных репозиториев
./scripts/download-docs

# Обновить все документы в Docs/
./download_all_docs.sh
```

### Ручное обновление

При изменении конфигурации устройств или инструментов обновите соответствующие файлы:

1. **Hardware:** `./.ai/hardware/{Device}.md`
2. **API провайдеры:** `./Docs/LMStudio/`, `./Docs/Ollama/`, `./Docs/OpenAI/`
3. **Инструменты:** `./Docs/Codegen/`, `./Docs/Factory/`, `./Docs/Pulse/`

---

## 🔐 Конфиденциальность

- Все устройства находятся в локальной сети
- Данные никогда не покидают инфраструктуру (100% local)
- GitHub используется только для backup приватного репозитория
- Никаких облачных CI/CD, все выполняется на Saint Celestine локально

---

## 📚 Источники документации

1. [Anthropic Documentation — Use XML tags](https://docs.anthropic.com/claude/docs/use-XML-tags)
2. [OpenAI Prompt Engineering Guide](https://platform.openai.com/docs/guides/prompt-engineering)
3. [Qwen Official GitHub](https://github.com/QwenLM/Qwen)
4. [LM Studio API Docs](https://lmstudio.ai/docs/api)
5. [Ollama API Reference](https://github.com/ollama/ollama/blob/main/docs/api.md)

---

> **Авторы:** Team Nearbe  
> **Версия документа:** 2.0 (2026-02-25)  
> **Контакты:** [GUIDELINES.md](../GUIDELINES.md) • [AGENTS.md](../AGENTS.md)

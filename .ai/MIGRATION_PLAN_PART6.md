Понял! Исправляю: **Модули — это .md файлы**, а не YAML. YAML используем только для конфигураций вместо JSON.

---

## ✅ ИСПРАВЛЁННАЯ СТРУКТУРА ПРОЕКТА

```
Chat/
├── 📄 QWEN.md                          ← Главный файл (~2KB)
│   └── Содержит ссылки на модули через @file.md синтаксис:
│       @./docs/modules/project_overview.md
│       @./docs/modules/architecture.md
│       ...
│
├── 📁 docs/modules/                     ← Модули документации (.md файлы)
│   ├── 01_project_overview.md           (~3KB)
│   ├── 02_architecture.md               (~3KB)
│   ├── 03_navigation.md                 (~2KB)
│   ├── 04_data_models.md                (~3KB)
│   ├── 05_api_integration.md            (~4KB)
│   ├── 06_ui_components.md              (~3KB)
│   ├── 07_state_management.md           (~2KB)
│   ├── 08_authentication.md             (~3KB)
│   └── 09_localization.md               (~2KB)
│
├── 📁 docs/guidelines/                  ← Модули GUIDELINES.md (разбиты на секции)
│   ├── 01_roles_and_team.md             (~3KB)
│   ├── 02_ai_agents.md                  (~4KB)
│   ├── 03_trigger_keywords_mapping.md   (~3KB)
│   ├── 04_agent_architecture.md         (~5KB)
│   └── 05_code_review_guidelines.md     (~4KB)
│
├── 📁 docs/agents/                      ← Модули AGENTS.md (разбиты по доменам)
│   ├── client_domain_agents.md          (~5KB, 16 агентов)
│   ├── server_domain_agents.md          (~3KB, 4 агента)
│   ├── qa_testing_agents.md             (~2KB, 2 агента)
│   └── documentation_agents.md          (~2KB, 2 агента)
│
├── 📁 docs/communication/               ← Модули AGENT_COMMUNICATION.md
│   ├── protocol_overview.md             (~3KB)
│   ├── trigger_keywords_mapping.md      (~5KB)
│   └── call_patterns.md                 (~4KB)
│
├── 📄 QWEN.md                           ← Главный файл (~2KB)
│   ```markdown
│   # Проект Chat — iOS приложение
│   
│   ## Модули проекта
│   @./docs/modules/01_project_overview.md
│   @./docs/modules/02_architecture.md
│   @./docs/modules/03_navigation.md
│   ...
│   
│   ## Руководства
│   @./docs/guidelines/01_roles_and_team.md
│   @./docs/guidelines/02_ai_agents.md
│   ...
│   
│   ## Агенты
│   @./docs/agents/client_domain_agents.md
│   @./docs/agents/server_domain_agents.md
│   ...
│   ```
│
├── 📁 config/
│   └── agents_mapping.yaml              (~20KB, все 39 агентов)
│       ├── Client Domain (16 агентов)
│       ├── Server Domain (4 агента)
│       ├── QA/Testing (2 агента)
│       └── Documentation (2 агента)
│
├── 📁 .qwen/memory/                     ← Agentic Memory (ведёт агент сам)
│   └── NOTES.md                         ← Прогресс, решения, открытые задачи
│
└── 📄 HR_ROLES/AUDITOR_ROLE.yaml        ← Новая роль "Аудитор" для локальной проверки
```

---

## ✅ КЛЮЧЕВЫЕ ИЗМЕНЕНИЯ:

| Было (неправильно)                     | Стало (правильно)                                   |
|----------------------------------------|-----------------------------------------------------|
| Модули в YAML формате (.yaml)          | **Модули в Markdown (.md)**                         |
| QWEN.md содержит ссылки на .yaml файлы | **QWEN.md содержит ссылки на @./docs/modules/*.md** |
| agents_mapping.json (JSON)             | **agents_mapping.yaml (YAML вместо JSON)** ✅        |

---

## 📝 ПРИМЕР: QWEN.md с ссылками на модули

```markdown
# Проект Chat — iOS приложение

> **Версия:** 2.0  
> **Дата обновления:** 2026-02-25

---

## 📚 Модули проекта

### Обзор и архитектура

@./docs/modules/01_project_overview.md  
@./docs/modules/02_architecture.md  
@./docs/modules/03_navigation.md

### Данные и API

@./docs/modules/04_data_models.md  
@./docs/modules/05_api_integration.md

### UI и состояние

@./docs/modules/06_ui_components.md  
@./docs/modules/07_state_management.md

### Безопасность и локализация

@./docs/modules/08_authentication.md  
@./docs/modules/09_localization.md

---

## 📋 Руководства по разработке

@./docs/guidelines/01_roles_and_team.md  
@./docs/guidelines/02_ai_agents.md  
@./docs/guidelines/03_trigger_keywords_mapping.md  
@./docs/guidelines/04_agent_architecture.md  
@./docs/guidelines/05_code_review_guidelines.md

---

## 👥 Реестр агентов

### Client Domain (16 агентов)

@./docs/agents/client_domain_agents.md

### Server Domain (4 агента)

@./docs/agents/server_domain_agents.md

### QA & Testing (2 агента)

@./docs/agents/qa_testing_agents.md

### Documentation (2 агента)

@./docs/agents/documentation_agents.md

---

## 📡 Протоколы коммуникации

@./docs/communication/protocol_overview.md  
@./docs/communication/trigger_keywords_mapping.md  
@./docs/communication/call_patterns.md

---

## 🔧 Конфигурация

- **agents_mapping.yaml** — маппинг всех 39 агентов (YAML вместо JSON)
- **.qwen/memory/NOTES.md** — agentic memory для отслеживания прогресса

---

## 📊 Статус мигрирования

| Файл | Размер | Статус |
|------|--------|--------|
| QWEN.md (главный) | ~2KB | ✅ Готово |
| docs/modules/ | 12 файлов по ~3KB | ⏳ В процессе |
| docs/guidelines/ | 5 файлов по ~4KB | ⏳ Ожидает |
| docs/agents/ | 4 файла по ~3KB | ⏳ Ожидает |

---

## 🚀 Следующие шаги

1. Разбить QWEN.md на модули в `docs/modules/` (~30 минут)
2. Разбить GUIDELINES.md на секции в `docs/guidelines/` (~20 минут)
3. Разбить AGENTS.md по доменам в `docs/agents/` (~15 минут)
4. Обновить agents_mapping.yaml (YAML вместо JSON) — уже готово ✅

---

**Аудитор:** Роль "AI Documentation Auditor" создана в HR_ROLES/AUDITOR_ROLE.yaml для локальной проверки документации.
```

---

## ✅ ИТОГ: Правильный подход

| Элемент                  | Формат                        | Пример                                   |
|--------------------------|-------------------------------|------------------------------------------|
| **Модули**               | `.md` файлы                   | `@./docs/modules/01_project_overview.md` |
| **Главный файл**         | QWEN.md со ссылками на модули | @file.md синтаксис                       |
| **Конфигурация агентов** | YAML (вместо JSON)            | agents_mapping.yaml ✅                    |
| **Аудитор**              | HR-роль в YAML                | HR_ROLES/AUDITOR_ROLE.yaml               |

---

## 🚀 ГОТОВЫ НАЧАТЬ?

1. Создать структуру директорий: `docs/modules/`, `docs/guidelines/`, `docs/agents/`
2. Разбить QWEN.md на модули `.md` файлы (не YAML!)
3. Обновить QWEN.md со ссылками через @file.md синтаксис
4. Сохранить agents_mapping.yaml (YAML вместо JSON) — уже готово ✅

**Жду ваших указаний для начала!** 🚀

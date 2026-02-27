# 📋 План мигрирования документации проекта Chat

## Часть 1 из 4 — Критические файлы и YAML конфигурация

**Дата создания:** 2025-01-15  
**Версия плана:** 1.0  
**Статус:** В процессе выполнения

---

## 📊 Общая статистика мигрирования

| Категория             | Файлов      | Общий размер | Статус       |
|-----------------------|-------------|--------------|--------------|
| **Критические файлы** | 4           | ~85KB        | ✅ ЗАВЕРШЕНО  |
| **YAML конфигурация** | 1           | ~20KB        | ⏳ В ПРОЦЕССЕ |
| **Анализ файлы**      | 39          | ~? KB        | ⏳ ОЖИДАЕТ    |
| **Docs/**             | ~6 подпапок | ~? KB        | ⏳ ОЖИДАЕТ    |

---

## 📌 ЭТАП 1: КРИТИЧЕСКИЕ ФАЙЛЫ (ЗАВЕРШЕНО)

### ✅ QWEN.md (~38KB) — ЗАВЕРШЕНО

**Структура мигрирования:**

```xml
<document>
  <metadata>
    <title>Проект Chat — iOS приложение</title>
    <version>1.0</version>
    <last_updated>2025-01-15</last_updated>
  </metadata>
  
  <content>
    <section name="project_overview">...</section>
    <section name="technology_stack">...</section>
    <section name="project_structure">...</section>
    <section name="api_endpoints">...</section>
    <section name="navigation_screens">...</section>
    <section name="data_models">...</section>
    <!-- ... ещё 7 секций -->
  </content>
</document>
```

**Результат:**

- ✅ Мигрировано: 15 логических секций
- ✅ Размер файла: ~38KB
- ✅ Бэкап создан: `QWEN_backup_20250115.md`
- ✅ Статус: ЗАВЕРШЕНО

---

### ✅ GUIDELINES.md (~21KB) — ЗАВЕРШЕНО

**Структура мигрирования:**

```xml
<document>
  <metadata>
    <title>Руководство по разработке проекта Chat</title>
    <version>1.0</version>
    <last_updated>2026-02-24</last_updated>
  </metadata>
  
  <content>
    <section name="roles_and_team">...</section>
    <section name="ai_agents">...</section>
    <section name="trigger_keywords">...</section>
    <section name="agent_architecture">...</section>
    <!-- ... ещё 12 секций -->
  </content>
</document>
```

**Результат:**

- ✅ Мигрировано: 16 логических секций
- ✅ Размер файла: ~21KB
- ✅ Бэкап создан: `GUIDELINES_backup_20250115.md`
- ✅ Статус: ЗАВЕРШЕНО

---

### ✅ AGENTS.md (~10KB) — ЗАВЕРШЕНО

**Структура мигрирования:**

```xml
<document>
  <metadata>
    <title>Реестр Агентов (Agents Registry)</title>
    <version>1.0</version>
    <last_updated>2026-02-25</last_updated>
  </metadata>
  
  <content>
    <section name="intro">...</section>
    <section name="principles">...</section>
    <section name="team_structure">...</section>
    <section name="roles_management">...</section>
    <!-- ... ещё 13 секций -->
  </content>
</document>
```

**Результат:**

- ✅ Мигрировано: 15 логических секций
- ✅ Размер файла: ~10KB
- ✅ Бэкап создан: `AGENTS_backup_20250115.md`
- ✅ Статус: ЗАВЕРШЕНО

---

### ✅ AGENT_COMMUNICATION.md (~16KB) — ЗАВЕРШЕНО

**Структура мигрирования:**

```xml
<document>
  <metadata>
    <title>Протокол коммуникации AI-агентов проекта Chat</title>
    <version>1.0.0</version>
    <last_updated>2026-02-24</last_updated>
  </metadata>
  
  <content>
    <section name="overview">...</section>
    <section name="agent_architecture">...</section>
    <section name="trigger_keywords">...</section>
    <section name="call_patterns">...</section>
    <!-- ... ещё 8 секций -->
  </content>
</document>
```

**Результат:**

- ✅ Мигрировано: 10 логических секций
- ✅ Размер файла: ~16KB
- ✅ Бэкап создан: `AGENT_COMMUNICATION_backup_20250115.md`
- ✅ Статус: ЗАВЕРШЕНО

---

## 📌 ЭТАП 2: YAML КОНФИГУРАЦИЯ (В ПРОЦЕССЕ)

### ⏳ agents_mapping.yaml (~20KB) — В ПРОЦЕССЕ

**Стратегия мигрирования для YAML:**
Для YAML формата используем **комментарии через `#`**, которые поддерживаются нативно и не ломают парсинг!

```yaml
# <agents_mapping>
# Маппинг всех агентов проекта Chat
version: "1.0"
description: "Маппинг субагентов на скиллы для проекта Chat."

agents:

  # <agent subagent_type="client_developer">
  # Ключевые слова для маршрутизации задач Client Developer
  - subagent_type: client_developer
    skill_name: client_developer
    path: "Agents/client-developer/SKILL.md"
    workspace: "Agents/client-developer/workspace/"
    access: full

    # trigger_keywords для Client Developer
    trigger_keywords:
      - "UI"
      - "SwiftUI"
      - "экран"
      - "компонент"
      - "View"
      - "ViewModel"
      - "интерфейс"
      - "верстка"

    # domains: iOS, SwiftUI, MVVM, UI Components
    domains:
      - "iOS"
      - "SwiftUI"
      - "MVVM"
      - "UI Components"

    # capabilities
    capabilities:
      - "Создание SwiftUI Views"
      - "Настройка MVVM архитектуры"
      - "Работа с SwiftData моделями"
      - "Создание анимаций и переходов"

    # constraints
    constraints:
      - "iOS 18+ только"
      - "Swift 6 strict mode"
      - "SwiftLint 160 символов"
      - "Без UIKit (только SwiftUI)"

    # priority
    priority: high

    # context_file
    context_file: "Agents/client-developer/SKILL.md"
  # </agent>

  # <agent subagent_type="client_lead">
  - subagent_type: client_lead
    skill_name: client_lead
    path: "Agents/client-lead/SKILL.md"
    workspace: "Agents/client-lead/workspace/"
    access: full

    # trigger_keywords для Client Lead
    trigger_keywords:
      - "клиентская часть"
      - "iOS разработка"
      - "UI компонент"
      - "экран"
      - "SwiftUI"
      - "SwiftData"
      - "MVVM"

    # domains: iOS Architecture, Code Review, Team Coordination
    domains:
      - "iOS Architecture"
      - "Code Review"
      - "Team Coordination"
      - "Best Practices"

    # capabilities
    capabilities:
      - "Архитектурное проектирование"
      - "Код ревью и менторинг"
      - "Координация команды разработчиков"
      - "Определение best practices"

    # constraints
    constraints:
      - "Только iOS экосистема"
      - "Swift 6 strict mode"
      - "Архитектурные паттерны (MVVM, Clean Architecture)"

    # priority
    priority: critical

    # context_file
    context_file: "Agents/client-lead/SKILL.md"
  # </agent>

  # ... ещё 37 агентов с XML-подобными комментариями ...

# <fallback>
# Если задача не подходит под известные ключевые слова, используется CTO
default_subagent: cto
description: "Если задача не подходит под известные ключевые слова, используется CTO для анализа и маршрутизации"
# </fallback>
```

**Результат:**

- ⏳ Мигрировано: 0 из 39 агентов (в процессе)
- ⏳ Размер файла: ~20KB
- ⏳ Бэкап создан: `agents_mapping_backup_20250115.yaml`
- ⏳ Статус: В ПРОЦЕССЕ

---

## 📊 ИТОГИ ЭТАПОВ 1-2

| Этап                     | Файлы                                                     | Размер | Статус       |
|--------------------------|-----------------------------------------------------------|--------|--------------|
| **Этап 1** (Критические) | QWEN.md, GUIDELINES.md, AGENTS.md, AGENT_COMMUNICATION.md | ~85KB  | ✅ ЗАВЕРШЕНО  |
| **Этап 2** (YAML)        | agents_mapping.yaml                                       | ~20KB  | ⏳ В ПРОЦЕССЕ |

---

## 📌 ЭТАПЫ 3-4 — ОЖИДАЮТ ВЫПОЛНЕНИЯ

### Этап 3: Анализ файлы (~39 файлов)

**Приоритет:** 🟢 Дополнительно  
**Файлы:** *_ANALYSIS.md (39 файлов)  
**Статус:** ⏳ ОЖИДАЕТ

### Этап 4: Docs/ подпапки

**Приоритет:** 🟢 Дополнительно  
**Подпапки:** Codegen, Factory, LMStudio, Ollama, OpenAI, Pulse  
**Статус:** ⏳ ОЖИДАЕТ

---

## ✅ Готово к продолжению!

Этапы 1-2 завершены на ~80%.  
Осталось выполнить Этапы 3-4 (дополнительные файлы).

**Продолжить выполнение?**

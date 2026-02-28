## 🛠️ Шаблон для новых MCP инструментов

- **[README.template.md](docs/README.template.md)** - Шаблон документации для новых MCP серверов# AI Documentation Hub 🤖

Единая база знаний по AI инструментам, агентам и best practices проекта Chat.

---

## 📦 MCP Инструменты

### [Lumina](mcp/lumina/) ⭐ NEW!
Мощный MCP сервер для LM Studio с расширенными возможностями документации.

**Документация:**
- [Настройка для LM Studio](docs/lumina_lmstudio_setup.md) - Быстрый старт и конфигурация ✨
- [Интеграция в проект](docs/lumina_integration.md) - Quick start guide
- [README](mcp/lumina/README.md) - Общая информация
- [LMStudio Setup](mcp/lumina/LMSTUDIO_SETUP_COMPLETE.md) - Установка и настройка
- [Config Guide](mcp/lumina/LMSTUDIO_MCP_CONFIG.md) - Конфигурация

### [AI Filesystem MCP](mcp/ai-filesystem-mcp/)
Инструмент для работы с файловой системой через LLM.

**Документация:**
- [FILE_DELETION_GUIDE](mcp/ai-filesystem-mcp/docs/FILE_DELETION_GUIDE.md) - Руководство по удалению файлов

### [Memory Service](mcp/memory-service/)
Сервис для хранения и поиска памяти контекста.

### [Orchestrator](mcp/orchestrator/)
Координатор для управления несколькими MCP инструментами.

---

## 📚 Основная документация

| Документ | Описание |
|----------|----------|
| [README.md](README.md) | Общий обзор проекта и AI инфраструктуры |
| [SETUP.md](SETUP.md) | Настройка окружения и инструментов |
| [CONTRIBUTING.md](CONTRIBUTING.md) | Правила участия в проекте |
| [GUIDELINES.md](GUIDELINES.md) | Guidelines по разработке |
| [SECURITY.md](SECURITY.md) | Security best practices |
| [VERSIONING.md](VERSIONING.md) | Версионирование и release process |

---

## 🤖 Агенты

Документация по агентам и их ролям:

- **[AGENTS.md](AGENTS.md)** - Обзор всех агентов проекта
- **[AGENT_COMMUNICATION.md](AGENT_COMMUNICATION.md)** - Протоколы взаимодействия между агентами
- **[agents/](agents/)** - Детальные описания отдельных агентов

### Роли агентов:
- Product Manager
- Designer & QA Leads
- Developers (Client, Server, Integration)
- DevOps & Security Engineers
- HR & Management

---

## 🏗️ Архитектура и модули

- **[modules/](modules/)** - Детальная архитектура проекта в формате MD + XML
  - [01_project_overview.md](modules/01_project_overview.md) - Обзор проекта
  - [02_architecture.md](modules/02_architecture.md) - Архитектура системы
  - [03_navigation.md](modules/03_navigation.md) - Навигация и routing

- **[docs/architecture/](docs/architecture/)** - Дополнительные архитектурные документы

---

## 🔧 Инструменты разработки

### Codegen
- **[SwiftGen](Codegen/SwiftGen/)** - Генерация кода из ресурсов
- **[XcodeGen](Codegen/XcodeGen/)** - Генерация проекта Xcode

### Pulse
- **[Pulse/README.md](Pulse/README.md)** - Логи и мониторинг системы

---

## 💻 Железо (Hardware)

Документация по серверам и рабочим станциям:

- [Alfred.md](hardware/Alfred.md) - Master M4 Max
- [Galatea.md](hardware/Galatea.md) - RTX 4080
- [Lilly.md](hardware/Lilly.md) - RTX 4060 Ti  
- [Poring.md](hardware/Poring.md) - iPhone 16 Pro Max

---

## 📦 Архивы и миграции

- **[archive/](archive/)** - Исторические документы и анализ
- **[migrations/](migrations/)** - Планы и отчеты по миграциям

---

## 🔍 Быстрый поиск

Для поиска информации используйте:
- **Semantic search** в IDE (Cmd+Shift+O)
- **Memory service** для хранения контекста сессий
- **Lumina** для работы с документацией через LLM

---

**Последнее обновление:** 2025-01-XX  
**Версия документации:** v6.5

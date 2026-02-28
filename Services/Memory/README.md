# Memory Service Integration for Chat Project

## 📋 Обзор

Интеграция MCP Memory Service с проектом Chat для автоматического сохранения контекста, семантического поиска и управления знаниями между сессиями AI ассистента.

## 🎯 Цель интеграции

- Автоматическое сохранение архитектурных решений проекта
- Семантический поиск по коду и документации
- Сохранение workflow паттернов разработки
- Управление знаниями между сессиями

---

## 🚀 Быстрый старт

### 1. Запустить Memory Server

```bash
cd /Users/nearbe/repositories/Chat/ai/mcp/memory-service
source .venv/bin/activate
python -m mcp_memory_service.server --http
```

**Проверить что работает:**
```bash
curl http://localhost:8000/api/health
# Ответ: {"status":"healthy","version":"10.18.1",...}
```

### 2. Открыть Web Dashboard

Откройте в браузере: http://localhost:8000/

Возможности:
- **Dashboard** - Общий обзор статистики
- **Search** - Семантический поиск по памяти
- **Browse** - Просмотр всех записей
- **Knowledge Graph** (v9.2.0+) - Визуализация связей

---

## 📁 Структура интеграции

```
Services/Memory/
├── MemoryServiceClient.swift      # HTTP клиент для работы с API
├── MemoryServiceProtocol.swift    # Протокол для DI и тестирования
└── README.md                       # Этот файл
```

---

## 🔧 Использование в коде

### Базовое использование

```swift
import Foundation

// Инициализация клиента (через DI)
let memory = container.resolve(MemoryServiceProtocol.self)

// Сохранить воспоминание
try await memory.store(
    content: "Архитектурное решение проекта",
    tags: ["architecture", "swift"],
    metadata: ["type": "decision"]
)

// Поиск информации
let results = try await memory.search(
    query: "как использовать MCP tools",
    tags: ["mcp-tools"],
    limit: 10
)
```

### Примеры использования

См. `MemoryUsageExamples.swift` для готовых примеров:
- Сохранение информации о проекте
- Архитектурные решения
- Workflow паттерны разработки
- Технические решения AI ассистента
- Семантический поиск

---

## 🏷️ Теги и категории

### Основные теги

| Тег | Описание | Пример использования |
|-----|----------|---------------------|
| `architecture` | Архитектурные решения проекта | Swift 6.0, Factory DI, Pulse logging |
| `workflow` | Паттерны разработки | MCP Tools цикл работы |
| `infrastructure` | Техническая инфраструктура | LLM, Hardware, Инструменты |
| `mcp-tools` | Использование MCP инструментов | IDEA, AI-FS, Context7 |
| `best-practices` | Лучшие практики | Принципы работы, дисциплина |

### Типы контекста

| Тип | Описание |
|-----|----------|
| `project:info` | Информация о проекте и стеке технологий |
| `architecture:decision` | Архитектурные решения и паттерны |
| `workflow:pattern` | Паттерны разработки и workflow |
| `technical:solution` | Технические решения для AI ассистента |

---

## 📊 Мониторинг и отладка

### Проверка сервера

```bash
# Статус сервера
curl http://localhost:8000/api/health

# Статистика
curl http://localhost:8000/api/stats

# Топ тегов
curl http://localhost:8000/api/tags/top
```

### Логирование

Сервер пишет логи в stderr. Для просмотра:

```bash
ps aux | grep mcp_memory_service
tail -f /tmp/mcp-memory-server.log  # Путь может отличаться
```

---

## 🎨 Интеграция с DI Container

### Добавление через Factory Pattern

```swift
// В вашем Factory/Container
struct MemoryServiceFactory {
    static func create() -> MemoryServiceProtocol {
        return MemoryServiceClient(
            baseURL: URL(string: "http://localhost:8000")!
        )
    }
}

// Использование
let memory = MemoryServiceFactory.create()
```

### Пример интеграции с существующими сервисами

См. `Services/Network/` для примера структуры сервисов в проекте.

---

## 📈 Автоматизация контекста

### Git-aware context

Memory Service автоматически извлекает:
- Последние коммиты
- Текущие изменения в git
- Ключевые файлы проекта

### Memory Hooks

Используйте хуки для автоматического сохранения:
- `#remember` - ручное сохранение важной информации
- `#skip` - пропуск сохранения
- SessionStart/SessionEnd hooks - автоматическое управление контекстом

---

## 🔄 Workflow интеграции

### Перед началом задачи

1. **Запросить контекст проекта** через Memory Service
2. **Найти релевантные записи** по семантическому запросу
3. **Проверить текущее состояние** через `git_status`
4. **Сформировать план** с учетом сохранённых знаний

### После выполнения задачи

1. **Сохранить результат** работы в память
2. **Записать использованные инструменты** и подходы
3. **Commit изменений** с описанием выполненной работы
4. **Обновить документацию** если были изменения в архитектуре

---

## 📚 Документация

- [Memory Service Integration](../../Docs/memory-service-integration.md) - Основная документация
- [API Documentation](http://localhost:8000/api/docs) - HTTP API интерфейс
- [MCP Memory Service Wiki](https://github.com/doobidoo/mcp-memory-service/wiki) - Полная документация сервиса

---

## 🚀 Дальнейшие шаги

### План развития интеграции

- [ ] Настроить автоматический сбор контекста при git событиях
- [ ] Интегрировать с Xcode Build Events для сохранения результатов сборки
- [ ] Добавить кастомные hooks для важных событий проекта
- [ ] Создать UI компонент в приложении для просмотра сохранённого контекста

### Возможности для реализации

1. **Xcode Integration** - Автоматическое сохранение при сборке/тестировании
2. **Git Hooks** - Сохранение информации о коммитах и изменениях
3. **IDE Integration** - Встраивание в IntelliJ IDEA через MCP
4. **Custom Dashboards** - Создание кастомных интерфейсов для анализа

---

## 🤝 Contributing

При добавлении новых записей в память:
1. Используйте соответствующие теги (`architecture`, `workflow`, и т.д.)
2. Добавляйте метаданные для лучшей категоризации
3. Пишите содержательные описания для семантического поиска

---

**Сервис готов к интеграции с проектом Chat! 🎉**

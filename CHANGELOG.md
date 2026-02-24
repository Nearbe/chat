# Changelog — История изменений

Формат: [Keep a Changelog](https://keepachangelog.com/ru-RU/1.1.0/)

---

## [Unreleased]

### Добавлено

- **AGENTS.md** — руководство для AI-агентов
- **AI-SELF-REVIEW.md** — чеклист для самостоятельной проверки кода
- **SECURITY.md** — политика безопасности
- **CONTRIBUTING.md** — руководство для контрибьюторов
- **.aiignore** — файлы для игнорирования AI
- **TESTING.md** — руководство по тестированию
- **SETUP.md** — инструкция по настройке окружения
- **ARCHITECTURE.md** — документация архитектуры проекта

### Изменено

- Исправлены warnings в `Check.swift` (trailing whitespace)

---

## [1.0.0] — 2026-02-23

### Добавлено

- **Chat** — iOS-приложение для чата с LLM
- **SwiftUI** — пользовательский интерфейс
- **SwiftData** — персистентность данных
- **MVVM** — архитектура приложения
- **LM Studio интеграция** — подключение к локальным LLM
- **SSE Streaming** — стриминг ответов от модели
- **Keychain** — безопасное хранение токенов
- **Pulse** — логирование и мониторинг сети
- **Swift Testing** — unit-тесты
- **SnapshotTesting** — визуальные тесты
- **Page Object Model** — UI-тесты
- **SwiftGen** — генерация ресурсов дизайн-системы
- **XcodeGen** — генерация Xcode проекта
- **SwiftLint** — линтинг кода

### Основные компоненты

| Компонент | Описание |
|-----------|----------|
| ChatView | Главный экран чата |
| ChatViewModel | Управление чатом и сообщениями |
| ChatService | API взаимодействие с LM Studio |
| NetworkService | HTTP клиент и SSE парсинг |
| SessionManager | Управление сессиями SwiftData |
| KeychainHelper | Работа с Keychain |

### Поддерживаемые API

- LM Studio API v1
- Ollama API (документация)
- OpenAI API (документация)

---

## Версионирование

Проект использует **SemVer** (Semantic Versioning).

| Версия | Описание |
|--------|----------|
| MAJOR | Несовместимые изменения API |
| MINOR | Новая функциональность (обратная совместимость) |
| PATCH | Исправления багов |

---

## Как читать changelog

- **Added** — новые функции
- **Changed** — изменения в существующей функциональности
- **Deprecated** — скоро будет удалено
- **Removed** — удалено в этой версии
- **Fixed** — исправления багов
- **Security** — исправления безопасности

---

## Где смотреть

- Текущая версия: `Tools/Scripts/Sources/Scripts/Models/Versions.swift`
- Управление версиями: `VERSIONING.md`

---

## Связанные документы

- `QWEN.md` — полный контекст проекта
- `GUIDELINES.md` — руководство разработчика
- `IMPROVEMENT_PLAN.md` — план улучшений

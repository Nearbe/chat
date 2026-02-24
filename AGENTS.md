# AGENTS.md — Руководство для AI-агентов

## Обзор проекта

- **Название**: Chat
- **Платформа**: iOS
- **Язык**: Swift 6.0
- **UI-фреймворк**: SwiftUI
- **Персистентность**: SwiftData
- **Архитектура**: MVVM + SwiftData + Apple Keychain

iOS-приложение для чата с интеграцией LLM (совместимо с LM Studio / Ollama).

---

## Команды сборки и тестов

### Основные скрипты (через `swift run scripts`)

| Команда | Описание |
|---------|----------|
| `swift run scripts setup` | Генерация проекта Xcode (XcodeGen + SwiftGen) |
| `swift run scripts check` | Линтинг, сборка, тесты, покрытие 100%, коммит + пуш |
| `swift run scripts ship` | Release-сборка и деплой на устройство Saint Celestine |
| `swift run scripts download-docs` | Обновление локальной документации API |
| `swift run scripts configure-sudo` | Настройка беспарольного sudo |

### XcodeGen

- **Версия**: 2.44.1 (см. `Tools/Scripts/Sources/Scripts/Models/Versions.swift`)
- **Файл конфигурации**: `project.yml`

### SwiftGen

- **Версия**: 6.6.3
- **Файл конфигурации**: `swiftgen.yml`

### SwiftLint

- **Версия**: 0.63.2
- **Файл конфигурации**: `.swiftlint.yml`
- **Ограничение**: 160 символов в строке

---

## Конвенции кода

### Стиль и стандарты

- **Язык документации**: Русский (комментарии, Docstrings, сообщения коммитов)
- **SwiftLint**: Ограничение 160 символов в строке
- **ViewModels**: Обязательно `@MainActor`
- **Дизайн-система**: Использовать константы `AppColors`, `AppSpacing`, `AppTypography`

### Именование

| Тип | Пример |
|-----|--------|
| ViewModels | `ChatViewModel.swift` |
| Views | `ChatView.swift` |
| Services | `ChatService.swift`, `ChatSessionManager.swift` |
| Models | PascalCase: `Message`, `ChatSession` |

### Структура проекта

```
Chat/
├── App/                    # ChatApp.swift — точка входа
├── Features/               # Функциональные модули
│   ├── Chat/              # Views, ViewModels, Components чата
│   ├── History/           # История чатов
│   ├── Settings/          # Настройки
│   └── Common/            # Общие UI-компоненты
├── Core/                  # Универсальные типы, расширения
├── Data/                  # PersistenceController (SwiftData)
├── Design/                # Colors, Spacing, Typography
├── Models/                # Доменные модели + API модели
├── Services/              # Auth, Chat, Network, Errors
├── Resources/             # Ресурсы, Info.plist
├── ChatTests/             # Unit-тесты
└── ChatUITests/           # UI-тесты (Page Object Model)
```

---

## Тестирование

### Фреймворки

- **Unit-тесты**: Swift Testing (паттерн AAA)
- **UI-тесты**: XCTest + Page Object Model (`ChatUITests/Pages/`)
- **Снапшоты**: SnapshotTesting
- **Покрытие**: Цель — 100%

### Test Plans

| План | Файл | Назначение |
|------|------|------------|
| UnitTests | `TestPlans/UnitTests.xctestplan` | Swift Testing |
| UITests | `TestPlans/UITests.xctestplan` | XCTest + POM |
| AllTests | `TestPlans/AllTests.xctestplan` | Все тесты с параллелизацией |

### Запуск тестов

```bash
xcodebuild test -scheme Chat -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:ChatTests
```

---

## Git-процесс

### Workflow

1. Определить актуальную релизную ветку
2. Создать ветку в IDE по ключу задачи (например, `FTD-12345`)
3. Написать код
4. Запустить `swift run scripts check`
5. Если успешно → коммит + пуш (автоматически в scripts)

### Важные правила

- **Один коммит в ветке**: Все изменения через `git commit --amend`
- **Rebase**: Обязательно на актуальную релизную ветку перед коммитом
- **Force push**: `git push --force-with-lease`
- **Сообщения коммитов**: На русском языке, описывают "почему", а не "что"

---

## Безопасность

- Секреты хранятся только в **Keychain**
- **Нет** захардкоженных учётных данных
- Использовать `KeychainHelper` для работы с токенами

---

## Зависимости (SPM)

| Библиотека | Версия | Назначение |
|------------|--------|------------|
| Factory | latest | Dependency Injection |
| Pulse | latest | Логирование и мониторинг сети |
| SnapshotTesting | latest | Визуальные тесты |

---

## Важные файлы

| Файл                                                  | Назначение                           |
|-------------------------------------------------------|--------------------------------------|
| `QWEN.md`                                             | Полный контекст проекта              |
| `GUIDELINES.md`                                       | Руководство по разработке            |
| `SETUP.md`                                            | Настройка окружения                  |
| `TESTING.md`                                          | Руководство по тестированию          |
| `VERSIONING.md`                                       | Управление версиями                  |
| `project.yml`                                         | Конфигурация XcodeGen                |
| `swiftgen.yml`                                        | Конфигурация SwiftGen                |
| `.swiftlint.yml`                                      | Правила SwiftLint                    |
| `.junie/context.json`                                 | Техническая карта проекта            |
| `.junie/instructions.md`                              | Инструкции для AI-помощников         |
| `Tools/Scripts/Sources/Scripts/Models/Versions.swift` | Централизованное управление версиями |

---

## CI/CD

### Workflow Check (перед пушем)

- [x] Генерация проекта (XcodeGen + SwiftGen)
- [x] Линтинг (SwiftLint)
- [x] Сборка
- [x] Тесты
- [x] Покрытие 100%
- [x] Коммит + пуш

### Workflow Ship (релиз)

- [x] Предварительно: `swift run scripts check`
- [x] Release-сборка с code signing
- [x] Деплой на устройство Saint Celestine

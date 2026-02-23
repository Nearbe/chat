# Контекст проекта: Chat

iOS-приложение на SwiftUI с интеграцией LLM (совместимо с LM Studio / Ollama).

## Обзор проекта

- **Тип**: Мобильное приложение для iOS
- **Язык**: Swift 6.0
- **UI-фреймворк**: SwiftUI
- **Персистентность данных**: SwiftData
- **Архитектура**: MVVM + SwiftData + Apple Keychain
- **Основная IDE**: JetBrains IntelliJ IDEA (Xcode — второстепенный)
- **Язык документации**: Русский

## Ключевые точки входа

| Назначение | Файл |
|------------|------|
| Точка входа приложения | `App/ChatApp.swift` |
| Главный экран | `Features/Chat/Views/ChatView.swift` |
| Основная бизнес-логика | `Features/Chat/ViewModels/ChatViewModel.swift` |
| Сетевой шлюз | `Services/Network/NetworkService.swift` |
| Персистентность | `Data/PersistenceController.swift` |

## Ключевые технологии

| Категория | Технология |
|-----------|------------|
| UI | SwiftUI |
| Data | SwiftData |
| DI | Factory |
| Логирование | Pulse |
| Тестирование | Swift Testing, XCTest, SnapshotTesting |
| Генерация кода | XcodeGen, SwiftGen |
| Линтинг | SwiftLint |
| Целевая платформа | iOS 26.2 |

## Структура проекта

```
Chat/
├── App/                    # Точка входа (ChatApp.swift)
├── Features/               # Функциональные модули
│   ├── Chat/              # Экран чата (Views, ViewModels, Components)
│   ├── History/           # Экран истории
│   ├── Settings/          # Экран настроек
│   └── Common/            # Общие UI-компоненты
├── Core/                  # Универсальные типы, расширения, утилиты
├── Data/                  # Конфигурация SwiftData (PersistenceController)
├── Design/                # Дизайн-система (Colors, Spacing, Typography)
├── Models/                # Модели данных
│   ├── API/               # Модели запросов/ответов API
│   ├── LMStudio/          # Модели LM Studio
│   └── *.swift            # Доменные модели (Message, ChatSession и др.)
├── Services/              # Сервисы бизнес-логики
│   ├── Auth/              # Аутентификация (Keychain)
│   ├── Chat/              # Сервис чата
│   ├── Network/           # HTTP-клиент, мониторинг сети
│   └── Errors/            # Определения ошибок
├── Resources/             # Ресурсы, Info.plist, entitlements
├── ChatTests/             # Unit-тесты
├── ChatUITests/           # UI-тесты (Page Object Model)
├── Tools/Scripts/         # Скрипты автоматизации на Swift
└── Docs/                  # Документация внешних API
```

## API URL (LM Studio v1)

Базовый URL по умолчанию: `http://192.168.1.91:64721`

| Метод | Эндпоинт | Описание |
|-------|----------|----------|
| GET | `/api/v1/models` | Получить список доступных моделей |
| POST | `/api/v1/models/load` | Загрузить модель в память |
| POST | `/api/v1/models/unload` | Выгрузить модель из памяти |
| POST | `/api/v1/models/download` | Скачать модель из репозитория |
| GET | `/api/v1/models/download/{jobId}` | Получить статус скачивания |
| POST | `/api/v1/chat` | Стриминг чат-комплишена (SSE) |

## Экраны и навигация

### Основные роуты (NavigationStack)

| Путь | Экран (View) | ViewModel | Описание |
|------|--------------|-----------|----------|
| `/` | `ChatView` | `ChatViewModel` | Главный экран чата |
| `/history` | `HistoryView` | — | История чатов (модальный) |
| `/model-picker` | `ModelPicker` | — | Выбор модели (модальный) |

### Схема навигации

```
ChatView (root)
├── tokenRequiredView (если не авторизован)
│   └── ShieldView (3D щит для ввода токена)
├── emptyStateView (если нет сообщений)
├── ChatMessagesView (список сообщений)
├── MessageInputView (поле ввода)
│
├── HistoryView (sheet)
│   └── SessionRowView (строки сессий)
│
├── ModelPicker (sheet)
│   └── ModelRowView (строки моделей)
│
├── ConsoleView (sheet) — Pulse отладка
└── ShareSheet (sheet) — экспорт в Markdown
```

## Модели и сущности

### Доменные модели (SwiftData)

| Модель | Файл | Назначение | Связи |
|--------|------|------------|-------|
| `Message` | `Models/Message.swift` | Отдельное сообщение в чате | Принадлежит `ChatSession` (relationship), содержит `sessionId` |
| `ChatSession` | `Models/ChatSession.swift` | Сессия чата (история) | Содержит массив `Message` (каскадное удаление) |

**Связи между SwiftData моделями:**
```
ChatSession (1) ──────< Message (N)
     │
     ├── id: UUID
     ├── title: String
     ├── modelName: String
     ├── messages: [Message] @Relationship(deleteRule: .cascade)
     │
     └── sortedMessages: [Message] (computed)
```

### Модели API (LM Studio)

| Модель | Файл | Назначение |
|--------|------|------------|
| `LMModelsResponse` | `Models/LMModelsResponse.swift` | Ответ API списка моделей |
| `LMChatRequest` | `Models/LMStudio/LMChatRequest.swift` | Запрос чата (messages, model, temperature) |
| `LMChatResponse` | `Models/LMStudio/LMChatResponse.swift` | Ответ чата (output, stats, responseId) |
| `LMOutputItem` | `Models/LMStudio/LMChatResponse.swift` | Элемент вывода: message/toolCall/reasoning |
| `LMMessageContent` | `Models/LMStudio/LMMessageContent.swift` | Текстовое сообщение |
| `LMToolCall` | `Models/LMStudio/LMToolCall.swift` | Вызов инструмента |
| `LMReasoningContent` | `Models/LMStudio/LMReasoningContent.swift` | Рассуждения модели (chain of thought) |
| `LMStats` | `Models/LMStudio/LMStats.swift` | Статистика генерации |
| `LMSEvent` | `Models/LMStudio/LMSEvent.swift` | SSE событие стрима |
| `LMStreamChunk` | `Models/LMStudio/LMStreamChunk.swift` | Чанк стрим-данных |
| `LMDoneEvent` | `Models/LMStudio/LMDoneEvent.swift` | Финальное SSE событие |
| `LMError` | `Models/LMStudio/LMError.swift` | Ошибка от API |
| `LMModelLoadRequest` | `Models/LMStudio/LMModelLoadRequest.swift` | Запрос загрузки модели |
| `LMModelLoadResponse` | `Models/LMStudio/LMModelLoadResponse.swift` | Ответ загрузки модели |
| `LMModelUnloadRequest` | `Models/LMStudio/LMModelUnloadRequest.swift` | Запрос выгрузки модели |
| `LMDownloadRequest` | `Models/LMStudio/LMDownloadRequest.swift` | Запрос скачивания модели |
| `LMDownloadResponse` | `Models/LMStudio/LMDownloadResponse.swift` | Ответ скачивания |
| `LMDownloadStatus` | `Models/LMStudio/LMDownloadStatus.swift` | Статус скачивания |
| `LMProviderInfo` | `Models/LMStudio/LMProviderInfo.swift` | Информация о провайдере |
| `LMInput` | `Models/LMStudio/LMInput.swift` | Входящие данные |
| `LMMessageContent` | `Models/LMStudio/LMMessageContent.swift` | Контент сообщения |
| `LMModelLoadConfig` | `Models/LMStudio/LMModelLoadConfig.swift` | Конфиг загрузки модели |
| `LMToolCallMetadata` | `Models/LMStudio/LMToolCallMetadata.swift` | Метаданные tool call |
| `LMInvalidToolCall` | `Models/LMStudio/LMInvalidToolCall.swift` | Некорректный вызов инструмента |

### Вспомогательные модели

| Модель | Файл | Назначение |
|--------|------|------------|
| `ModelInfo` | `Models/ModelInfo.swift` | Информация о доступной модели |
| `ModelCapabilities` | `Models/ModelCapabilities.swift` | Возможности модели (vision, toolUse) |
| `ModelQuantization` | `Models/ModelQuantization.swift` | Уровень квантования модели |
| `ToolCall` | `Models/ToolCall.swift` | Вызов инструмента (доменная) |
| `ToolCallResult` | `Models/ToolCallResult.swift` | Результат выполнения инструмента |
| `ToolDefinition` | `Models/ToolDefinition.swift` | Определение инструмента для API |
| `ToolParameters` | `Models/ToolParameters.swift` | Параметры инструмента (JSON Schema) |
| `ToolProperty` | `Models/ToolProperty.swift` | Свойство параметра инструмента |
| `ToolCallsResponse` | `Models/ToolCallsResponse.swift` | Ответ с вызовами инструментов |
| `GenerationStats` | `Models/GenerationStats.swift` | Статистика генерации (токены, скорость) |

### Поток данных (Data Flow)

```
User Input
    │
    ▼
ChatViewModel
    │
    ├──► ChatService ──► NetworkService ──► HTTPClient
    │                                            │
    │                                            ▼
    │                                    LM Studio API
    │                                    (/api/v1/chat)
    │                                            │
    ▼                                            ▼
SwiftData                                   SSE Stream
(ChatSession ◄── Message)                    │
    ▲                                          │
    │                                    SSEParser
    │                                          │
    └──────────────────────────────────────────┘
                    ChatViewModel.updateContent()
```

### Жизненный цикл сообщения

```
1. User отправляет сообщение
   │
   ▼
2. ChatViewModel создает Message(role: "user")
   │
   ▼
3. ChatService отправляет POST /api/v1/chat
   │
   ▼
4. Сервер возвращает SSE поток
   │
   ├──► SSEParser парсит чанки
   │
   ▼
5. ChatViewModel создает Message(role: "assistant", isGenerating: true)
   │
   ▼
6. При каждом чанке: message.content += chunk
   │
   ▼
7. При получении LMDoneEvent: message.isGenerating = false
   │
   ▼
8. SwiftData сохраняет сообщение
```

## Важные файлы и директории

### Экраны (Views)

| Файл | Директория | Назначение |
|------|------------|------------|
| `ChatView.swift` | `Features/Chat/Views/` | Главный экран чата |
| `ChatMessagesView.swift` | `Features/Chat/Views/` | Список сообщений |
| `MessageInputView.swift` | `Features/Chat/Views/` | Поле ввода сообщения |
| `MessageBubble.swift` | `Features/Chat/Components/` | Пузырь сообщения |
| `ShieldView.swift` | `Features/Chat/Components/` | 3D щит для ввода токена |
| `HistoryView.swift` | `Features/History/Views/` | Экран истории чатов |
| `SessionRowView.swift` | `Features/History/Components/` | Строка сессии в истории |
| `ModelPicker.swift` | `Features/Settings/Views/` | Экран выбора модели |
| `ModelRowView.swift` | `Features/Settings/Components/` | Строка модели в пикере |

### ViewModels

| Файл | Директория | Назначение |
|------|------------|------------|
| `ChatViewModel.swift` | `Features/Chat/ViewModels/` | Управление чатом, сообщениями, генерацией |
| `AppConfig.swift` | `Features/Settings/ViewModels/` | Конфигурация приложения (Singleton) |

### Сервисы (Services)

| Файл | Директория | Назначение |
|------|------------|------------|
| `ChatService.swift` | `Services/Chat/` | Основной сервис для API чата |
| `ChatSessionManager.swift` | `Services/Chat/` | Управление сессиями SwiftData |
| `ChatStreamService.swift` | `Services/Chat/` | SSE стриминг ответов |
| `NetworkService.swift` | `Services/Network/` | HTTP клиент для LM Studio API |
| `HTTPClient.swift` | `Services/Network/` | Низкоуровневый HTTP клиент |
| `SSEParser.swift` | `Services/Network/` | Парсинг SSE потока |
| `NetworkMonitor.swift` | `Services/Network/` | Мониторинг сетевого подключения |
| `AuthorizationProvider.swift` | `Services/Network/` | Провайдер авторизации |
| `KeychainHelper.swift` | `Services/Auth/` | Работа с Keychain |
| `DeviceIdentity.swift` | `Services/Auth/` | Идентификация устройства |

### Модели (Models)

| Файл | Назначение |
|------|------------|
| `Message.swift` | Модель сообщения (SwiftData) |
| `ChatSession.swift` | Модель сессии чата (SwiftData) |
| `ModelInfo.swift` | Информация о модели |
| `LMModelsResponse.swift` | Ответ API списка моделей |
| `ToolCall.swift` | Вызов инструмента |
| `GenerationStats.swift` | Статистика генерации |

### Конфигурация

| Файл | Назначение |
|------|------------|
| `project.yml` | Конфигурация XcodeGen |
| `swiftgen.yml` | Конфигурация SwiftGen |
| `.swiftlint.yml` | Правила SwiftLint |
| `GUIDELINES.md` | Полное руководство по разработке |
| `IMPROVEMENT_PLAN.md` | План улучшений |
| `VERSIONING.md` | Управление версиями |
| `Tools/Scripts/Sources/Scripts/Core/Versions.swift` | Централизованное управление версиями |

## Сборка и запуск

### Требования
- Xcode 15.0+
- XcodeGen 2.44.1
- SwiftGen 6.6.3
- SwiftLint 0.63.2
- Swift 6.0

### Команды (обязательно использовать `swift run scripts`)

| Команда | Описание |
|---------|----------|
| `swift run scripts setup` | Генерация проекта Xcode (XcodeGen + SwiftGen) |
| `swift run scripts check` | Линтинг, сборка, тесты, покрытие 100%, коммит + пуш |
| `swift run scripts ship` | Release-сборка и деплой на устройство Saint Celestine |
| `swift run scripts download-docs` | Обновление локальной документации API |

### Workflow

**Check** (обязательно перед каждым push):
- Генерирует проект (XcodeGen + SwiftGen)
- Проверяет стиль кода (SwiftLint)
- Собирает и запускает тесты (xcodebuild test)
- Проверяет покрытие кода (100%)
- Коммитит и пушит автоматически

**Ship** (для доставки на реальное устройство):
- Предварительно: `swift run scripts check` должен пройти
- Собирает в Release конфигурации с code signing
- Устанавливает на устройство Saint Celestine
- Требует настроенный sudo (`swift run scripts configure-sudo`)

## Конвенции разработки

### Стиль кода
- **Язык**: Русский (комментарии, документация, сообщения коммитов)
- **SwiftLint**: Ограничение 160 символов в строке, требует `@MainActor` на ViewModel
- **Архитектура**: Организация по функциональным модулям с четким разделением ответственности

### Стандарты тестирования
- **Unit-тесты**: Фреймворк Swift Testing с паттерном AAA
- **UI-тесты**: Паттерн Page Object Model в `ChatUITests/Pages/`
- **Снапшоты**: SnapshotTesting для визуальной регрессии
- **Покрытие**: Цель — 100% покрытие кода

### Конвенции именования
- ViewModels: `*ViewModel.swift` с `@MainActor`
- Views: `*View.swift`
- Services: `*Service.swift`, `*Manager.swift`
- Models: PascalCase (например, `Message`, `ChatSession`)

### Использование дизайн-системы
- **Colors**: Использовать константы `AppColors`, никогда не `Color.`
- **Spacing**: Использовать константы `AppSpacing`, никогда не магические числа в `.padding()`
- **Typography**: Использовать константы `AppTypography`
- Файлы: `Design/Typography.swift`, `Design/Spacing.swift`, `Design/Colors.swift`

### Безопасность
- Секреты хранятся только в Keychain
- Отсутствуют захардкоженные учетные данные

### Документация
- Все публичные API требуют Docstrings на русском языке
- В исходных файлах обязательны ссылки на документацию: `// MARK: - Связь с документацией:`

## Принципы архитектуры

1. **Внедрение зависимостей**: Использовать `@Injected` из Factory
2. **Единственная ответственность**: Сервисы имеют узкую, сфокусированную ответственность
3. **По функциональным модулям**: Код организован по фичам для удобства поддержки
4. **AuthorizationProvider**: Вся логика авторизации изолирована через протоколы

## Работа с задачами

### Основные流程

#### Обычная разработка
```
1. Пользователь говорит, что нужно сделать
2. Делаю работу согласно инструкциям
3. Запускаю swift run scripts check
4. Если есть ошибки → прошу разрешение игнорировать (формат ниже)
5. Если check прошёл → коммит и пуш в скрипте → работа завершена
```

#### Разработка UI (визуальные элементы)
```
1. То же что выше
2. Запускаю swift run scripts ship
3. Пользователь проверяет на устройстве
4. Работа завершена
```

**После ship — короткая сводка:**
- Что изменилось
- Куда смотреть (экран, компонент)
- Как тестировать (пошагово)

### Правила при ошибках в check

1. **Сначала пытаюсь исправить** всеми доступными способами
2. Если **совсем не получается** исправить — прошу разрешение игнорировать

**Формат вопроса:**
```
Можно я буду игнорировать ошибку: ТЕКСТ_ОШИБКИ?
```

Только после ответа "да" или "можно" — продолжаю.

### Git-рабочий процесс

- **Один коммит в ветке**: Все изменения объединяются через `git commit --amend`
- **Rebase** на актуальную релизную ветку перед коммитом
- **Force push**: `git push --force-with-lease` для amended коммитов
- **Сообщения коммитов**: На русском языке, описывают "почему", а не "что"

## Обязательные файлы для поддержания актуальности

При любых изменениях в структуре проекта, ключевых компонентах или архитектуре, **обязательно** проверить и обновить:

1. `.junie/context.json` — техническая карта проекта
2. `GUIDELINES.md` — общее руководство
3. `.junie/instructions.md` — специфические инструкции для AI

Информационная связность — залог корректной работы будущих сессий.

## Архитектурные особенности

### Внедрение зависимостей (Dependency Injection)

Проект использует **Factory** для управления зависимостями. Все регистрации в `Core/Container+Registrations.swift`:

```swift
@MainActor
extension Container {
    var sessionManager: Factory<ChatSessionManager> { ... }.singleton
    var networkService: Factory<NetworkService> { ... }.singleton
    var chatService: Factory<ChatService> { ... }.singleton
    var networkMonitor: Factory<NetworkMonitor> { ... }.singleton
}
```

Использование в коде:
```swift
@Injected(\.sessionManager) private var sessionManager
@Injected(\.chatService) private var chatService
```

### Concurrency (async/await)

- Все сервисы помечены `@MainActor` для безопасной работы с UI
- Используется Swift Concurrency: `async`, `await`, `Task`
- `AsyncThrowingStream` для SSE стриминга
- `Combine` для наблюдения за `NetworkMonitor`

### Персистентность данных

**SwiftData** через `PersistenceController` (`Data/PersistenceController.swift`):
- Основной контекст: `container.mainContext`
- Схема: `[ChatSession.self, Message.self]`
- Поддержка in-memory режима для тестов
- Методы: `save()`, `deleteAll()`

### Безопасное хранение

**Keychain** через `KeychainHelper` (`Services/Auth/KeychainHelper.swift`):
- Хранение API токенов
- Уровень доступа: `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`
- Методы: `get(key:)`, `set(key:value:)`, `delete(key:)`

### Обработка ошибок

| Тип | Файл | Описание |
|-----|------|----------|
| `NetworkError` | `Services/Errors/NetworkError.swift` | invalidURL, noData, decodingError, serverError, unauthorized, rateLimited, networkError |
| `AuthError` | `Services/Errors/AuthError.swift` | Ошибки аутентификации |

### Логирование и мониторинг

**Pulse** (`Services/NetworkConfiguration.swift`):
- Интеграция через `URLSessionProxyDelegate()`
- Вызов консоли: двойной тап по заголовку "Chat" (ChatView.swift:162)
- `import Pulse` в NetworkConfiguration
- `import PulseUI` в ChatView для отображения ConsoleView

Логи скриптов: директория `Logs/Check/`

### Тестирование

| Test Plan | Файл | Назначение |
|-----------|------|------------|
| UnitTests | `TestPlans/UnitTests.xctestplan` | Unit тесты (Swift Testing) |
| UITests | `TestPlans/UITests.xctestplan` | UI тесты (XCTest + Page Object Model) |
| AllTests | `TestPlans/AllTests.xctestplan` | Все тесты с параллелизацией |

### Автоматизация (Swift Scripts)

Swift-based CLI в `Tools/Scripts/` (точка входа `Scripts.swift`):

| Команда | Файл | Назначение |
|---------|------|------------|
| Setup | `Commands/Setup.swift` | XcodeGen + SwiftGen генерация |
| Check | `Commands/Check.swift` | SwiftLint + тесты + сборка (default) |
| Ship | `Commands/Ship.swift` | Release сборка + деплой |
| DownloadDocs | `Commands/DownloadDocs.swift` | Обновление документации |
| UpdateDocsLinks | `Commands/UpdateDocsLinks.swift` | Обновление ссылок на документацию |
| ConfigureSudo | `Commands/ConfigureSudo.swift` | Настройка беспарольного sudo |

Запуск: `./scripts <command>`

### Версионирование

Централизованное управление версиями в `Tools/Scripts/Sources/Scripts/Core/Versions.swift`:
- XcodeGen, SwiftGen, SwiftLint
- SPM зависимости: Factory, Pulse, SnapshotTesting
- iOS Deployment Target, Swift version

### Внешние интеграции

| Компонент | Интеграция | Назначение |
|-----------|------------|------------|
| LM Studio | REST API v1 | Локальный LLM сервер (основной) |
| Apple Keychain | Security framework | Безопасное хранение токенов |
| Pulse | URLSessionProxyDelegate | Сетевой мониторинг и логирование |
| NWPathMonitor | Network framework | Мониторинг статуса сети |

Документация также скачивается для Ollama (_docs), но runtime-интеграции нет.

### Ограничения iOS-разработки

- **Personal Team**: Без CloudKit, Push Notifications, IAP, Apple Pay
- **Code Signing**: Разработка использует автоматическое подписание для симуляторов
- **Целевое устройство**: «Saint Celestine» (реальный iPhone)

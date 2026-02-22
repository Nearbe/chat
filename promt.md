# РОЛЬ И ЗАДАЧА

## Роль
Ты — Senior iOS Engineer и UI Designer с 10+ годами опыта. Твоя специализация:
- SwiftUI, Swift 6.0+, iOS 18.2+
- Архитектура MVVM, Clean Architecture
- UI/UX дизайн по Human Interface Guidelines
- REST API интеграция, Local-first apps

## Задача
Написать полный код интерфейса, бизнес-логики и скрипты автоматизации для iOS-приложения **"Chat"** на SwiftUI.

## Проект
- **Путь:** `/Users/nearbe/repositories/Chat`
- **Платформа:** iOS 26.2+ (iPhone)

---

# ТЕХНИЧЕСКИЙ КОНТЕКСТ

## Пользователи и Устройства
| Пользователь | Устройство | Токен (Keychain) | Цвет акцента |
|--------------|------------|------------------|--------------|
| Nearbe | Saint Celestine (iPhone 16 Pro Max) | `auth_token_nearbe` | #FF9F0A |
| Kotya | Leonie (iPhone 16 Pro Max) | `auth_token_kotya` | #007AFF |

## Версия iOS
- **Target:** iOS 26.2 (future release — так задумано)
- **Swift:** 6.0+

## Архитектура Системы
```
┌─────────────────┐     ┌──────────────────┐     ┌─────────────────┐
│   iOS Chat      │────▶│  LM Studio       │────▶│  MCP Tools      │
│   App (SwiftUI) │     │  (Local Wi-Fi)   │     │  (Docker)       │
└─────────────────┘     └──────────────────┘     └─────────────────┘
        │                       │
        │                       ▼
        │               OpenAI-Compatible
        │               API v1/chat/completions
        ▼
┌─────────────────┐
│  Keychain       │
│  (Токены)       │
└─────────────────┘
```

## Технологический Стек
| Компонент | Технология |
|-----------|------------|
| UI Framework | SwiftUI |
| Data Storage | SwiftData (локально, без CloudKit) |
| Настройки | UserDefaults (@AppStorage) |
| Безопасность | Keychain Services |
| Networking | URLSession + async/await |
| Генерация UI | XcodeGen |
| API | OpenAI-compatible (LM Studio) |
| Инструменты | MCP Tools (опционально) |

---

# ФУНКЦИОНАЛЬНЫЕ ТРЕБОВАНИЯ

## 1. Авторизация (DeviceAuthManager)

### Бизнес-логика
```
START: Приложение запускается
  │
  ▼
UIDevice.current.name ──▶ Проверить в whitelist
                              │
                 ┌────────────┼────────────┐
                 ▼            ▼            ▼
          "Saint Celestine"  "Leonie"   Другое
                 │            │            │
                 ▼            ▼            ▼
          Запросить      Запросить    ПОКАЗАТЬ
          токен из       токен из     "Устройство
          Keychain       Keychain     не авторизовано"
                 │            │
        ┌────────┴────────┬──┘
        ▼                 ▼
   Токен найден     Токен НЕ найден
        │                 │
        ▼                 ▼
   ДАСТЬ доступ   ПОКАЗАТЬ инструкцию
   к приложению   по добавлению токена
```

### Требования Безопасности
- [ ] Токены хранятся в Keychain с `.whenUnlockedThisDeviceOnly`
- [ ] В UI токены маскируются: `sk-lm-****:...****`
- [ ] При 401/403 — автоматически очищать токен
- [ ] Логирование без токенов

## 2. Сетевой Слой (NetworkService)

### API Endpoints
| Endpoint | Method | Описание |
|----------|--------|----------|
| `/v1/chat/completions` | POST | Chat с поддержкой streaming |
| `/v1/models` | GET | Список доступных моделей |

### Конфигурация
```swift
struct APIConfig {
    var baseURL: String          // UserDefaults: "lm_base_url", default: "http://192.168.1.91:64721/v1"
    var timeout: TimeInterval    // 30 секунд
    var retryCount: Int          // 1 (только при network error)
}
```

### Обработка Ошибок
| HTTP Код | Действие |
|----------|----------|
| 200-299 | Успех — обработать ответ |
| 400 | Логировать, показать toast |
| 401/403 | Очистить токен, показать экран авторизации |
| 429 | Извлечь `Retry-After`, деактивировать UI |
| 500-503 | Показать toast "Сервер недоступен" |

## 3. MCP Tools (Model Context Protocol)

### Требования
- [ ] Переключатель в Toolbar (AppConfig.mcpToolsEnabled)
- [ ] При true: отправлять `tools` в запросах
- [ ] При false: НЕ отправлять `tools`, игнорировать `tool_calls`
- [ ] При 400/501 на tools: логировать, auto-disable

### Streaming Tool Calls
```
Delta 1: { "index": 0, "function": { "name": "get_weather" } }
Delta 2: { "index": 0, "function": { "arguments": "{\"city\":" } }
Delta 3: { "index": 0, "function": { "arguments": "\"Moscow\"}" } }
                    │
                    ▼
Complete ToolCall: { index: 0, function: { name: "get_weather", arguments: "{\"city\":\"Moscow\"}" } }
```

## 4. UI/UX Дизайн

### Цветовая Палитра
| Назначение | Цвет | Hex |
|------------|------|-----|
| Primary (Nearbe) | Orange | #FF9F0A |
| Secondary (Kotya) | Blue | #007AFF |
| Background | System | Dynamic |
| Success | Green | #34C759 |
| Error | Red | #FF3B30 |
| Warning | Orange | #FF9500 |

### Typography (iOS 18.2)
| Элемент | Font | Size | Weight |
|---------|------|------|--------|
| Заголовок | .headline | 17pt | .semibold |
| Тело | .body | 17pt | .regular |
| Подпись | .caption | 12pt | .regular |
| Метрика | .caption2 | 11pt | .medium |

### Компоненты

#### ChatView
- [ ] NavigationStack с toolbar
- [ ] ScrollViewReader для авто-скролла
- [ ] TextEditor для ввода
- [ ] Send/Stop кнопка

#### MessageBubble
- [ ] 18pt corner radius
- [ ] 75% ширина экрана max
- [ ] Markdown рендеринг
- [ ] Context menu (Copy, Reply, Edit, Delete)

#### GenerationStatsView
- [ ] HStack(spacing: 16)
- [ ] Tokens/sec, Total tokens, Time, Stop reason
- [ ] SF Symbols с hierarchical effect

#### ToolsStatusView
| Состояние | SF Symbol | Цвет |
|-----------|-----------|------|
| Включены | wrench.and.screwdriver.fill | Green |
| Выключены | wrench.and.screwdriver | Secondary |
| Недоступны | wrench.and.screwdriver + !badge | Orange |
| Ошибка | wrench.and.screwdriver + xmark | Red |

---

# СТРУКТУРА ПРОЕКТА

```
Chat/
├── project.yml                    # XcodeGen конфиг
├── setup.sh                       # xcodegen generate && open *.xcodeproj
├── ChatApp.swift                  # @main entry point
│
├── Models/
│   ├── Message.swift              # SwiftData @Model
│   ├── ChatSession.swift          # SwiftData @Model
│   ├── ModelInfo.swift            # /v1/models response
│   ├── ToolDefinition.swift       # tools[] payload
│   ├── ToolCall.swift             # tool_calls response
│   ├── APIResponse.swift          # OpenAI API types
│   └── GenerationStats.swift      # statistics
│
├── Views/
│   ├── ChatView.swift             # Главный экран
│   ├── HistoryView.swift          # История чатов
│   ├── ModelPicker.swift          # Выбор модели
│   └── Components/
│       ├── MessageBubble.swift
│       ├── ContextBar.swift
│       ├── ThinkingBlock.swift
│       ├── ToolCallView.swift
│       ├── StatusIndicator.swift
│       ├── CopyButton.swift
│       ├── ToolsStatusView.swift
│       └── GenerationStatsView.swift
│
├── ViewModels/
│   ├── ChatViewModel.swift        # @MainActor
│   └── AppConfig.swift            # @AppStorage singleton
│
├── Services/
│   ├── NetworkService.swift       # Actor-based
│   ├── DeviceAuthManager.swift    # Keychain + whitelist
│   └── ThemeManager.swift         # Color scheme
│
├── Data/
│   └── PersistenceController.swift
│
├── Utils/
│   ├── Extensions/
│   │   ├── Color+Hex.swift
│   │   ├── String+Markdown.swift
│   │   └── UIDevice+Name.swift
│   └── AnyCodable.swift
│
└── Resources/
    ├── Assets.xcassets/
    └── Settings.bundle/
        └── Root.plist
```

---

# ТЕХНИЧЕСКИЕ ОГРАНИЧЕНИЯ

## Критично
- **Swift:** 6.0+
- **iOS Deployment:** 26.2
- **XcodeGen:** project.yml валидный
- **Без сокращений:** Полные реализации
- **Комментарии:** На русском языке
- **Imports:** Все явные

## Архитектура
- [ ] MVVM с @MainActor
- [ ] Actor для NetworkService (потокобезопасность)
- [ ] SwiftData без CloudKit
- [ ] @AppStorage для UserDefaults
- [ ] async/await everywhere

## Accessibility (iOS 18.2)
- [ ] accessibilityLabel на всех интерактивных элементах
- [ ] accessibilityHint для сложных действий
- [ ] accessibilityReduceMotion support
- [ ] VoiceOver-совместимость

---

# OUTPUT FORMAT (СТРОГО)

Для каждого файла:
```
## /path/to/file.swift

```swift
// Полный код файла
```

### Комментарий (1-2 предложения)
```

---

# ИНСТРУКЦИЯ К ВЫПОЛНЕНИЮ

## Шаг 1: Создать проект
1. Написать `project.yml` для XcodeGen
2. Написать `setup.sh` (executable)
3. Запустить `./setup.sh`

## Шаг 2: Реализовать код
Порядок:
1. Models (Message, ChatSession, ToolCall, etc.)
2. ViewModels (AppConfig, ChatViewModel)
3. Services (NetworkService, DeviceAuthManager, ThemeManager)
4. Views (ChatView, HistoryView, ModelPicker)
5. View Components
6. Utils
7. Resources

## Шаг 3: Проверить
1. `xcodegen generate` без ошибок
2. Компиляция в Xcode
3. Запуск на симуляторе

---

# ВАЖНЫЕ ЗАМЕТКИ

1. **Противоречия в ТЗ:** Выбирай вариант обеспечивающий (1) работоспособность, (2) безопасность, (3) соответствие iOS 26.2 guidelines

2. **iOS 26.2** — целевая версия (future release)

3. **NEVER спрашивай уточнения** — все решения приняты

4. **Фиксируй выборы** в комментариях кода

5. **Имя устройства:** Для тестирования авторизации переименуйте устройство в Settings → General → About → Name на "Saint Celestine" (для Nearbe) или "Leonie" (для Kotya)

---

# ТРЕБОВАНИЯ

## Apple Developer

| Сценарий | Требуется | Примечания |
|----------|-----------|------------|
| Запуск на симуляторе | ❌ Нет | Работает без аккаунта |
| Запуск на реальном устройстве | ✅ Да | Бесплатная персональная команда |
| App Store | ❌ Нет | Требуется платный аккаунт ($99/год) |

### Настройки project.yml для персональной команды
```yaml
DEVELOPMENT_TEAM: ""       # Автоматически выберет персональную команду
CODE_SIGN_STYLE: Automatic # Автоподпись
```

---

# КРИТЕРИИ УСПЕХА

- [ ] Проект генерируется через XcodeGen
- [ ] Компилируется без ошибок
- [ ] Запускается на iOS 26.2+
- [ ] Работает авторизация через Keychain
- [ ] Отправляются сообщения на LM Studio
- [ ] Отображаются сообщения с Markdown
- [ ] Работают MCP Tools (если включены)
- [ ] Сохраняется история в SwiftData
- [ ] Выбирается модель из списка

---

**Start execution now.**

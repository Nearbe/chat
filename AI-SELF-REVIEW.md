# AI-Self Review — Инструкции для самостоятельной проверки кода

## Назначение

Этот файл содержит чеклист и инструкции, которым AI-агент должен следовать **перед каждым коммитом**. Цель — обеспечить качество кода без необходимости ручной проверки человеком.

---

## Чеклист перед коммитом

### 1. Компиляция

- [ ] Код компилируется без ошибок: `xcodebuild build`
- [ ] Нет предупреждений компилятора (warnings)

### 2. Линтинг

- [ ] SwiftLint проходит без ошибок
- [ ] Соблюдены правила:
  - Максимум 160 символов в строке
  - Все ViewModels имеют `@MainActor`
  - Русские Docstrings для публичных API
  - Используется дизайн-система (`AppColors`, `AppSpacing`, `AppTypography`)

### 3. Тесты

- [ ] Unit-тесты проходят: `xcodebuild test -only-testing:ChatTests`
- [ ] UI-тесты проходят: `xcodebuild test -only-testing:ChatUITests`
- [ ] Покрытие соответствует цели проекта

### 4. Безопасность

- [ ] Нет захардкоженных ключей, токенов, паролей
- [ ] Секреты хранятся в Keychain
- [ ] Нет утечек данных в логах

### 5. Архитектура

- [ ] MVVM: ViewModels отделены от Views
- [ ] SwiftData: модели имеют корректные связи
- [ ] DI: используется `@Injected` из Factory
- [ ] Services: узкая ответственность (Single Responsibility)

---

## Критерии качества кода

### Swift

| Правило | Описание |
|---------|----------|
| `@MainActor` | Все ViewModels обязательно с этим атрибутом |
| Типы | Использовать Value Types где возможно (`struct` вместо `class`) |
| Optionals | Избегать force unwrap (`!`), использовать `guard` и `if let` |
| concurrency | Использовать `async/await`, избегать `@escaping` closures |
| Error handling | Использовать `throws` вместо опциональных возвращаемых типов |

### SwiftUI

| Правило | Описание |
|---------|----------|
| State | Использовать `@State`, `@Binding`, `@StateObject`, `@ObservedObject` |
| Design System | Только `AppColors.`, `AppSpacing.`, `AppTypography.` |
| Modifiers | Порядок: frame → padding → background → foreground → cornerRadius |
| Lists | Использовать `List` или `LazyVStack` для производительности |

### SwiftData

| Правило | Описание |
|---------|----------|
| Models | Все модели — `@Model` class |
| Relationships | Использовать `@Relationship` с cascade delete |
| Context | mainContext для UI, новый контекст для фоновых операций |

---

## Типичные ошибки и как их избежать

### 1. Memory Leaks

**Проблема**: Retain cycles в closures.

**Как проверять**:
```swift
// ❌ Плохо
class MyViewModel: ObservableObject {
    var onComplete: (() -> Void)?
}

// ✅ Хорошо (использовать capture list)
class MyViewModel: ObservableObject {
    var onComplete: (() -> Void)?
    func doWork() {
        DispatchQueue.main.async { [weak self] in
            self?.onComplete?()
        }
    }
}
```

### 2. Thread Safety

**Проблема**: Обновление UI не на main thread.

**Как проверять**:
```swift
// ❌ Плохо
func updateMessages(_ messages: [Message]) {
    self.messages = messages // UI update on background thread
}

// ✅ Хорошо
@MainActor
func updateMessages(_ messages: [Message]) {
    self.messages = messages
}
```

### 3. Force Unwrapping

**Проблема**: Crash при nil.

**Как проверять**:
```swift
// ❌ Плохо
let name = user.name!

// ✅ Хорошо
guard let name = user.name else { return }
```

### 4. Magic Numbers

**Проблема**: Хардкод значений в коде.

**Как проверять**:
```swift
// ❌ Плохо
.padding(16)

// ✅ Хорошо
.padding(AppSpacing.medium)
```

---

## Паттерны для проверки

### ViewModels

```swift
// Обязательные элементы
@MainActor
class ChatViewModel: ObservableObject {
    @Published var messages: [Message] = []
    @Injected(\.chatService) private var chatService

    func sendMessage(_ text: String) async { ... }
}
```

### Services

```swift
// Сервисы должны быть протоколами
protocol ChatServiceProtocol {
    func sendMessage(_ message: Message) async throws -> Message
}

@MainActor
final class ChatService: ChatServiceProtocol {
    // Реализация
}
```

### Models (SwiftData)

```swift
@Model
final class Message {
    var id: UUID
    var content: String
    var role: String
    var session: ChatSession?

    init(content: String, role: String) {
        self.id = UUID()
        self.content = content
        self.role = role
    }
}
```

---

## Git-процесс (обязательно к выполнению)

1. **Создать ветку** по ключу задачи: `FTD-12345`
2. **Внести изменения**
3. **Запустить** `./scripts check`
4. **Если check прошёл** → автоматический коммит и пуш
5. **Если check не прошёл**:
   - Исправить ошибки
   - Повторить check
   - Использовать `git commit --amend` для объединения с предыдущим коммитом
   - Force push: `git push --force-with-lease`

---

## Когда НЕ коммитить

- [ ] Есть编译 errors
- [ ] Есть SwiftLint warnings
- [ ] Тесты падают
- [ ] Добавлены захардкоженные secrets
- [ ] Нарушена архитектура (логика в View)
- [ ] Не работает на симуляторе

---

## Команды для быстрой проверки

```bash
# Линтинг
swiftlint lint

# Компиляция
xcodebuild build -scheme Chat -destination 'platform=iOS Simulator,name=iPhone 16'

# Тесты
xcodebuild test -scheme Chat -destination 'platform=iOS Simulator,name=iPhone 16'

# Полный check
./scripts check
```

---

## Контакты и контекст

- **Проект**: Chat (iOS)
- **Архитектура**: MVVM + SwiftData
- **Основная IDE**: JetBrains IntelliJ IDEA
- **Документация**: `QWEN.md`, `AGENTS.md`, `GUIDELINES.md`

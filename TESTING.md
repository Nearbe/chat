# Руководство по тестированию

## Обзор

Проект Chat использует три уровня тестирования:
1. **Unit-тесты** — Swift Testing
2. **UI-тесты** — XCTest + Page Object Model
3. **Snapshot-тесты** — SnapshotTesting

---

## Структура тестов

```
ChatTests/                      # Unit-тесты
├── Services/
│   ├── ChatServiceTests.swift
│   └── NetworkServiceTests.swift
├── ViewModels/
│   └── ChatViewModelTests.swift
└── Models/
    └── MessageTests.swift

ChatUITests/                    # UI-тесты
├── Pages/
│   ├── ChatPage.swift
│   └── MessageInputPage.swift
├── Flows/
│   └── SendMessageFlow.swift
└── ChatUITests.swift
```

---

## Unit-тесты

### Фреймворк

Используется **Swift Testing** с паттерном AAA (Arrange-Act-Assert).

### Пример теста

```swift
import Testing

@testable import Chat

@MainActor
@Suite
struct ChatServiceTests {
    @Test
    func sendMessage_shouldReturnMessage() async {
        // Arrange
        let service = ChatService()

        // Act
        let message = await service.sendMessage("Hello")

        // Assert
        #expect(message.content == "Hello")
    }

    @Test
    func sendMessage_whenNetworkError_shouldThrow() async {
        // Arrange
        let service = ChatService()
        let networkError = NetworkError.noData

        // Act & Assert
        await #expect(throws: networkError) {
            try await service.sendMessage("")
        }
    }
}
```

### Запуск

```bash
# Все unit-тесты
xcodebuild test -scheme Chat -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:ChatTests

# Конкретный тест
xcodebuild test -scheme Chat -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:ChatTests/ChatServiceTests/sendMessage_shouldReturnMessage
```

---

## UI-тесты

### Архитектура

Page Object Model (POM) — разделение локаторов от логики тестов.

### Пример Page Object

```swift
import XCTest

final class ChatPage {
    private let app: XCUIApplication

    init(app: XCUIApplication) {
        self.app = app
    }

    var messageInput: XCUIElement {
        app.textFields["messageInput"]
    }

    var sendButton: XCUIElement {
        app.buttons["sendButton"]
    }

    var messagesList: XCUIElement {
        app.collectionViews["messagesList"]
    }

    func sendMessage(_ text: String) {
        messageInput.tap()
        messageInput.typeText(text)
        sendButton.tap()
    }
}
```

### Пример теста

```swift
import XCTest

@MainActor
final class SendMessageFlowTests: XCTestCase {
    var app: XCUIApplication!
    var chatPage: ChatPage!

    override func setUp() {
        super.setUp()
        app = XCUIApplication()
        chatPage = ChatPage(app: app)
    }

    func test_sendMessage_shouldAppearInChat() {
        // Act
        chatPage.sendMessage("Hello")

        // Assert
        XCTAssertTrue(chatPage.messagesList.staticTexts["Hello"].exists)
    }
}
```

### Запуск

```bash
# Все UI-тесты
xcodebuild test -scheme Chat -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:ChatUITests
```

---

## Snapshot-тесты

### Фреймворк

**SnapshotTesting** для визуальной регрессии.

### Пример

```swift
import SnapshotTesting
import SwiftUI

@Snapshot
struct MessageBubbleSnapshotTests {
    @Test
    func messageBubble_userMessage() {
        let view = MessageBubbleView(
            message: Message(content: "Hello", role: "user")
        )

        assertSnapshot(of: view, as: .swiftUI)
    }

    @Test
    func messageBubble_assistantMessage() {
        let view = MessageBubbleView(
            message: Message(content: "Hi!", role: "assistant")
        )

        assertSnapshot(of: view, as: .swiftUI)
    }
}
```

---

## Test Plans

| Plan | Файл | Назначение |
|------|------|------------|
| UnitTests | `TestPlans/UnitTests.xctestplan` | Только unit-тесты |
| UITests | `TestPlans/UITests.xctestplan` | Только UI-тесты |
| AllTests | `TestPlans/AllTests.xctestplan` | Все тесты с параллелизацией |

---

## Покрытие кода

### Цели

| Метрика | Цель |
|---------|------|
| Unit-тесты | 100% |
| UI-тесты | Критические сценарии |
| Snapshot | Все View компоненты |

### Проверка покрытия

```bash
# С покрытием
xcodebuild test -scheme Chat -destination 'platform=iOS Simulator,name=iPhone 16' -enableCodeCoverage YES -resultBundlePath ./Coverage

# Отчёт в Xcode
open Coverage/index.html
```

---

## Лучшие практики

### Названия тестов

```
<Method>_<Scenario>_<ExpectedResult>

sendMessage_withValidInput_shouldReturnMessage
sendMessage_withEmptyInput_shouldThrowError
```

### AAA паттерн

```swift
@Test
func example() {
    // Arrange — подготовка
    let service = ChatService()

    // Act — действие
    let result = service.doSomething()

    // Assert — проверка
    #expect(result == expected)
}
```

### Изоляция тестов

- [ ] Каждый тест независим
- [ ] Нет зависимости между тестами
- [ ] Используйте `@MainActor` для UI тестов
- [ ] Очищайте state в `setUp`/`tearDown`

### Что тестировать

| Компонент | Что тестировать |
|-----------|-----------------|
| ViewModels | Все публичные методы, state изменения |
| Services | Happy path, ошибки, edge cases |
| Models | Codable, валидация, вычисляемые свойства |
| Views | Snapshot-тесты |

### Что НЕ тестировать

- [ ] Private методы
- [ ] UI-details (точное позиционирование)
- [ ] Внешние зависимости (NetworkService → mock)
- [ ] Третьесторонние библиотеки

---

## Mocks

### Пример Mock

```swift
final class MockChatService: ChatServiceProtocol {
    var sendMessageResult: Message?
    var sendMessageError: Error?

    func sendMessage(_ text: String) async throws -> Message {
        if let error = sendMessageError {
            throw error
        }
        return sendMessageResult ?? Message(content: text, role: "user")
    }
}
```

### Использование в тестах

```swift
@Test
func test_viewModel_usesMockService() {
    let mockService = MockChatService()
    mockService.sendMessageResult = Message(content: "Mock", role: "assistant")

    let viewModel = ChatViewModel(chatService: mockService)
    // Тестирование...
}
```

---

## CI/CD

Тесты запускаются автоматически в `./scripts check`.

### Локальный запуск

```bash
# Полный check (включает тесты)
./scripts check

# Только тесты
xcodebuild test -scheme Chat -destination 'platform=iOS Simulator,name=iPhone 16'
```

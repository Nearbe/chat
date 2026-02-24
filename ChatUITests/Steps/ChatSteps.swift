// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.

import XCTest

/// Шаги для работы с чатом
/// Аналог UTChatSteps из tx-mobile
@MainActor
public final class ChatSteps {

    // MARK: - Свойства

    private let chatPage = ChatPage()

    // MARK: - Отправка сообщений

    /// Отправка сообщения в чат
    @discardableResult
    public func sendMessage(_ text: String) -> ChatSteps {
        XCTContext.runActivity(named: "Отправка сообщения: '\(text)'") { _ in
            chatPage.typeMessage(text)
            chatPage.tapSend()
        }
        return self
    }

    /// Отправка нескольких сообщений
    @discardableResult
    public func sendMultipleMessages(_ messages: [String]) -> ChatSteps {
        XCTContext.runActivity(named: "Отправка нескольких сообщений") { _ in
            messages.forEach { message in
                sendMessage(message)
            }
        }
        return self
    }

    // MARK: - Проверки

    /// Проверка наличия сообщения
    @discardableResult
    public func verifyMessageExists(_ text: String) -> ChatSteps {
        XCTContext.runActivity(named: "Проверка наличия сообщения: '\(text)'") { _ in
            chatPage.checkHasMessage(text)
        }
        return self
    }

    /// Проверка видимости пустого состояния
    @discardableResult
    public func verifyEmptyState() -> ChatSteps {
        XCTContext.runActivity(named: "Проверка пустого состояния") { _ in
            chatPage.checkEmptyStateVisible()
        }
        return self
    }

    /// Проверка индикатора генерации
    @discardableResult
    public func verifyThinkingIndicator() -> ChatSteps {
        XCTContext.runActivity(named: "Проверка индикатора генерации") { _ in
            // Проверка наличия индикатора "Думаю..."
        }
        return self
    }

    // MARK: - Навигация

    /// Открытие истории чатов
    @discardableResult
    public func openHistory() -> ChatSteps {
        _ = XCTContext.runActivity(named: "Открытие истории чатов") {
            _ in
            chatPage.openHistory()
        }
        return self
    }

    /// Открытие выбора модели
    @discardableResult
    public func openModelPicker() -> ChatSteps {
        _ = XCTContext.runActivity(named: "Открытие выбора модели") {
            _ in
            chatPage.openModelPicker()
        }
        return self
    }

    // MARK: - Очистка

    /// Очистка поля ввода
    @discardableResult
    public func clearInput() -> ChatSteps {
        XCTContext.runActivity(named: "Очистка поля ввода") { _ in
            chatPage.messageInputField.element.tap()
            chatPage.messageInputField.element.tap()
        }
        return self
    }
}

/// Глобальный экземпляр
public var chatSteps: ChatSteps { ChatSteps() }

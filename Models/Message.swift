import Foundation
import SwiftData

/// Модель сообщения в чате
/// Хранится в SwiftData для локального хранения истории
@Model
final class Message {
    /// Уникальный идентификатор сообщения
    var id: UUID

    /// Текст сообщения
    var content: String

    /// Роль отправителя: user или assistant
    var role: String

    /// Timestamp создания сообщения
    var createdAt: Date

    /// Индекс сообщения в рамках сессии
    var index: Int

    /// ID сессии чата
    var sessionId: UUID

    /// Статус генерации (для assistant сообщений)
    var isGenerating: Bool

    /// Имя модели, которая сгенерировала сообщение
    var modelName: String?

    /// Токены, использованные для генерации (опционально)
    var tokensUsed: Int?

    /// Связь с сессией чата
    @Relationship(inverse: \ChatSession.messages)
    var session: ChatSession?

    init(
        id: UUID = UUID(),
        content: String,
        role: String,
        createdAt: Date = Date(),
        index: Int = 0,
        sessionId: UUID,
        isGenerating: Bool = false,
        modelName: String? = nil,
        tokensUsed: Int? = nil
    ) {
        self.id = id
        self.content = content
        self.role = role
        self.createdAt = createdAt
        self.index = index
        self.sessionId = sessionId
        self.isGenerating = isGenerating
        self.modelName = modelName
        self.tokensUsed = tokensUsed
    }
}

/// Расширение для удобного создания сообщений
extension Message {
    /// Создать сообщение пользователя
    static func user(content: String, sessionId: UUID, index: Int) -> Message {
        Message(content: content, role: "user", index: index, sessionId: sessionId)
    }

    /// Создать сообщение ассистента
    static func assistant(content: String = "", sessionId: UUID, index: Int, modelName: String? = nil) -> Message {
        Message(
            content: content,
            role: "assistant",
            index: index,
            sessionId: sessionId,
            isGenerating: true,
            modelName: modelName
        )
    }

    /// Проверка, является ли сообщение от пользователя
    var isUser: Bool {
        role == "user"
    }

    /// Проверка, является ли сообщение от ассистента
    var isAssistant: Bool {
        role == "assistant"
    }
}

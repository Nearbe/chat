import Foundation
import SwiftData

/// Модель сессии чата
/// Содержит мета-информацию о чате и связанные сообщения
@Model
final class ChatSession {
    /// Уникальный идентификатор сессии
    var id: UUID

    /// Название чата (первое сообщение пользователя или "Новый чат")
    var title: String

    /// Timestamp создания сессии
    var createdAt: Date

    /// Timestamp последнего обновления
    var updatedAt: Date

    /// Имя модели, используемой в чате
    var modelName: String

    /// Список сообщений в чате
    @Relationship(deleteRule: .cascade)
    var messages: [Message]

    /// Сортировка сообщений по индексу
    var sortedMessages: [Message] {
        messages.sorted { $0.index < $1.index }
    }

    init(
        id: UUID = UUID(),
        title: String = "Новый чат",
        createdAt: Date = Date(),
        updatedAt: Date = Date(),
        modelName: String = "default",
        messages: [Message] = []
    ) {
        self.id = id
        self.title = title
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.modelName = modelName
        self.messages = messages
    }

    /// Обновить название чата на основе первого сообщения пользователя
    func updateTitleIfNeeded() {
        if title == "Новый чат" {
            if let firstUserMessage = messages.first(where: { $0.isUser }) {
                let preview = firstUserMessage.content.prefix(50)
                title = preview.isEmpty ? "Новый чат" : String(preview)
            }
        }
    }

    /// Добавить сообщение в сессию
    func addMessage(_ message: Message) {
        message.session = self
        messages.append(message)
        updatedAt = Date()
        updateTitleIfNeeded()
    }

    /// Получить следующий индекс для нового сообщения
    var nextMessageIndex: Int {
        messages.map(\.index).max() ?? -1 + 1
    }
}

/// Расширение для форматирования даты
extension ChatSession {
    /// Форматированная строка даты создания
    var formattedDate: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current

        if calendar.isDateInToday(createdAt) {
            formatter.dateFormat = "HH:mm"
        } else if calendar.isDateInYesterday(createdAt) {
            return "Вчера"
        } else {
            formatter.dateFormat = "dd MMM"
        }

        return formatter.string(from: createdAt)
    }

    /// Количество сообщений в чате
    var messageCount: Int {
        messages.count
    }

    /// Количество сообщений пользователя
    var userMessageCount: Int {
        messages.filter(\.isUser).count
    }
}

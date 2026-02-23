import Foundation
import SwiftData

// MARK: - Модель сессии чата (Chat Session Model)

/// Модель данных для сессии чата (истории).
/// Содержит мета-информацию о чате и связанные сообщения.
/// Хранится в SwiftData для персистентности.
///
/// Связи:
/// - ChatSession содержит массив Message через relationship
/// - При удалении сессии каскадно удаляются все сообщения
///
/// Архитектура:
/// - Использует @Model для SwiftData персистентности
/// - title автоматически обновляется по первому сообщению
/// - sortedMessages обеспечивает правильный порядок
///
/// - Важно: При удалении сессии удаляются все сообщения
/// - Примечание: Обновляет updatedAt при каждом новом сообщении
@Model
final class ChatSession {
    
    // MARK: - Идентификация (Identification)
    
    /// Уникальный идентификатор сессии
    /// UUID генерируется автоматически при создании
    /// Используется как primary key в SwiftData
    @Attribute(.unique)
    var id: UUID

    // MARK: - Метаданные (Metadata)
    
    /// Название чата
    /// По умолчанию: "Новый чат"
    /// Обновляется автоматически по первому сообщению пользователя
    /// Первые 50 символов первого сообщения
    var title: String

    /// Timestamp создания сессии
    /// Устанавливается один раз при создании
    /// Используется для сортировки истории
    var createdAt: Date

    /// Timestamp последнего обновления
    /// Обновляется при каждом новом сообщении
    /// Используется для сортировки "недавних" чатов
    var updatedAt: Date

    /// Имя модели, используемой в чате
    /// Сохраняется при создании сессии
    /// Используется для восстановления при загрузке
    var modelName: String

    // MARK: - Связи (Relationships)
    
    /// Массив сообщений в чате
    /// Relationship с каскадным удалением
    /// При удалении сессии удаляются все сообщения
    @Relationship(deleteRule: .cascade)
    var messages: [Message]

    // MARK: - Вычисляемые свойства (Computed Properties)
    
    /// Сообщения, отсортированные по индексу
    /// Гарантирует правильный порядок в UI
    /// - Returns: Отсортированный массив сообщений
    var sortedMessages: [Message] {
        messages.sorted { $0.index < $1.index }
    }

    // MARK: - Инициализация (Initialization)
    
    /// Основной конструктор
    /// - Parameters:
    ///   - id: UUID (по умолчанию новый)
    ///   - title: Название чата (по умолчанию "Новый чат")
    ///   - createdAt: Время создания (по умолчанию сейчас)
    ///   - updatedAt: Время обновления (по умолчанию сейчас)
    ///   - modelName: Имя модели (по умолчанию "default")
    ///   - messages: Начальный массив сообщений (по умолчанию пустой)
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

    // MARK: - Публичные методы (Public Methods)
    
    /// Обновить название чата если это "Новый чат"
    /// Вызывается автоматически при добавлении первого сообщения
    /// Берёт первые 50 символов первого сообщения пользователя
    func updateTitleIfNeeded() {
        if title == "Новый чат" {
            if let firstUserMessage = messages.first(where: { $0.isUser }) {
                let preview = firstUserMessage.content.prefix(50)
                // Если сообщение пустое - оставляем "Новый чат"
                title = preview.isEmpty ? "Новый чат" : String(preview)
            }
        }
    }

    /// Добавить сообщение в сессию
    /// - Parameter message: Сообщение для добавления
    /// Автоматически:
    /// - Устанавливает связь с сессией
    /// - Обновляет updatedAt
    /// - Обновляет название если нужно
    func addMessage(_ message: Message) {
        message.session = self  // Устанавливаем связь
        messages.append(message)
        updatedAt = Date()      // Обновляем timestamp
        updateTitleIfNeeded()   // Проверяем название
    }

    /// Получить следующий индекс для нового сообщения
    /// - Returns: Индекс для следующего сообщения
    /// Используется при создании нового сообщения
    var nextMessageIndex: Int {
        // Берем максимальный индекс или -1 если нет сообщений
        messages.map(\.index).max() ?? -1 + 1
    }
}

// MARK: - Форматирование даты (Date Formatting)

/// Расширение для форматирования даты в UI
extension ChatSession {
    
    /// Форматированная строка даты создания
    /// Показывает:
    /// - Время (HH:mm) для сегодняшних чатов
    /// - "Вчера" для вчерашних
    /// - Дату (dd MMM) для остальных
    var formattedDate: String {
        let formatter = DateFormatter()
        let calendar = Calendar.current

        if calendar.isDateInToday(createdAt) {
            // Сегодня - показываем только время
            formatter.dateFormat = "HH:mm"
        } else if calendar.isDateInYesterday(createdAt) {
            // Вчера - показываем слово "Вчера"
            return "Вчера"
        } else {
            // Ранее - показываем дату
            formatter.dateFormat = "dd MMM"
        }

        return formatter.string(from: createdAt)
    }

    /// Количество сообщений в чате
    /// - Returns: Общее число сообщений (включая AI и пользователя)
    var messageCount: Int {
        messages.count
    }

    /// Количество сообщений пользователя
    /// - Returns: Число сообщений с ролью "user"
    var userMessageCount: Int {
        messages.filter(\.isUser).count
    }
}

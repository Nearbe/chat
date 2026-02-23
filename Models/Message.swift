// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation
import SwiftData

// MARK: - Модель сообщения чата (Message Model)

/// Модель данных для отдельного сообщения в чате.
/// Хранится в SwiftData для персистентности истории.
///
/// Связи:
/// - Message принадлежит ChatSession через relationship
/// - Сессия содержит массив сообщений, отсортированных по индексу
///
/// Архитектура:
/// - Использует @Model для автоматического создания таблицы в SwiftData
/// - UUID обеспечивает уникальность каждого сообщения
/// - Индекс используется для сортировки в рамках сессии
///
/// - Важно: При редактировании сообщения удаляются все последующие
/// - Примечание: isGenerating блокирует повторную отправку во время генерации
@Model
final class Message {
    
    // MARK: - Идентификация (Identification)
    
    /// Уникальный идентификатор сообщения
    /// Генерируется автоматически при создании
    /// Используется для ForEach в SwiftUI
    @Attribute(.unique)
    var id: UUID

    // MARK: - Содержимое (Content)
    
    /// Текстовое содержимое сообщения
    /// Может быть пустым во время стриминга (постепенно заполняется)
    var content: String

    /// Роль отправителя сообщения
    /// Возможные значения:
    /// - "user" - сообщение от пользователя
    /// - "assistant" - ответ от AI
    /// - "tool" - результат выполнения инструмента
    var role: String

    // MARK: - Метаданные (Metadata)
    
    /// Timestamp создания сообщения
    /// Устанавливается при создании, используется для сортировки
    var createdAt: Date

    /// Порядковый номер сообщения в рамках сессии
    /// Начинается с 0, инкрементируется для каждого нового сообщения
    /// Используется для восстановления порядка сообщений
    var index: Int

    /// ID сессии чата, которой принадлежит сообщение
    /// Позволяет восстановить связь без загрузки всей сессии
    var sessionId: UUID

    /// Флаг генерации ответа
    /// true - идёт стриминг ответа от AI
    /// false - генерация завершена или это сообщение пользователя
    /// Используется для показа индикатора "печатания"
    var isGenerating: Bool

    /// Имя модели, сгенерировавшей сообщение
    /// nil для сообщений пользователя
    /// Используется для отображения в UI и аналитики
    var modelName: String?

    /// Количество использованных токенов
    /// Заполняется после завершения генерации
    /// nil для сообщений пользователя
    var tokensUsed: Int?

    /// Цепочка мыслей (reasoning) для Claude-like моделей
    /// Содержит внутренние рассуждения модели перед ответом
    /// Отображается в UI как "думает..."
    var reasoning: String?

    // MARK: - Связи (Relationships)
    
    /// Ссылка на родительскую сессию чата
    /// Устанавливается автоматически при добавлении в сессию
    /// Используется SwiftData для каскадного удаления
    @Relationship(inverse: \ChatSession.messages)
    var session: ChatSession?

    // MARK: - Инициализация (Initialization)
    
    /// Основной конструктор сообщения
    /// - Parameters:
    ///   - id: Уникальный ID (по умолчанию новый UUID)
    ///   - content: Текст сообщения
    ///   - role: Роль (user/assistant/tool)
    ///   - createdAt: Время создания (по умолчанию сейчас)
    ///   - index: Индекс в сессии
    ///   - sessionId: ID сессии
    ///   - isGenerating: Флаг генерации (для assistant)
    ///   - modelName: Имя модели (для assistant)
    ///   - tokensUsed: Использованные токены (для assistant)
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

// MARK: - Удобные фабричные методы (Factory Methods)

/// Расширение для удобного создания сообщений разных типов
extension Message {
    
    /// Создать сообщение пользователя
    /// - Parameters:
    ///   - content: Текст сообщения
    ///   - sessionId: ID сессии
    ///   - index: Индекс в сессии
    /// - Returns: Новое сообщение с ролью "user"
    static func user(content: String, sessionId: UUID, index: Int) -> Message {
        Message(content: content, role: "user", index: index, sessionId: sessionId)
    }

    /// Создать сообщение ассистента
    /// Автоматически устанавливает isGenerating = true
    /// - Parameters:
    ///   - content: Начальный контент (обычно пустой)
    ///   - sessionId: ID сессии
    ///   - index: Индекс в сессии
    ///   - modelName: Имя модели (опционально)
    /// - Returns: Новое сообщение с ролью "assistant"
    static func assistant(
        content: String = "",
        sessionId: UUID,
        index: Int,
        modelName: String? = nil
    ) -> Message {
        Message(
            content: content,
            role: "assistant",
            index: index,
            sessionId: sessionId,
            isGenerating: true,  // Начинаем с флага генерации
            modelName: modelName
        )
    }

    /// Проверка, является ли сообщение от пользователя
    /// - Returns: true если role == "user"
    var isUser: Bool {
        role == "user"
    }

    /// Проверка, является ли сообщение от AI ассистента
    /// - Returns: true если role == "assistant"
    var isAssistant: Bool {
        role == "assistant"
    }
}

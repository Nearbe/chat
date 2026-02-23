// MARK: - Связь с документацией: LM Studio (Версия: main). Статус: Синхронизировано.
import Foundation
import SwiftData

/// Менеджер сессий чата для работы со SwiftData
@MainActor
final class ChatSessionManager: ObservableObject {
    private let modelContext: ModelContext

    init(modelContext: ModelContext) {
        self.modelContext = modelContext
    }

    /// Создать новую сессию
    func createSession(modelName: String, title: String? = nil) -> ChatSession {
        let session = ChatSession(title: title ?? "Новый чат", modelName: modelName)
        modelContext.insert(session)
        save()
        return session
    }

    /// Добавить сообщение в сессию
    func addMessage(_ message: Message, to session: ChatSession) {
        session.addMessage(message)
        save()
    }

    /// Удалить сессию
    func deleteSession(_ session: ChatSession) {
        modelContext.delete(session)
        save()
    }

    /// Удалить сообщение
    func deleteMessage(_ message: Message) {
        modelContext.delete(message)
        save()
    }

    /// Удалить сообщения после определенного индекса (для редактирования)
    func deleteMessages(after index: Int, in session: ChatSession) {
        let messagesToDelete = session.messages.filter { $0.index > index }
        for msg in messagesToDelete {
            modelContext.delete(msg)
        }
        save()
    }

    /// Сохранить изменения в контексте
    func save() {
        do {
            try modelContext.save()
        } catch {
            // Ошибка сохранения SwiftData
            // В реальном приложении здесь должен быть вызов логгера (например, OSLog или Pulse)
        }
    }
}

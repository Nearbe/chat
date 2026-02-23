// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import SwiftData
import Foundation

/// Контроллер для работы с базой данных (SwiftData)
/// Отвечает за инициализацию хранилища и управление контекстом данных.
@MainActor
final class PersistenceController {
    /// Основной контейнер моделей данных
    let container: ModelContainer

    /// Основной контекст для работы в UI-потоке
    var mainContext: ModelContext {
        container.mainContext
    }

    /// Общий экземпляр контроллера (Singleton)
    @MainActor static let shared = PersistenceController()

    /// Инициализация хранилища
    /// - Parameter inMemory: Если true, данные будут храниться только в оперативной памяти (для тестов)
    private init(inMemory: Bool = false) {
        let schema = Schema([ChatSession.self, Message.self])
        let config: ModelConfiguration
        if inMemory {
            config = ModelConfiguration(schema: schema, isStoredInMemoryOnly: true)
        } else {
            config = ModelConfiguration(schema: schema)
        }

        do {
            container = try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Не удалось создать ModelContainer: \(error)")
        }
    }

    /// Принудительное сохранение текущего контекста
    func save() {
        try? container.mainContext.save()
    }

    /// Полная очистка всех данных приложения
    /// Удаляет все сессии и связанные с ними сообщения
    func deleteAll() {
        try? container.mainContext.delete(model: ChatSession.self)
        try? container.mainContext.delete(model: Message.self)
        save()
    }
}

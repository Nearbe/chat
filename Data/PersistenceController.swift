import SwiftData
import Foundation

/// КонтроллерPersistence для SwiftData
@MainActor
final class PersistenceController {
    let container: ModelContainer

    var mainContext: ModelContext {
        container.mainContext
    }

    static let shared = PersistenceController()

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

    /// Сохранить контекст
    func save() {
        try? container.mainContext.save()
    }

    /// Удалить все данные
    func deleteAll() {
        try? container.mainContext.delete(model: ChatSession.self)
        try? container.mainContext.delete(model: Message.self)
        save()
    }
}

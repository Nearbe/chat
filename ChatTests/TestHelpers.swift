import Foundation
import SwiftData
@testable import Chat

/// Помощник для создания in-memory контейнера SwiftData для тестов
enum TestHelpers {
    @MainActor
    static func createInMemoryContainer() -> ModelContainer {
        let schema = Schema([
            ChatSession.self,
            Message.self
        ])
        let configuration = ModelConfiguration(isStoredInMemoryOnly: true)
        
        do {
            return try ModelContainer(for: schema, configurations: [configuration])
        } catch {
            fatalError("Could not create in-memory ModelContainer: \(error.localizedDescription)")
        }
    }
}

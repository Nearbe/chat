import Foundation

/// Протокол для работы с памятью проекта
/// Позволяет инвертировать зависимость и легко тестировать
protocol MemoryServiceProtocol {
    
    /// Сохранить воспоминание в память
    func store(
        content: String,
        tags: [String],
        metadata: [String: Any]?
    ) async throws -> MemoryID
    
    /// Поиск воспоминаний по запросу
    func search(
        query: String,
        tags: [String]?,
        limit: Int
    ) async throws -> [MemoryItem]
    
    /// Получить статистику сервера
    func getStats() async throws -> ServerStats
}

// MARK: - Factory Extension

extension MemoryServiceClient: MemoryServiceProtocol { }

import Foundation
import Combine

/// Клиент для работы с MCP Memory Service через HTTP API
/// Интеграция: http://localhost:8000/api/docs
final class MemoryServiceClient {
    
    // MARK: - Properties
    
    private let baseURL = URL(string: "http://localhost:8000")!
    private let session: URLSession
    weak var delegate: MemoryServiceDelegate?
    
    /// Инициализация клиента
    /// - Parameter baseURL: Базовый URL сервера (по умолчанию localhost:8000)
    init(baseURL: URL = URL(string: "http://localhost:8000")!, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
    }
    
    // MARK: - Public Methods
    
    /// Сохранить воспоминание в память
    /// - Parameters:
    ///   - content: Текст воспоминания
    ///   - tags: Массив тегов для категоризации
    ///   - metadata: Дополнительные метаданные
    /// - Returns: ID сохранённого воспоминания
    func store(
        content: String,
        tags: [String] = [],
        metadata: [String: Any]? = nil
    ) async throws -> MemoryID {
        
        let endpoint = baseURL.appendingPathComponent("api/memories")
        
        var payload: [String: Any] = [
            "content": content,
            "tags": tags
        ]
        
        if let metadata = metadata {
            payload["metadata"] = metadata
        }
        
        let (data, response) = try await sendRequest(
            method: "POST",
            endpoint: endpoint,
            body: payload
        )
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw MemoryServiceError.invalidResponse
        }
        
        if !httpResponse.okStatus {
            throw MemoryServiceError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let result = try JSONDecoder().decode(MemoryStoreResult.self, from: data)
        return result.id
    }
    
    /// Поиск воспоминаний по запросу
    /// - Parameters:
    ///   - query: Текст запроса для семантического поиска
    ///   - tags: Фильтр по тегам (опционально)
    ///   - limit: Максимальное количество результатов (по умолчанию 10)
    /// - Returns: Массив найденных воспоминаний
    func search(
        query: String,
        tags: [String]? = nil,
        limit: Int = 10
    ) async throws -> [MemoryItem] {
        
        let endpoint = baseURL.appendingPathComponent("api/memories/search")
        
        var payload: [String: Any] = [
            "query": query,
            "limit": limit
        ]
        
        if let tags = tags {
            payload["tags"] = tags
        }
        
        let (data, response) = try await sendRequest(
            method: "POST",
            endpoint: endpoint,
            body: payload
        )
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw MemoryServiceError.invalidResponse
        }
        
        if !httpResponse.okStatus {
            throw MemoryServiceError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let result = try JSONDecoder().decode(SearchResult.self, from: data)
        return result.memories
    }
    
    /// Получить статистику сервера
    func getStats() async throws -> ServerStats {
        
        let endpoint = baseURL.appendingPathComponent("api/stats")
        
        let (data, response) = try await sendRequest(
            method: "GET",
            endpoint: endpoint
        )
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw MemoryServiceError.invalidResponse
        }
        
        if !httpResponse.okStatus {
            throw MemoryServiceError.httpError(statusCode: httpResponse.statusCode)
        }
        
        return try JSONDecoder().decode(ServerStats.self, from: data)
    }
    
    // MARK: - Private Methods
    
    private func sendRequest(
        method: String,
        endpoint: URL,
        body: [String: Any]? = nil
    ) async throws -> (Data, URLResponse) {
        
        var request = URLRequest(url: endpoint)
        request.httpMethod = method
        
        if let body = body {
            request.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            guard let jsonData = try? JSONSerialization.data(withJSONObject: body) else {
                throw MemoryServiceError.serializationError
            }
            request.httpBody = jsonData
        }
        
        let (data, response) = try await session.data(for: request)
        return (data, response)
    }
}

// MARK: - Helper Extensions

private extension HTTPURLResponse {
    var okStatus: Bool {
        statusCode >= 200 && statusCode < 300
    }
}

// MARK: - Protocols and Delegates

protocol MemoryServiceDelegate: AnyObject {
    func memoryClient(_ client: MemoryServiceClient, didSave memoryID: MemoryID)
    func memoryClient(_ client: MemoryServiceClient, didSearch results: [MemoryItem])
    func memoryClient(_ client: MemoryServiceClient, didFail error: Error)
}

// MARK: - Models

struct MemoryStoreResult: Decodable {
    let id: MemoryID
    let message: String
}

struct SearchResult: Decodable {
    let memories: [MemoryItem]
    let count: Int
}

struct ServerStats: Decodable {
    let totalMemories: Int
    let memoryCountLastWeek: Int?
    let topTags: [(tag: String, count: Int)]?
    
    enum CodingKeys: String, CodingKey {
        case totalMemories = "total_memories"
        case memoryCountLastWeek = "memory_count_last_week"
        case topTags
    }
}

// MARK: - Error Types

enum MemoryServiceError: LocalizedError {
    case invalidResponse
    case httpError(statusCode: Int)
    case serializationError
    case networkError(Error)
    
    var errorDescription: String? {
        switch self {
        case .invalidResponse: return "Некорректный ответ сервера"
        case let .httpError(code): return "HTTP ошибка \(code)"
        case .serializationError: return "Ошибка сериализации данных"
        case let .networkError(error): return error.localizedDescription
        }
    }
}

// MARK: - Type Aliases

typealias MemoryID = String

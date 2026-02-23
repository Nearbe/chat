import Foundation

/// Объект вызова инструмента (tool call) в ответе LM Studio.
struct LMToolCall: Codable {
    /// Тип вывода (всегда "tool_call")
    let type: String
    
    /// Идентификатор или имя вызываемого инструмента
    let tool: String
    
    /// Аргументы вызова в виде словаря с универсальными значениями AnyCodable
    let arguments: [String: AnyCodable]?
    
    /// Текстовый вывод/результат выполнения инструмента (если доступен)
    let output: String?
    
    /// Информация о провайдере инструмента (например, MCP сервер)
    let providerInfo: LMProviderInfo?

    enum CodingKeys: String, CodingKey {
        case type, tool, arguments, output
        case providerInfo = "provider_info"
    }
}

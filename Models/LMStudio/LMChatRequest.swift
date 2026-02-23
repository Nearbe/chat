// MARK: - Связь с документацией: LM Studio (Версия: main). Статус: Синхронизировано.
import Foundation

/// Объект запроса к чат-интерфейсу LM Studio v1 API.
/// Содержит все параметры для формирования запроса к языковой модели.
struct LMChatRequest: Codable {
    /// Идентификатор модели для использования (например, "qwen2.5-7b-instruct")
    let model: String
    
    /// Список сообщений для истории чата
    let input: LMInput
    
    /// Системная инструкция, определяющая поведение модели
    let systemPrompt: String?
    
    /// Флаг использования потоковой передачи ответа (Server-Sent Events)
    let stream: Bool
    
    /// Параметр "креативности" модели (от 0.0 до 2.0)
    let temperature: Double?
    
    /// Параметр Top-P фильтрации (nucleus sampling)
    let topP: Double?
    
    /// Параметр Top-K фильтрации (ограничение выборки k-токенами)
    let topK: Int?
    
    /// Параметр Min-P фильтрации (минимальная вероятность токена относительно самого вероятного)
    let minP: Double?
    
    /// Штраф за повторение токенов
    let repeatPenalty: Double?
    
    /// Максимальное количество генерируемых токенов
    let maxOutputTokens: Int?
    
    /// Настройки логики рассуждения (для моделей с поддержкой reasoning)
    let reasoning: String?
    
    /// Ограничение контекстного окна для текущего запроса
    let contextLength: Int?
    
    /// Флаг сохранения запроса на стороне сервера
    let store: Bool?
    
    /// ID предыдущего ответа для связывания контекста
    let previousResponseId: String?
    
    /// Список активных интеграций (например, MCP инструменты)
    let integrations: [LMIntegration]?

    enum CodingKeys: String, CodingKey {
        case model
        case input
        case systemPrompt = "system_prompt"
        case stream
        case temperature
        case topP = "top_p"
        case topK = "top_k"
        case minP = "min_p"
        case repeatPenalty = "repeat_penalty"
        case maxOutputTokens = "max_output_tokens"
        case reasoning
        case contextLength = "context_length"
        case store
        case previousResponseId = "previous_response_id"
        case integrations
    }

    /// Инициализация запроса чата
    /// - Parameters:
    ///   - model: ID модели
    ///   - messages: Массив сообщений чата
    ///   - systemPrompt: Системная инструкция (опционально)
    ///   - stream: Использовать стриминг (по умолчанию true)
    ///   - temperature: Температура генерации (опционально)
    ///   - maxTokens: Максимальное количество токенов (опционально)
    ///   - reasoning: Настройки рассуждения (опционально)
    ///   - contextLength: Лимит контекста (опционально)
    ///   - store: Сохранять ли запрос (по умолчанию true)
    ///   - previousResponseId: ID предыдущего ответа (опционально)
    ///   - integrations: Список интеграций (опционально)
    init(
        model: String,
        messages: [ChatMessage],
        systemPrompt: String? = nil,
        stream: Bool = true,
        temperature: Double? = nil,
        maxTokens: Int? = nil,
        reasoning: String? = nil,
        contextLength: Int? = nil,
        store: Bool = true,
        previousResponseId: String? = nil,
        integrations: [LMIntegration]? = nil
    ) {
        self.model = model
        self.input = LMInput(messages: messages)
        self.systemPrompt = systemPrompt
        self.stream = stream
        self.temperature = temperature
        self.topP = nil
        self.topK = nil
        self.minP = nil
        self.repeatPenalty = nil
        self.maxOutputTokens = maxTokens
        self.reasoning = reasoning
        self.contextLength = contextLength
        self.store = store
        self.previousResponseId = previousResponseId
        self.integrations = integrations
    }
}

/// Информация об интеграции с внешними инструментами или серверами (например, MCP).
struct LMIntegration: Codable {
    /// Тип интеграции (например, "mcp")
    let type: String
    
    /// Уникальный идентификатор интеграции
    let id: String?
    
    /// Отображаемое имя сервера интеграции
    let serverLabel: String?
    
    /// URL адрес сервера интеграции
    let serverUrl: String?
    
    /// Список разрешённых для использования функций/инструментов
    let allowedTools: [String]?
    
    /// Дополнительные HTTP-заголовки для запросов к интеграции
    let headers: [String: String]?

    enum CodingKeys: String, CodingKey {
        case type, id
        case serverLabel = "server_label"
        case serverUrl = "server_url"
        case allowedTools = "allowed_tools"
        case headers
    }
}

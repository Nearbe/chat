import Foundation

/// Вызов инструмента (tool_call) от модели
struct ToolCall: Identifiable, Hashable {
    let id: UUID
    let index: Int
    let name: String
    var arguments: String
    var result: String?
    var isExecuting: Bool
    var error: String?

    init(
        id: UUID = UUID(),
        index: Int,
        name: String,
        arguments: String = "",
        result: String? = nil,
        isExecuting: Bool = true,
        error: String? = nil
    ) {
        self.id = id
        self.index = index
        self.name = name
        self.arguments = arguments
        self.result = result
        self.isExecuting = isExecuting
        self.error = error
    }

    /// Парсинг аргументов из JSON
    var parsedArguments: [String: Any]? {
        guard let data = arguments.data(using: .utf8) else { return nil }
        return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    }

    /// Успешно ли выполнен инструмент
    var isSuccessful: Bool {
        result != nil && error == nil
    }
}

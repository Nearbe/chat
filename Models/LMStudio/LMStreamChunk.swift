// MARK: - Связь с документацией: LM Studio (Версия: main). Статус: Синхронизировано.
import Foundation

/// Объект частичного ответа (чанка) при потоковой передаче (SSE) от LM Studio.
/// Позволяет обрабатывать входящие данные по мере их генерации.
struct LMStreamChunk: Codable {
    /// Тип чанка (например, "message", "reasoning", "tool_call", "done")
    let type: String
    
    /// Текстовое содержимое (для сообщений и рассуждений)
    let content: String?
    
    /// Имя вызываемого инструмента (если это чанк вызова инструмента)
    let tool: String?
    
    /// Аргументы вызова инструмента (если есть)
    let arguments: [String: AnyCodable]?
    
    /// Вывод инструмента (если это результат выполнения)
    let output: String?
    
    /// Промежуточная или финальная статистика генерации
    let stats: LMStats?

    enum CodingKeys: String, CodingKey {
        case type, content, tool, arguments, output, stats
    }

    /// Проверка, является ли чанк частью обычного сообщения
    var isMessage: Bool { type == "message" }
    
    /// Проверка, является ли чанк частью рассуждений модели
    var isReasoning: Bool { type == "reasoning" }
    
    /// Проверка, является ли чанк частью вызова инструмента
    var isToolCall: Bool { type == "tool_call" }
    
    /// Проверка, является ли чанк сигналом завершения стрима
    var isDone: Bool { type == "done" }
}

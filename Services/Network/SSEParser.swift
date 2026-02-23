import Foundation

/// - Спецификация API: [Docs/LMStudio/developer/rest/streaming-events.md](../../Docs/LMStudio/developer/rest/streaming-events.md)
/// Парсер событий Server-Sent Events (SSE) для обработки потоковой передачи от LM Studio.
/// Накапливает байты, выделяет строки и декодирует их в структурированные события.
struct SSEParser {
    /// Внутренний буфер для накопления текущей строки данных
    private var buffer = ""
    
    /// Тип текущего события (поле "event:" в SSE)
    private var currentEventType = ""
    
    /// Накопленный контент сообщения
    private var messageContent = ""
    
    /// Накопленный контент рассуждений
    private var reasoningContent = ""

    /// Типы событий, которые может вернуть парсер после обработки данных
    enum ParsedEvent {
        case chatStart             /// Начало сессии чата
        case messageStart          /// Начало нового сообщения
        case messageDelta(String)  /// Часть (дельта) текста сообщения
        case messageEnd            /// Конец сообщения
        case reasoningStart        /// Начало блока рассуждений
        case reasoningDelta(String) /// Часть (дельта) текста рассуждений
        case reasoningEnd          /// Конец блока рассуждений
        case toolCallStart(tool: String?, providerInfo: LMProviderInfo?) /// Начало вызова инструмента
        case toolCallArguments([String: AnyCodable]?) /// Порция аргументов для инструмента
        case toolCallSuccess       /// Успешное завершение вызова инструмента
        case toolCallFailure       /// Ошибка при вызове инструмента
        case chatEnd               /// Завершение сессии чата
        case error(String)         /// Ошибка, переданная сервером
    }

    /// Обработать входящий байт данных.
    /// Если накоплена полная строка (заканчивается на \n), пытается распарсить её.
    /// - Parameter byte: Байт из сетевого потока
    /// - Returns: Объект ParsedEvent, если удалось распознать событие, иначе nil
    mutating func parse(byte: UInt8) -> ParsedEvent? {
        let char = Character(UnicodeScalar(byte))
        buffer.append(char)

        // SSE строки разделяются символом переноса строки
        guard char == "\n" else { return nil }

        let line = buffer.trimmingCharacters(in: .whitespacesAndNewlines)
        buffer = ""

        guard !line.isEmpty else { return nil }

        // Парсим тип события (event: ...)
        if line.hasPrefix("event: ") {
            currentEventType = String(line.dropFirst(7))
            return nil
        }

        // Парсим данные события (data: ...)
        guard line.hasPrefix("data: ") else { return nil }

        let jsonString = String(line.dropFirst(6))
        guard let data = jsonString.data(using: .utf8) else { return nil }

        do {
            let decoder = JSONDecoder()
            let event = try decoder.decode(LMSEvent.self, from: data)
            return mapEvent(event)
        } catch {
            // Ошибка декодирования SSE события
            return nil
        }
    }

    // swiftlint:disable cyclomatic_complexity
    /// Преобразование сырого события API в типизированное внутреннее событие ParsedEvent.
    private mutating func mapEvent(_ event: LMSEvent) -> ParsedEvent? {
        switch event.type {
        case "chat.start":
            messageContent = ""
            reasoningContent = ""
            return .chatStart

        case "message.start":
            messageContent = ""
            return .messageStart

        case "message.delta":
            if let content = event.content {
                messageContent += content
                return .messageDelta(content)
            }
            return nil

        case "message.end":
            return .messageEnd

        case "reasoning.start":
            reasoningContent = ""
            return .reasoningStart

        case "reasoning.delta":
            if let content = event.content {
                reasoningContent += content
                return .reasoningDelta(content)
            }
            return nil

        case "reasoning.end":
            return .reasoningEnd

        case "tool_call.start":
            return .toolCallStart(tool: event.tool, providerInfo: event.providerInfo)

        case "tool_call.arguments":
            return .toolCallArguments(event.arguments)

        case "tool_call.success":
            return .toolCallSuccess

        case "tool_call.failure":
            return .toolCallFailure

        case "chat.end":
            return .chatEnd

        case "error":
            if let errorMsg = event.error?.message {
                return .error(errorMsg)
            }
            return nil

        default:
            return nil
        }
    }
    // swiftlint:enable cyclomatic_complexity

    /// Полный сброс состояния парсера (используется перед началом нового стрима).
    mutating func reset() {
        buffer = ""
        currentEventType = ""
        messageContent = ""
        reasoningContent = ""
    }
}

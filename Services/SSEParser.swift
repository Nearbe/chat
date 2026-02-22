import Foundation

/// Парсер SSE событий для стриминга
struct SSEParser {
    private var buffer = ""
    private var currentEventType = ""
    private var messageContent = ""
    private var reasoningContent = ""

    enum ParsedEvent {
        case chatStart
        case messageStart
        case messageDelta(String)
        case messageEnd
        case reasoningStart
        case reasoningDelta(String)
        case reasoningEnd
        case toolCallStart(tool: String?, providerInfo: LMProviderInfo?)
        case toolCallArguments([String: AnyCodable]?)
        case toolCallSuccess
        case toolCallFailure
        case chatEnd
        case error(String)
    }

    /// Обработать байты из стрима и вернуть событие если строка завершена
    mutating func parse(byte: UInt8) -> ParsedEvent? {
        let char = Character(UnicodeScalar(byte))
        buffer.append(char)

        guard char == "\n" else { return nil }

        let line = buffer.trimmingCharacters(in: .whitespacesAndNewlines)
        buffer = ""

        guard !line.isEmpty else { return nil }

        // Парсим event type
        if line.hasPrefix("event: ") {
            currentEventType = String(line.dropFirst(7))
            return nil
        }

        // Парсим data
        guard line.hasPrefix("data: ") else { return nil }

        let jsonString = String(line.dropFirst(6))
        guard let data = jsonString.data(using: .utf8) else { return nil }

        do {
            let decoder = JSONDecoder()
            let event = try decoder.decode(LMSEvent.self, from: data)
            return mapEvent(type: event.type, content: event.content, tool: event.tool, arguments: event.arguments, providerInfo: event.providerInfo, error: event.error)
        } catch {
            print("[SSEParser] Decode error: \(error.localizedDescription)")
            return nil
        }
    }

    private mutating func mapEvent(type: String, content: String?, tool: String?, arguments: [String: AnyCodable]?, providerInfo: LMProviderInfo?, error: LMError?) -> ParsedEvent? {
        switch type {
        case "chat.start":
            messageContent = ""
            reasoningContent = ""
            return .chatStart

        case "message.start":
            messageContent = ""
            return .messageStart

        case "message.delta":
            if let content = content {
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
            if let content = content {
                reasoningContent += content
                return .reasoningDelta(content)
            }
            return nil

        case "reasoning.end":
            return .reasoningEnd

        case "tool_call.start":
            return .toolCallStart(tool: tool, providerInfo: providerInfo)

        case "tool_call.arguments":
            return .toolCallArguments(arguments)

        case "tool_call.success":
            return .toolCallSuccess

        case "tool_call.failure":
            return .toolCallFailure

        case "chat.end":
            return .chatEnd

        case "error":
            if let errorMsg = error?.message {
                return .error(errorMsg)
            }
            return nil

        default:
            return nil
        }
    }

    /// Сбросить состояние парсера
    mutating func reset() {
        buffer = ""
        currentEventType = ""
        messageContent = ""
        reasoningContent = ""
    }
}

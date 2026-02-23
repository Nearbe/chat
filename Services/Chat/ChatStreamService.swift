import Foundation

/// - Спецификация API: [Docs/LMStudio/developer/rest/streaming-events.md](../../Docs/LMStudio/developer/rest/streaming-events.md)
/// Сервис для стриминга чата
final class ChatStreamService: @unchecked Sendable {
    private let httpClient: HTTPClient

    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }

    /// Streaming chat completion
    nonisolated func streamChat(
        url: URL,
        messages: [ChatMessage],
        model: String,
        temperature: Double?,
        maxTokens: Int?
    ) -> AsyncThrowingStream<ChatCompletionStreamPart, Error> {
        AsyncThrowingStream { continuation in
            let httpClient = self.httpClient

            Task {
                do {
                    try Task.checkCancellation()

                    let lmRequest = LMChatRequest(
                        model: model,
                        messages: messages,
                        systemPrompt: nil,
                        stream: true,
                        temperature: temperature,
                        maxTokens: maxTokens
                    )

                    let (bytes, _) = try await httpClient.postStreaming(url: url, body: lmRequest)

                    var parser = SSEParser()

                    for try await byte in bytes {
                        try Task.checkCancellation()

                        if let event = parser.parse(byte: byte) {
                            if let part = Self.convertToStreamPart(event: event) {
                                continuation.yield(part)
                            }

                            if case .chatEnd = event {
                                continuation.finish()
                                return
                            }
                        }
                    }

                    continuation.finish()
                } catch is CancellationError {
                    continuation.finish(throwing: CancellationError())
                } catch {
                    continuation.finish(throwing: error)
                }
            }

            continuation.onTermination = { @Sendable _ in
                // Task cancellation handled by Swift concurrency
            }
        }
    }

    nonisolated private static func convertToStreamPart(event: SSEParser.ParsedEvent) -> ChatCompletionStreamPart? {
        switch event {
        case .messageDelta(let content):
            return createPart(content: content, reasoning: nil)

        case .reasoningDelta(let content):
            return createPart(content: nil, reasoning: content)

        case .chatEnd:
            return ChatCompletionStreamPart(
                choices: [
                    StreamChoice(
                        index: 0,
                        delta: ChatCompletionDelta(role: .assistant, content: nil, toolCalls: nil),
                        finishReason: "stop"
                    )
                ]
            )

        default:
            return nil
        }
    }

    nonisolated private static func createPart(content: String?, reasoning: String?) -> ChatCompletionStreamPart {
        ChatCompletionStreamPart(
            choices: [
                StreamChoice(
                    index: 0,
                    delta: ChatCompletionDelta(
                        role: .assistant,
                        content: content,
                        toolCalls: nil,
                        reasoningContent: reasoning
                    ),
                    finishReason: nil
                )
            ]
        )
    }
}

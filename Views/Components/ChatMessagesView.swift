import SwiftUI

/// Список сообщений чата
struct ChatMessagesView: View {
    let messages: [Message]
    let toolCalls: [ToolCall]
    let showStats: Bool
    let isGenerating: Bool
    let currentStats: GenerationStats?
    let onDeleteMessage: (Message) -> Void
    let onEditMessage: (Message, String) -> Void

    var body: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(messages, id: \.id) { message in
                        MessageBubble(
                            message: message,
                            onDelete: { onDeleteMessage(message) },
                            onEdit: { newContent in
                                onEditMessage(message, newContent)
                            }
                        )
                        .id(message.id)
                    }

                    if !toolCalls.isEmpty {
                        ForEach(toolCalls) { call in
                            ToolCallView(toolCall: call)
                        }
                    }

                    if showStats && !isGenerating, let stats = currentStats {
                        GenerationStatsView(stats: stats)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(Color(uiColor: .systemGroupedBackground))
        }
    }
}

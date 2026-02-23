// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import SwiftUI

/// Представление для отображения списка сообщений чата.
/// Содержит прокручиваемую область (ScrollView) с пузырями сообщений,
/// индикаторами вызова инструментов и блоком статистики генерации.
struct ChatMessagesView: View {
    /// Список сообщений для отображения
    let messages: [Message]
    
    /// Текущие активные или завершенные вызовы инструментов (function calling)
    let toolCalls: [ToolCall]
    
    /// Флаг отображения статистики генерации (токены, скорость)
    let showStats: Bool
    
    /// Флаг процесса генерации ответа в данный момент
    let isGenerating: Bool
    
    /// Статистика последней или текущей генерации
    let currentStats: GenerationStats?
    
    /// Колбэк для удаления сообщения из истории
    let onDeleteMessage: (Message) -> Void
    
    /// Колбэк для редактирования текста сообщения
    let onEditMessage: (Message, String) -> Void

    var body: some View {
        ScrollViewReader { _ in
            ScrollView {
                // Используем LazyVStack для оптимизации рендеринга больших списков
                LazyVStack(spacing: 8) {
                    // Отображение каждого сообщения через MessageBubble
                    ForEach(messages, id: \.id) { message in
                        MessageBubble(
                            message: message,
                            onDelete: { onDeleteMessage(message) },
                            onEdit: { newContent in
                                onEditMessage(message, newContent)
                            }
                        )
                        .id(message.id) // Присваиваем ID для возможности программной прокрутки
                    }

                    // Отображение вызовов инструментов (если есть)
                    if !toolCalls.isEmpty {
                        ForEach(toolCalls) { call in
                            ToolCallView(toolCall: call)
                        }
                    }

                    // Отображение блока статистики после завершения генерации
                    if showStats && !isGenerating, let stats = currentStats {
                        GenerationStatsView(stats: stats)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .background(AppColors.backgroundSecondary)
        }
    }
}

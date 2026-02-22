import SwiftUI
import SwiftData

/// Главный экран чата
struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @Environment(\.modelContext) private var modelContext
    @State private var showingHistory = false
    @State private var showingSettings = false
    @State private var showingModelPicker = false
    @State private var scrollProxy: ScrollViewProxy?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !viewModel.isAuthenticated {
                    authRequiredView
                } else if viewModel.messages.isEmpty {
                    emptyStateView
                } else {
                    chatMessagesView
                }

                inputAreaView
            }
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                if viewModel.isAuthenticated {
                    ToolbarItem(placement: .topBarLeading) {
                        Button {
                            showingHistory = true
                        } label: {
                            Image(systemName: "list.bullet")
                        }
                        .accessibilityLabel("История чатов")
                    }

                    ToolbarItem(placement: .principal) {
                        Button {
                            showingModelPicker = true
                        } label: {
                            HStack(spacing: 4) {
                                Text(viewModel.config.selectedModel.isEmpty ? "Модель" : viewModel.config.selectedModel)
                                    .lineLimit(1)
                                Image(systemName: "chevron.down")
                                    .font(.caption)
                            }
                        }
                        .accessibilityLabel("Выбор модели")
                    }

                    ToolbarItem(placement: .topBarTrailing) {
                        HStack(spacing: 16) {
                            ToolsStatusView(isEnabled: viewModel.config.mcpToolsEnabled)

                            Button {
                                showingSettings = true
                            } label: {
                                Image(systemName: "gear")
                            }
                            .accessibilityLabel("Настройки")
                        }
                    }
                }
            }
            .sheet(isPresented: $showingHistory) {
                HistoryView(
                    onSelectSession: { session in
                        viewModel.loadSession(session)
                        showingHistory = false
                    },
                    onDeleteSession: { session in
                        viewModel.deleteSession(session)
                    }
                )
            }
            .sheet(isPresented: $showingModelPicker) {
                ModelPicker(
                    models: viewModel.availableModels,
                    selectedModel: $viewModel.config.selectedModel
                )
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
            }
            .alert("Ошибка", isPresented: .init(
                get: { viewModel.errorMessage != nil },
                set: { if !$0 { viewModel.errorMessage = nil } }
            )) {
                Button("OK", role: .cancel) {}
            } message: {
                Text(viewModel.errorMessage ?? "")
            }
            .task {
                viewModel.setModelContext(modelContext)
                await viewModel.loadModels()
            }
            .onChange(of: viewModel.messages.count) {
                if viewModel.config.autoScroll {
                    scrollToBottom()
                }
            }
        }
    }

    // MARK: - Auth Required View

    private var authRequiredView: some View {
        VStack(spacing: 16) {
            Image(systemName: "lock.shield")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("Устройство не авторизовано")
                .font(.headline)

            Text(viewModel.authError ?? "Добавьте токен в настройках")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Button("Открыть настройки") {
                showingSettings = true
            }
            .buttonStyle(.borderedProminent)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Empty State View

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(.system(size: 60))
                .foregroundStyle(.secondary)

            Text("Начните разговор")
                .font(.headline)

            Text("Отправьте сообщение, чтобы получить ответ от AI")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - Chat Messages View

    private var chatMessagesView: some View {
        ScrollViewReader { proxy in
            ScrollView {
                LazyVStack(spacing: 8) {
                    ForEach(viewModel.messages, id: \.id) { message in
                        MessageBubble(
                            message: message,
                            onDelete: { viewModel.deleteMessage(message) },
                            onEdit: { newContent in
                                Task {
                                    await viewModel.editMessage(message, newContent: newContent)
                                }
                            }
                        )
                        .id(message.id)
                    }

                    if !viewModel.toolCalls.isEmpty {
                        ForEach(viewModel.toolCalls) { call in
                            ToolCallView(toolCall: call)
                        }
                    }

                    if viewModel.config.showStats && !viewModel.isGenerating {
                        GenerationStatsView(stats: viewModel.currentStats)
                    }
                }
                .padding(.horizontal)
                .padding(.vertical, 8)
            }
            .onAppear {
                scrollProxy = proxy
            }
        }
        .background(Color(uiColor: .systemGroupedBackground))
    }

    // MARK: - Input Area View

    private var inputAreaView: some View {
        VStack(spacing: 0) {
            Divider()

            HStack(alignment: .bottom, spacing: 12) {
                TextEditor(text: $viewModel.inputText)
                    .frame(minHeight: 36, maxHeight: 100)
                    .scrollContentBackground(.hidden)
                    .background(Color(uiColor: .systemGray6))
                    .cornerRadius(18)
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color(uiColor: .systemGray4), lineWidth: 1)
                    )
                    .accessibilityLabel("Ввод сообщения")
                    .accessibilityHint("Введите текст сообщения")

                Button {
                    if viewModel.isGenerating {
                        viewModel.stopGeneration()
                    } else {
                        Task {
                            await viewModel.sendMessage()
                        }
                    }
                } label: {
                    Image(systemName: viewModel.isGenerating ? "stop.fill" : "arrow.up.circle.fill")
                        .font(.system(size: 32))
                        .foregroundStyle(viewModel.isGenerating ? .red : ThemeManager.shared.accentColor)
                }
                .disabled(viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && !viewModel.isGenerating)
                .accessibilityLabel(viewModel.isGenerating ? "Остановить генерацию" : "Отправить сообщение")
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
            .background(Color(uiColor: .systemBackground))
        }
    }

    // MARK: - Helpers

    private func scrollToBottom() {
        guard let lastMessage = viewModel.messages.last else { return }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
            withAnimation {
                scrollProxy?.scrollTo(lastMessage.id, anchor: .bottom)
            }
        }
    }
}

#Preview {
    ChatView()
        .modelContainer(PersistenceController.shared.container)
}

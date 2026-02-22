import SwiftUI
import SwiftData
import UIKit

/// Главный экран чата
struct ChatView: View {
    @StateObject private var viewModel = ChatViewModel()
    @Environment(\.modelContext) private var modelContext
    @State private var showingHistory = false
    @State private var showingModelPicker = false
    @State private var scrollProxy: ScrollViewProxy?

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                if !viewModel.isAuthenticated {
                    tokenRequiredView
                } else if viewModel.messages.isEmpty {
                    emptyStateView
                } else {
                    chatMessagesView
                }

                inputAreaView
            }
            .contentShape(Rectangle())
            .onTapGesture {
                UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }
                    .flatMap { $0.windows }
                    .first(where: { $0.isKeyWindow })?
                    .endEditing(true)
            }
            .onAppear {
                viewModel.refreshAuthentication()
                Task {
                    await viewModel.checkServerConnection()
                }
            }
            .navigationTitle("Chat")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
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
                            Text(viewModel.config.selectedModel.isEmpty ? "Выбрать модель" : viewModel.config.selectedModel)
                                .lineLimit(1)
                            Image(systemName: "chevron.down")
                                .font(.caption)
                        }
                    }
                    .accessibilityLabel("Выбор модели")
                }

                ToolbarItem(placement: .navigationBarLeading) {
                    Circle()
                        .fill(viewModel.isServerReachable ? Color.green : Color.red)
                        .frame(width: 10, height: 10)
                }

                ToolbarItem(placement: .navigationBarTrailing) {
                    Button {
                        viewModel.config.mcpToolsEnabled.toggle()
                    } label: {
                        Image(systemName: viewModel.config.mcpToolsEnabled ? "wrench.and.screwdriver.fill" : "wrench.and.screwdriver")
                            .foregroundStyle(viewModel.config.mcpToolsEnabled ? ThemeManager.shared.accentColor : .secondary)
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
            .onChange(of: viewModel.errorMessage) {
                // Ошибки обрабатываются без показа алерта
                // viewModel.errorMessage очищается автоматически
            }
            .task {
                viewModel.setModelContext(modelContext)
                await viewModel.loadModels()
            }
            .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
                viewModel.refreshAuthentication()
            }
            .onChange(of: viewModel.messages.count) {
                if viewModel.config.autoScroll {
                    scrollToBottom()
                }
            }
        }
    }

    // MARK: - Auth Required View

    private var tokenRequiredView: some View {
        VStack(spacing: 20) {
            ShieldView { token in
                viewModel.saveToken(token)
            }
            .frame(width: 280, height: 280)

            Text("Требуется токен")
                .font(.headline)

            Text("Скопируйте токен и нажмите на щит")
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
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
            // Иконки статуса над всей областью ввода (только для авторизованных)
            if viewModel.isAuthenticated {
                HStack(alignment: .bottom) {
                    Spacer()
                    StatusBadgeView(
                        isConnected: viewModel.isConnected,
                        isServerReachable: viewModel.isServerReachable,
                        isModelSelected: !viewModel.config.selectedModel.isEmpty
                    )
                    .padding(.bottom, 16)
                }
                .frame(height: 52)
                .padding(.trailing, 16)
                .background(Color(uiColor: .systemBackground))
            }

            if viewModel.isAuthenticated {
                HStack(alignment: .bottom, spacing: 8) {
                    TextField("Сообщение...", text: $viewModel.inputText, axis: .vertical)
                        .textFieldStyle(.plain)
                        .lineLimit(1...10)
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.clear)
                        .cornerRadius(18)
                        .overlay(
                            RoundedRectangle(cornerRadius: 18)
                                .stroke(Color(uiColor: .systemGray4), lineWidth: 1)
                        )
                        .accessibilityLabel("Ввод сообщения")
                        .accessibilityHint("Введите текст сообщения")

                    if viewModel.isAuthenticated {
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
                        .disabled(!viewModel.isGenerating && (viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty || !viewModel.isServerReachable || viewModel.config.selectedModel.isEmpty))
                        .opacity((viewModel.isGenerating || (!viewModel.inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty && viewModel.isServerReachable && !viewModel.config.selectedModel.isEmpty)) ? 1.0 : 0.5)
                        .accessibilityLabel(viewModel.isGenerating ? "Остановить генерацию" : "Отправить сообщение")
                    }
                }
                .padding(.horizontal)
                .padding(.bottom, 8)
            }
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

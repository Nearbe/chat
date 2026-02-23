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
                    ChatMessagesView(
                        messages: viewModel.messages,
                        toolCalls: viewModel.toolCalls,
                        showStats: viewModel.config.showStats,
                        isGenerating: viewModel.isGenerating,
                        currentStats: viewModel.currentStats,
                        onDeleteMessage: { viewModel.deleteMessage($0) },
                        onEditMessage: { message, newContent in
                            Task {
                                await viewModel.editMessage(message, newContent: newContent)
                            }
                        }
                    )
                }

                MessageInputView(
                    inputText: $viewModel.inputText,
                    isAuthenticated: viewModel.isAuthenticated,
                    isGenerating: viewModel.isGenerating,
                    isServerReachable: viewModel.isServerReachable,
                    selectedModel: viewModel.config.selectedModel,
                    onSend: { await viewModel.sendMessage() },
                    onStop: { viewModel.stopGeneration() }
                )
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

}

#Preview {
    ChatView()
        .modelContainer(PersistenceController.shared.container)
}

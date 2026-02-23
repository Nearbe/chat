// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import SwiftUI
import SwiftData
import Combine

/// Центральный компонент приложения, управляющий бизнес-логикой чата.
@MainActor
final class ChatViewModel: ObservableObject {

    // MARK: - Published Properties

    @Published var messages: [Message] = []
    @Published var inputText: String = ""
    @Published var isGenerating: Bool = false
    @Published var errorMessage: String?
    @Published var availableModels: [ModelInfo] = []
    @Published var currentStats: GenerationStats = .empty
    @Published var toolCalls: [ToolCall] = []
    @Published var isAuthenticated: Bool = false
    @Published var isConnected: Bool = true
    @Published var isServerReachable: Bool = true
    @Published var isModelSelected: Bool = false

    // MARK: - Properties

    var config = AppConfig.shared

    var currentSession: ChatSession? {
        get { _currentSession }
        set { _currentSession = newValue }
    }
    private var _currentSession: ChatSession?

    private var sessionManager: ChatSessionManager?
    private var chatService: ChatServiceProtocol?
    private var networkMonitor: NetworkMonitoring?
    private var cancellables = Set<AnyCancellable>()
    private var streamingTask: Task<Void, Never>?
    private var generationStartTime: Date?

    init() {
        refreshAuthentication()
    }

    deinit {
        streamingTask?.cancel()
    }

    /// Настройка зависимостей и наблюдение за статусом сети
    /// - Parameters:
    ///   - sessionManager: Менеджер сессий SwiftData
    ///   - chatService: Сервис для общения с AI
    ///   - networkMonitor: Монитор сетевого подключения
    func setup(
        sessionManager: ChatSessionManager,
        chatService: ChatServiceProtocol,
        networkMonitor: NetworkMonitoring
    ) {
        self.sessionManager = sessionManager
        self.chatService = chatService
        self.networkMonitor = networkMonitor

        refreshAuthentication()

        networkMonitor.isConnectedPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.isConnected, on: self)
            .store(in: &cancellables)
    }

    // MARK: - Authentication

    /// Обновить статус авторизации
    func refreshAuthentication() {
        isAuthenticated = DeviceIdentity.isAuthorized &&
                         DeviceAuthorizationProvider().authorizationHeader() != nil
    }

    /// Сохранить токен доступа
    /// - Parameter token: Строка токена
    func saveToken(_ token: String) {
        if let config = DeviceConfiguration.configuration(for: DeviceIdentity.currentName) {
            _ = KeychainHelper.set(key: config.tokenKey, value: token)
            refreshAuthentication()
        }
    }

    // MARK: - Model Management

    /// Загрузить список доступных моделей
    func loadModels() async {
        guard let chatService = chatService else { return }
        do {
            let models = try await chatService.fetchModels()
            availableModels = models
            isServerReachable = true

            if !config.selectedModel.isEmpty && !models.contains(where: { $0.id == config.selectedModel }) {
                config.selectedModel = ""
            }
            isModelSelected = !config.selectedModel.isEmpty
        } catch {
            availableModels = []
            isServerReachable = false
            isModelSelected = !config.selectedModel.isEmpty
        }
    }

    /// Проверить соединение с сервером
    func checkServerConnection() async {
        await loadModels()
    }

    // MARK: - Session Management

    /// Установить текущую активную сессию
    /// - Parameter session: Сессия из SwiftData
    func setSession(_ session: ChatSession) {
        currentSession = session
        messages = session.sortedMessages
        config.selectedModel = session.modelName
        isModelSelected = !config.selectedModel.isEmpty
    }

    /// Установить контекст данных (SwiftData)
    /// - Parameter context: Контекст модели
    func setModelContext(_ context: ModelContext) {
        self.sessionManager = ChatSessionManager(modelContext: context)
    }

    /// Удалить сессию чата
    /// - Parameter session: Сессия для удаления
    func deleteSession(_ session: ChatSession) {
        if currentSession?.id == session.id {
            currentSession = nil
            messages = []
        }
        sessionManager?.deleteSession(session)
    }

    /// Создать новую сессию в SwiftData
    /// - Returns: Созданная сессия
    func createNewSession() -> ChatSession {
        stopGeneration()
        currentSession = nil
        messages = []
        toolCalls = []

        let session = sessionManager?.createSession(modelName: config.selectedModel)
            ?? ChatSession(modelName: config.selectedModel)
        currentSession = session
        return session
    }

    // MARK: - Message Actions

    /// Отправить сообщение пользователю
    func sendMessage() async {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let sessionManager = sessionManager,
              chatService != nil else { return }

        let content = inputText
        inputText = ""
        errorMessage = nil

        if currentSession == nil {
            currentSession = sessionManager.createSession(modelName: config.selectedModel)
        }

        guard let session = currentSession else { return }

        let userMsg = Message.user(
            content: content,
            sessionId: session.id,
            index: session.nextMessageIndex
        )
        sessionManager.addMessage(userMsg, to: session)
        messages = session.sortedMessages

        await generateResponse()
    }

    /// Остановить генерацию ответа
    func stopGeneration() {
        streamingTask?.cancel()
        isGenerating = false
        if let lastMsg = messages.last, lastMsg.isGenerating {
            lastMsg.isGenerating = false
            sessionManager?.save()
        }
    }

    /// Удалить сообщение из текущей сессии
    /// - Parameter message: Сообщение для удаления
    func deleteMessage(_ message: Message) {
        guard let session = currentSession else { return }
        sessionManager?.deleteMessage(message)
        messages = session.sortedMessages
    }

    /// Отредактировать существующее сообщение
    /// - Parameters:
    ///   - message: Исходное сообщение
    ///   - newContent: Новый текст
    func editMessage(_ message: Message, newContent: String) async {
        guard let session = currentSession, let sessionManager = sessionManager else { return }

        sessionManager.deleteMessages(after: message.index, in: session)
        message.content = newContent
        sessionManager.save()

        messages = session.sortedMessages
        await generateResponse()
    }

    /// Очистить сообщение об ошибке
    func clearError() {
        errorMessage = nil
    }

    // MARK: - Generation Logic

    /// Запуск процесса генерации ответа от AI
    private func generateResponse() async {
        guard let session = currentSession,
              let sessionManager = sessionManager else { return }

        isGenerating = true
        currentStats = .empty
        toolCalls = []
        generationStartTime = Date()

        let assistantMsg = createAssistantMessage(in: session)
        sessionManager.addMessage(assistantMsg, to: session)
        messages.append(assistantMsg)

        let apiMessages = session.sortedMessages.map { ChatMessage(from: $0) }

        streamingTask = Task { [weak self] in
            guard let self = self else { return }
            await self.performStreaming(messages: apiMessages, assistantMsg: assistantMsg)
            self.isGenerating = false
        }
    }

    private func createAssistantMessage(in session: ChatSession) -> Message {
        return Message.assistant(
            sessionId: session.id,
            index: session.nextMessageIndex,
            modelName: config.selectedModel
        )
    }

    private func performStreaming(messages apiMessages: [ChatMessage], assistantMsg: Message) async {
        guard let chatService = chatService else { return }

        do {
            let stream = chatService.streamChat(
                messages: apiMessages,
                model: config.selectedModel,
                temperature: config.temperature,
                maxTokens: config.maxTokens
            )

            var tokenCount = 0
            for try await part in stream {
                if Task.isCancelled { break }
                updateResponse(with: part, assistantMsg: assistantMsg, tokenCount: &tokenCount)
            }

            if !Task.isCancelled {
                finalizeResponse(assistantMsg: assistantMsg, tokenCount: tokenCount)
            }
        } catch {
            handleGenerationError(error, assistantMsg: assistantMsg)
        }
    }

    private func updateResponse(with part: ChatCompletionStreamPart, assistantMsg: Message, tokenCount: inout Int) {
        guard let delta = part.choices.first?.delta else { return }

        if let content = delta.content {
            assistantMsg.content += content
            tokenCount += 1
        }

        if let reasoning = delta.reasoningContent {
            assistantMsg.reasoning = (assistantMsg.reasoning ?? "") + reasoning
        }

        updateStats(tokenCount: tokenCount, finishReason: part.choices.first?.finishReason)
    }

    private func updateStats(tokenCount: Int, finishReason: String?) {
        guard let startTime = generationStartTime else { return }
        let duration = Date().timeIntervalSince(startTime)
        currentStats = GenerationStats(
            totalTokens: tokenCount,
            tokensPerSecond: duration > 0 ? Double(tokenCount) / duration : 0,
            generationTime: duration,
            stopReason: finishReason
        )
    }

    private func finalizeResponse(assistantMsg: Message, tokenCount: Int) {
        assistantMsg.isGenerating = false
        assistantMsg.tokensUsed = tokenCount
        sessionManager?.save()
    }

    private func handleGenerationError(_ error: Error, assistantMsg: Message) {
        if !Task.isCancelled {
            errorMessage = error.localizedDescription
            assistantMsg.isGenerating = false
            sessionManager?.save()
        }
    }
}

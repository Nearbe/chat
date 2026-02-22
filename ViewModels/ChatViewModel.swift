import SwiftUI
import SwiftData

/// Основной ViewModel для чата
@MainActor
final class ChatViewModel: ObservableObject {
    // MARK: - Публичные свойства

    @Published var messages: [Message] = []
    @Published var inputText: String = ""
    @Published var isGenerating: Bool = false
    @Published var errorMessage: String?
    @Published var availableModels: [ModelInfo] = []
    @Published var currentStats: GenerationStats = .empty
    @Published var toolCalls: [ToolCall] = []
    @Published var isAuthenticated: Bool = false
    @Published var authError: String?

    var config = AppConfig.shared

    // MARK: - Приватные свойства

    private var currentSession: ChatSession?
    private let networkService: NetworkService
    private let authManager = DeviceAuthManager()
    private var modelContext: ModelContext?
    private var generationStartTime: Date?
    private var streamingTask: Task<Void, Never>?

    // MARK: - Инициализация

    init() {
        self.networkService = NetworkService(deviceName: UIDevice.current.name)
        checkAuthentication()
    }

    // MARK: - Авторизация

    func checkAuthentication() {
        let result = authManager.authenticate()
        switch result {
        case .success:
            isAuthenticated = true
            authError = nil
        case .failure(let error):
            isAuthenticated = false
            authError = error.localizedDescription
        }
    }

    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }

    // MARK: - Загрузка моделей

    func loadModels() async {
        do {
            let models = try await networkService.fetchModels()
            availableModels = models
            if config.selectedModel.isEmpty, let firstModel = models.first {
                config.selectedModel = firstModel.id
            }
        } catch {
            // Не показываем алерт - оставляем пустую заглушку
            availableModels = []
        }
    }

    // MARK: - Управление сессиями

    func createNewSession() -> ChatSession {
        // Отменяем текущую генерацию при создании новой сессии
        streamingTask?.cancel()
        streamingTask = nil

        let session = ChatSession(modelName: config.selectedModel)
        currentSession = session
        messages = []
        toolCalls = []
        isGenerating = false
        return session
    }

    func loadSession(_ session: ChatSession) {
        currentSession = session
        messages = session.sortedMessages
        config.selectedModel = session.modelName
    }

    func deleteSession(_ session: ChatSession) {
        modelContext?.delete(session)
        try? modelContext?.save()
    }

    // MARK: - Отправка сообщений

    func sendMessage() async {
        guard !isGenerating else { return }  // Предотвращаем race condition
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        guard isAuthenticated else {
            // Не показываем алерт - показываем authRequiredView
            return
        }

        let userMessage = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        inputText = ""

        let sessionId = currentSession?.id ?? UUID()
        let index = messages.count

        let userMsg = Message.user(content: userMessage, sessionId: sessionId, index: index)
        messages.append(userMsg)

        if currentSession == nil {
            currentSession = ChatSession(id: sessionId, title: String(userMessage.prefix(50)), modelName: config.selectedModel)
            currentSession?.addMessage(userMsg)
            if let ctx = modelContext {
                ctx.insert(currentSession!)
                try? ctx.save()
            }
        } else if let session = currentSession {
            session.addMessage(userMsg)
            try? modelContext?.save()
        }

        await generateResponse(for: sessionId)
    }

    func stopGeneration() {
        streamingTask?.cancel()
        streamingTask = nil
        isGenerating = false

        if let lastMessage = messages.last, lastMessage.isAssistant {
            lastMessage.isGenerating = false
        }
    }

    // MARK: - Генерация ответа

    private func generateResponse(for sessionId: UUID) async {
        isGenerating = true
        errorMessage = nil
        toolCalls = []
        generationStartTime = Date()

        let apiMessages: [ChatMessage] = messages.map { ChatMessage(from: $0) }

        // mcpToolsEnabled: true = сервер использует свои tools, false = отключено
        let tools: [ToolDefinition]? = config.mcpToolsEnabled ? nil : []

        let request = ChatCompletionRequest(
            model: config.selectedModel,
            messages: apiMessages,
            temperature: config.temperature,
            maxTokens: config.maxTokens,
            stream: true,
            tools: tools
        )

        let assistantIndex = messages.count
        let assistantMsg = Message.assistant(content: "", sessionId: sessionId, index: assistantIndex, modelName: config.selectedModel)
        messages.append(assistantMsg)

        do {
            var fullContent = ""
            var currentToolCalls: [Int: ToolCall] = [:]

            for try await chunk in await networkService.streamChat(request: request) {
                for choice in chunk.choices {
                    if let content = choice.delta.content {
                        fullContent += content
                        messages[messages.count - 1].content = fullContent
                    }

                    if let calls = choice.delta.toolCalls {
                        for call in calls {
                            if var existingCall = currentToolCalls[call.index] {
                                if let args = call.function?.arguments {
                                    existingCall.arguments += args
                                }
                                currentToolCalls[call.index] = existingCall
                            } else if let name = call.function?.name, let args = call.function?.arguments {
                                let newCall = ToolCall(index: call.index, name: name, arguments: args)
                                currentToolCalls[call.index] = newCall
                            }
                        }
                        toolCalls = Array(currentToolCalls.values).sorted { $0.index < $1.index }
                    }

                    if let reason = choice.finishReason {
                        if reason == "tool_calls" {
                            await handleToolCalls(Array(currentToolCalls.values), sessionId: sessionId)
                        }

                        let endTime = Date()
                        let duration = endTime.timeIntervalSince(generationStartTime ?? endTime)
                        let tokens = fullContent.count / 4
                        currentStats = GenerationStats(
                            totalTokens: tokens,
                            tokensPerSecond: duration > 0 ? Double(tokens) / duration : 0,
                            generationTime: duration,
                            stopReason: reason
                        )

                        messages[messages.count - 1].isGenerating = false
                        messages[messages.count - 1].tokensUsed = tokens
                        isGenerating = false
                    }
                }
            }
        } catch is CancellationError {
            messages[messages.count - 1].isGenerating = false
        } catch {
            // Обработка ошибок авторизации - не показываем алерт
            if let responseError = error as? NetworkError, case .unauthorized = responseError {
                authManager.clearToken()
                isAuthenticated = false
                authError = "Токен истёк. Пожалуйста, добавьте новый токен."
            } else if !(error is CancellationError) {
                // Для остальных ошибок показываем алерт
                errorMessage = "Ошибка: \(error.localizedDescription)"
            }
            messages[messages.count - 1].isGenerating = false
        }

        try? modelContext?.save()
    }

    // MARK: - Обработка Tool Calls

    private func handleToolCalls(_ calls: [ToolCall], sessionId: UUID) async {
        for var call in calls {
            call.isExecuting = true
            let result: String

            switch call.name {
            case "get_current_time":
                let date = Date()
                let formatter = DateFormatter()
                if let tz = call.parsedArguments?["timezone"] as? String {
                    formatter.timeZone = TimeZone(identifier: tz)
                }
                formatter.dateFormat = "dd MMMM yyyy, HH:mm:ss"
                result = formatter.string(from: date)

            case "calculate":
                if let expr = call.parsedArguments?["expression"] as? String {
                    let sanitized = expr.replacingOccurrences(of: "[^0-9+\\-*/.() ]", with: "", options: .regularExpression)
                    let expression = NSExpression(format: sanitized)
                    if let value = expression.expressionValue(with: nil, context: nil) as? NSNumber {
                        result = value.stringValue
                    } else {
                        result = "Ошибка вычисления"
                    }
                } else {
                    result = "Неверные аргументы"
                }

            default:
                result = "Неизвестный инструмент: \(call.name)"
            }

            call.result = result
            call.isExecuting = false

            if let idx = toolCalls.firstIndex(where: { $0.index == call.index }) {
                toolCalls[idx] = call
            }

            let toolMessage = Message(content: result, role: "tool", index: messages.count, sessionId: sessionId)
            messages.append(toolMessage)
        }

        await generateResponse(for: sessionId)
    }

    // MARK: - Удаление и редактирование

    func deleteMessage(_ message: Message) {
        messages.removeAll { $0.id == message.id }
        modelContext?.delete(message)
        try? modelContext?.save()
    }

    func editMessage(_ message: Message, newContent: String) async {
        guard message.isUser else { return }
        message.content = newContent

        let laterMessages = messages.filter { $0.index > message.index }
        for msg in laterMessages {
            modelContext?.delete(msg)
        }
        messages = messages.filter { $0.index <= message.index }
        try? modelContext?.save()

        await generateResponse(for: message.sessionId)
    }
}

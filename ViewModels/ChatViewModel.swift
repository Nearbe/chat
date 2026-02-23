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
    
    let config = AppConfig.shared
    
    private var sessionManager: ChatSessionManager?
    private var chatService: ChatService?
    private var networkMonitor: NetworkMonitor?
    private var currentSession: ChatSession?
    private var cancellables = Set<AnyCancellable>()
    private var streamingTask: Task<Void, Never>?
    private var generationStartTime: Date?
    
    // MARK: - Setup
    
    func setup(
        sessionManager: ChatSessionManager,
        chatService: ChatService,
        networkMonitor: NetworkMonitor
    ) {
        self.sessionManager = sessionManager
        self.chatService = chatService
        self.networkMonitor = networkMonitor
        
        networkMonitor.$isConnected
            .receive(on: RunLoop.main)
            .assign(to: \.isConnected, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Authentication
    
    func refreshAuthentication() {
        isAuthenticated = DeviceIdentity.isAuthorized && 
                         DeviceAuthorizationProvider().authorizationHeader() != nil
    }
    
    func saveToken(_ token: String) {
        if let config = DeviceConfiguration.configuration(for: DeviceIdentity.currentName) {
            _ = KeychainHelper.set(key: config.tokenKey, value: token)
            refreshAuthentication()
        }
    }
    
    // MARK: - Model Management
    
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
            isServerReachable = isConnected
            isModelSelected = !config.selectedModel.isEmpty
        }
    }
    
    func checkServerConnection() async {
        await loadModels()
    }
    
    // MARK: - Session Management
    
    func setSession(_ session: ChatSession) {
        currentSession = session
        messages = session.sortedMessages
        config.selectedModel = session.modelName
        isModelSelected = !config.selectedModel.isEmpty
    }
    
    func deleteSession(_ session: ChatSession) {
        if currentSession?.id == session.id {
            currentSession = nil
            messages = []
        }
        sessionManager?.deleteSession(session)
    }
    
    func createNewSession() -> ChatSession {
        stopGeneration()
        currentSession = nil
        messages = []
        toolCalls = []
        
        let session = sessionManager?.createSession(modelName: config.selectedModel) ?? ChatSession(modelName: config.selectedModel)
        currentSession = session
        return session
    }
    
    // MARK: - Message Actions
    
    func sendMessage() async {
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              let sessionManager = sessionManager,
              let chatService = chatService else { return }
        
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
    
    func stopGeneration() {
        streamingTask?.cancel()
        isGenerating = false
        if let lastMsg = messages.last, lastMsg.isGenerating {
            lastMsg.isGenerating = false
            sessionManager?.save()
        }
    }
    
    func deleteMessage(_ message: Message) {
        guard let session = currentSession else { return }
        sessionManager?.deleteMessage(message)
        messages = session.sortedMessages
    }
    
    func editMessage(_ message: Message, newContent: String) async {
        guard let session = currentSession, let sessionManager = sessionManager else { return }
        
        sessionManager.deleteMessages(after: message.index, in: session)
        message.content = newContent
        sessionManager.save()
        
        messages = session.sortedMessages
        await generateResponse()
    }
    
    // MARK: - Generation Logic
    
    private func generateResponse() async {
        guard let session = currentSession,
              let chatService = chatService,
              let sessionManager = sessionManager else { return }
        
        isGenerating = true
        currentStats = .empty
        toolCalls = []
        generationStartTime = Date()
        
        let assistantMsg = Message.assistant(
            sessionId: session.id,
            index: session.nextMessageIndex,
            modelName: config.selectedModel
        )
        sessionManager.addMessage(assistantMsg, to: session)
        messages.append(assistantMsg)
        
        let apiMessages = session.sortedMessages.map { ChatMessage(from: $0) }
        
        streamingTask = Task {
            do {
                let stream = chatService.streamChat(
                    messages: apiMessages,
                    model: config.selectedModel,
                    temperature: config.temperature,
                    maxTokens: config.maxTokens
                )
                
                var totalContent = ""
                var totalReasoning = ""
                var tokenCount = 0
                
                for try await part in stream {
                    if Task.isCancelled { break }
                    
                    if let delta = part.choices.first?.delta {
                        if let content = delta.content {
                            totalContent += content
                            assistantMsg.content = totalContent
                            tokenCount += 1
                        }
                        
                        if let reasoning = delta.reasoningContent {
                            totalReasoning += reasoning
                            assistantMsg.reasoning = (assistantMsg.reasoning ?? "") + reasoning
                        }
                        
                        // Update stats
                        if let startTime = generationStartTime {
                            let duration = Date().timeIntervalSince(startTime)
                            currentStats = GenerationStats(
                                totalTokens: tokenCount,
                                tokensPerSecond: duration > 0 ? Double(tokenCount) / duration : 0,
                                generationTime: duration,
                                stopReason: part.choices.first?.finishReason
                            )
                        }
                    }
                }
                
                assistantMsg.isGenerating = false
                assistantMsg.tokensUsed = tokenCount
                sessionManager.save()
                
            } catch {
                if !Task.isCancelled {
                    errorMessage = error.localizedDescription
                }
                assistantMsg.isGenerating = false
                sessionManager.save()
            }
            
            isGenerating = false
        }
    }
}

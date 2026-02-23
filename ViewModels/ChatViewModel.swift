import SwiftUI
import SwiftData
import Network

// MARK: - Основной ViewModel для чата

/// Центральный компонент приложения, управляющий всей бизнес-логикой чата.
/// Работает в основном потоке благодаря аннотации @MainActor.
///
/// Основные функции:
/// - Управление сообщениями (отправка, редактирование, удаление)
/// - Взаимодействие с LM Studio API через стриминг
/// - Управление сессиями и историей чатов
/// - Авторизация через Keychain
/// - Мониторинг сетевого подключения
/// - Обработка tool calls от AI моделей
///
/// Архитектура: MVVM с использованием Swift Concurrency
/// Персистентность: SwiftData для сообщений и сессий
///
/// - Важно: Все @Published свойства автоматически обновляют UI при изменении
/// - Примечание: Использует Network framework для мониторинга подключения
@MainActor
final class ChatViewModel: ObservableObject {
    
    // MARK: - Публичные Published свойства (Public Published Properties)
    
    /// Список сообщений в текущей сессии чата
    /// Обновляется автоматически при отправке/получении новых сообщений
    @Published var messages: [Message] = []
    
    /// Текст, вводимый пользователем в поле сообщения
    /// Двустороннее связывание (binding) с TextField в UI
    @Published var inputText: String = ""
    
    /// Флаг генерации ответа AI
    /// true - идёт генерация, false - ожидание пользователя
    /// Используется для блокировки повторной отправки и показа индикатора
    @Published var isGenerating: Bool = false
    
    /// Текущее сообщение об ошибке
    /// nil - ошибок нет, строка - текст ошибки
    /// Очищается автоматически при следующем действии
    @Published var errorMessage: String?
    
    /// Список доступных моделей от LM Studio
    /// Загружается асинхронно при запуске и при открытии ModelPicker
    @Published var availableModels: [ModelInfo] = []
    
    /// Статистика текущей генерации
    /// Включает количество токенов, скорость, время генерации
    @Published var currentStats: GenerationStats = .empty
    
    /// Список текущих tool calls от AI
    /// Используются для отображения выполняемых инструментов
    @Published var toolCalls: [ToolCall] = []
    
    /// Флаг авторизации пользователя
    /// true - токен сохранён в Keychain, false - требуется авторизация
    @Published var isAuthenticated: Bool = false
    
    /// Ошибка авторизации (если есть)
    /// Отображается на экране авторизации
    @Published var authError: String?
    
    /// Статус сетевого подключения (WiFi/Cellular)
    /// Используется для определения возможности подключения к серверу
    @Published var isConnected: Bool = true
    
    /// Флаг доступности LM Studio сервера
    /// true - сервер отвечает, false - сервер недоступен
    @Published var isServerReachable: Bool = true
    
    /// Флаг выбора модели
    /// true - модель выбрана, false - требуется выбор модели
    @Published var isModelSelected: Bool = false
    
    // MARK: - Публичные свойства (Public Properties)
    
    /// Конфигурация приложения
    /// Содержит настройки из UserDefaults (модель, температура, инструменты и т.д.)
    var config = AppConfig.shared
    
    // MARK: - Приватные свойства (Private Properties)
    
    /// Текущая активная сессия чата
    /// Создаётся при первом сообщении или при загрузке из истории
    private var currentSession: ChatSession?
    
    /// Сетевой сервис для взаимодействия с LM Studio API
    /// Создаётся с именем текущего устройства для логирования
    private let networkService: NetworkService
    
    /// Менеджер авторизации через Keychain
    /// Управляет сохранением и получением токена устройства
    private let authManager = DeviceAuthManager()
    
    /// Контекст SwiftData для персистентности
    /// Устанавливается из SwiftUI при появлении View
    private var modelContext: ModelContext?
    
    /// Время начала генерации
    /// Используется для расчёта статистики скорости
    private var generationStartTime: Date?
    
    /// Задача стриминга (для возможности отмены)
    /// Позволяет остановить генерацию при необходимости
    private var streamingTask: Task<Void, Never>?
    
    /// Монитор сетевого подключения (NWPathMonitor)
    /// Отслеживает изменения WiFi/Ethernet подключения в реальном времени
    private let pathMonitor = NWPathMonitor()
    
    /// Очередь для монитора сети
    /// Использует отдельный поток для мониторинга
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")

    // MARK: - Инициализация (Initialization)
    
    /// Инициализация ViewModel
    /// Настраивает сетевой сервис, проверяет авторизацию и запускает мониторинг сети
    init() {
        // Создаём сетевой сервис с именем текущего устройства
        // Это используется для идентификации в логах сервера
        self.networkService = NetworkService(deviceName: UIDevice.current.name)
        
        // Проверяем токен авторизации при инициализации
        // Если токен есть в Keychain - сразу авторизуем пользователя
        checkAuthentication()
        
        // Запускаем мониторинг сетевого подключения
        // Позволяет отслеживать доступность сервера в реальном времени
        startNetworkMonitoring()
    }
    
    /// Деинициализация
    /// Очищает ресурсы при удалении объекта
    deinit {
        // Останавливаем монитор сети для предотвращения утечек
        pathMonitor.cancel()
    }

    // MARK: - Публичные методы (Public Methods)
    
    /// Обновить статус авторизации
    /// Вызывается при появлении ChatView и при изменении настроек
    /// Проверяет наличие токена в Keychain
    func refreshAuthentication() {
        checkAuthentication()
    }
    
    /// Сохранить токен авторизации
    /// - Parameter token: API токен от LM Studio (должен начинаться с "sk-lm")
    /// Сохраняет токен в Keychain и обновляет статус авторизации
    func saveToken(_ token: String) {
        authManager.setToken(token)
        checkAuthentication()
    }
    
    /// Установить контекст SwiftData
    /// - Parameter context: ModelContext от SwiftUI environment
    /// Должен быть вызван в .task модификаторе View
    func setModelContext(_ context: ModelContext) {
        self.modelContext = context
    }
    
    /// Загрузить доступные модели с сервера
    /// - Важно: Выполняется асинхронно через async/await
    /// - Примечание: При ошибке очищает список моделей
    func loadModels() async {
        do {
            // Запрашиваем модели у LM Studio
            let models = try await networkService.fetchModels()
            availableModels = models
            isServerReachable = true
            
            // Проверяем, что выбранная модель всё ещё доступна
            // Если нет - сбрасываем выбор
            if !config.selectedModel.isEmpty && !models.contains(where: { $0.id == config.selectedModel }) {
                config.selectedModel = ""
            }
            isModelSelected = !config.selectedModel.isEmpty
        } catch {
            // При ошибке очищаем список моделей
            availableModels = []
            // Сервер недоступен, но возможно есть интернет
            isServerReachable = isConnected
            isModelSelected = !config.selectedModel.isEmpty
        }
    }
    
    /// Проверить подключение к LM Studio серверу
    /// - Важно: Выполняется асинхронно
    /// - Примечание: Не обновляет список моделей, только статус подключения
    func checkServerConnection() async {
        do {
            // Пробуем получить список моделей
            // Если успешно - сервер доступен
            _ = try await networkService.fetchModels()
            isServerReachable = true
        } catch {
            // При ошибке - сервер недоступен
            isServerReachable = isConnected
        }
        isModelSelected = !config.selectedModel.isEmpty
    }
    
    /// Создать новую сессию чата
    /// - Returns: Новая пустая сессия ChatSession
    /// - Примечание: Очищает текущие сообщения и отменяет генерацию
    func createNewSession() -> ChatSession {
        // Отменяем текущую генерацию
        streamingTask?.cancel()
        streamingTask = nil
        
        // Создаём новую сессию с выбранной моделью
        let session = ChatSession(modelName: config.selectedModel)
        currentSession = session
        
        // Очищаем сообщения и состояние
        messages = []
        toolCalls = []
        isGenerating = false
        
        return session
    }
    
    /// Загрузить существующую сессию из истории
    /// - Parameter session: Сессия для загрузки
    /// Восстанавливает сообщения и выбранную модель
    func loadSession(_ session: ChatSession) {
        currentSession = session
        messages = session.sortedMessages
        config.selectedModel = session.modelName
    }
    
    /// Удалить сессию
    /// - Parameter session: Сессия для удаления
    /// Удаляет из SwiftData и сохраняет контекст
    func deleteSession(_ session: ChatSession) {
        modelContext?.delete(session)
        try? modelContext?.save()
    }
    
    /// Отправить сообщение
    /// - Важно: Выполняется асинхронно через async/await
    /// - Примечание: Не отправляет если идёт генерация или текст пустой
    func sendMessage() async {
        // Защита от race condition - игнорируем повторные вызовы
        guard !isGenerating else { return }
        
        // Проверяем что текст не пустой
        guard !inputText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else { return }
        
        // Проверяем авторизацию
        guard isAuthenticated else {
            // Если не авторизован - просто возвращаемся
            // UI сам покажет экран авторизации
            return
        }

        // Очищаем текст и сохраняем сообщение
        let userMessage = inputText.trimmingCharacters(in: .whitespacesAndNewlines)
        inputText = ""

        // Создаём идентификатор сессии и индекс сообщения
        let sessionId = currentSession?.id ?? UUID()
        let index = messages.count

        // Создаём сообщение пользователя
        let userMsg = Message.user(content: userMessage, sessionId: sessionId, index: index)
        messages.append(userMsg)

        // Создаём или обновляем сессию
        if currentSession == nil {
            // Новая сессия
            currentSession = ChatSession(id: sessionId, title: String(userMessage.prefix(50)), modelName: config.selectedModel)
            currentSession?.addMessage(userMsg)
            if let ctx = modelContext {
                ctx.insert(currentSession!)
                try? ctx.save()
            }
        } else if let session = currentSession {
            // Добавление к существующей сессии
            session.addMessage(userMsg)
            try? modelContext?.save()
        }

        // Запускаем генерацию ответа
        await generateResponse(for: sessionId)
    }
    
    /// Остановить генерацию ответа
    /// - Примечание: Отменяет текущую задачу стриминга
    func stopGeneration() {
        streamingTask?.cancel()
        streamingTask = nil
        isGenerating = false

        // Обновляем флаг генерации у последнего сообщения
        if let lastMessage = messages.last, lastMessage.isAssistant {
            lastMessage.isGenerating = false
        }
    }
    
    /// Удалить сообщение
    /// - Parameter message: Сообщение для удаления
    /// Удаляет из массива и из SwiftData
    func deleteMessage(_ message: Message) {
        messages.removeAll { $0.id == message.id }
        modelContext?.delete(message)
        try? modelContext?.save()
    }
    
    /// Редактировать сообщение пользователя
    /// - Parameters:
    ///   - message: Редактируемое сообщение (должно быть от пользователя)
    ///   - newContent: Новый текст сообщения
    /// - Важно: Выполняется асинхронно
    /// - Примечание: Удаляет все сообщения после редактируемого и перегенерирует
    func editMessage(_ message: Message, newContent: String) async {
        // Разрешаем редактирование только сообщений пользователя
        guard message.isUser else { return }
        message.content = newContent

        // Удаляем все сообщения после текущего
        let laterMessages = messages.filter { $0.index > message.index }
        for msg in laterMessages {
            modelContext?.delete(msg)
        }
        messages = messages.filter { $0.index <= message.index }
        try? modelContext?.save()

        // Перегенерируем ответ
        await generateResponse(for: message.sessionId)
    }

    // MARK: - Приватные методы (Private Methods)

    /// Проверить авторизацию (private)
    /// Проверяет наличие токена в Keychain
    private func checkAuthentication() {
        if let token = authManager.getToken(), !token.isEmpty {
            isAuthenticated = true
            authError = nil
        } else {
            isAuthenticated = false
            authError = "Введите токен"
        }
    }
    
    /// Запустить мониторинг сети (private)
    /// Отслеживает изменения WiFi/Ethernet подключения
    private func startNetworkMonitoring() {
        // Настраиваем обработчик обновлений
        pathMonitor.pathUpdateHandler = { [weak self] path in
            Task { @MainActor in
                guard let self = self else { return }
                
                // Проверяем именно WiFi или Ethernet (не любой интерфейс)
                // Это предотвращает ложные срабатывания на VPN или мобильных данных
                let hasWifiOrEthernet = path.usesInterfaceType(.wifi) || path.usesInterfaceType(.wiredEthernet)
                self.isConnected = hasWifiOrEthernet && path.status == .satisfied

                // Если есть WiFi - проверяем сервер
                if hasWifiOrEthernet && path.status == .satisfied {
                    await self.checkServerConnection()
                } else {
                    self.isServerReachable = false
                }
            }
        }
        pathMonitor.start(queue: monitorQueue)
    }
    
    /// Сгенерировать ответ от AI (private)
    /// - Parameter sessionId: ID сессии для генерации
    /// - Важно: Основной метод обработки стриминга от LM Studio
    /// - Примечание: Обрабатывает tool calls, reasoning, обычный контент
    private func generateResponse(for sessionId: UUID) async {
        // Устанавливаем состояние генерации
        isGenerating = true
        isConnected = true
        errorMessage = nil
        toolCalls = []
        generationStartTime = Date()

        // Подготавливаем сообщения для API
        let apiMessages: [ChatMessage] = messages.map { ChatMessage(from: $0) }

        // Индекс для нового сообщения ассистента
        let assistantIndex = messages.count
        
        // Создаём пустое сообщение ассистента для стриминга
        let assistantMsg = Message.assistant(
            content: "",
            sessionId: sessionId,
            index: assistantIndex,
            modelName: config.selectedModel
        )
        messages.append(assistantMsg)

        do {
            // Переменные для накопления контента
            var fullContent = ""
            var reasoningContent = ""
            var currentToolCalls: [Int: ToolCall] = [:]

            // Стриминг ответов от LM Studio
            for try await chunk in await networkService.streamChat(
                messages: apiMessages,
                model: config.selectedModel,
                temperature: config.temperature,
                maxTokens: config.maxTokens
            ) {
                // Обрабатываем каждую выборку (choice) из ответа
                for choice in chunk.choices {
                    // Обрабатываем reasoning (цепочка мыслей модели)
                    if let reasoning = choice.delta.reasoningContent {
                        reasoningContent += reasoning
                        messages[messages.count - 1].reasoning = reasoningContent
                    }

                    // Обрабатываем обычный контент
                    if let content = choice.delta.content {
                        fullContent += content
                        messages[messages.count - 1].content = fullContent
                    }

                    // Обрабатываем tool calls
                    if let calls = choice.delta.toolCalls {
                        for call in calls {
                            if var existingCall = currentToolCalls[call.index] {
                                // Дополняем аргументы существующего tool call
                                if let args = call.function?.arguments {
                                    existingCall.arguments += args
                                }
                                currentToolCalls[call.index] = existingCall
                            } else if let name = call.function?.name, let args = call.function?.arguments {
                                // Новый tool call
                                let newCall = ToolCall(index: call.index, name: name, arguments: args)
                                currentToolCalls[call.index] = newCall
                            }
                        }
                        toolCalls = Array(currentToolCalls.values).sorted { $0.index < $1.index }
                    }

                    // Проверяем завершение генерации
                    if let reason = choice.finishReason {
                        // Обрабатываем tool calls если есть
                        if reason == "tool_calls" || reason == "stop" {
                            await handleToolCalls(Array(currentToolCalls.values), sessionId: sessionId)
                        }

                        // Рассчитываем статистику
                        let endTime = Date()
                        let duration = endTime.timeIntervalSince(generationStartTime ?? endTime)
                        let tokens = fullContent.count / 4  // Приблизительная оценка
                        currentStats = GenerationStats(
                            totalTokens: tokens,
                            tokensPerSecond: duration > 0 ? Double(tokens) / duration : 0,
                            generationTime: duration,
                            stopReason: reason
                        )

                        // Обновляем сообщение
                        messages[messages.count - 1].isGenerating = false
                        messages[messages.count - 1].tokensUsed = tokens
                        isGenerating = false
                    }
                }
            }
        } catch is CancellationError {
            // Обработка отмены пользователем
            messages[messages.count - 1].isGenerating = false
        } catch {
            // Обработка ошибок
            if let responseError = error as? NetworkError, case .unauthorized = responseError {
                // Ошибка авторизации
                isAuthenticated = false
                authError = "Токен неверный. Пожалуйста, обновите токен в Настройках."
            } else if let responseError = error as? NetworkError, case .networkError = responseError {
                // Ошибка сети
                isConnected = false
                errorMessage = "Нет соединения с сервером"
            } else if !(error is CancellationError) {
                // Другие ошибки
                errorMessage = "Ошибка: \(error.localizedDescription)"
            }
            messages[messages.count - 1].isGenerating = false
        }

        // Сохраняем в SwiftData
        try? modelContext?.save()
    }
    
    /// Обработать tool calls от AI (private)
    /// - Parameters:
    ///   - calls: Массив tool calls для выполнения
    ///   - sessionId: ID сессии
    /// - Важно: Выполняется асинхронно для каждого tool call
    /// - Примечание: Поддерживает встроенные инструменты (время, калькулятор)
    private func handleToolCalls(_ calls: [ToolCall], sessionId: UUID) async {
        // Обрабатываем каждый tool call
        for var call in calls {
            call.isExecuting = true
            let result: String

            // Выполняем соответствующий инструмент
            switch call.name {
            case "get_current_time":
                // Получение текущего времени
                let date = Date()
                let formatter = DateFormatter()
                if let tz = call.parsedArguments?["timezone"] as? String {
                    formatter.timeZone = TimeZone(identifier: tz)
                }
                formatter.dateFormat = "dd MMMM yyyy, HH:mm:ss"
                result = formatter.string(from: date)

            case "calculate":
                // Вычисление выражения
                if let expr = call.parsedArguments?["expression"] as? String {
                    // Удаляем потенциально опасные символы
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
                // Неизвестный инструмент
                result = "Неизвестный инструмент: \(call.name)"
            }

            // Обновляем состояние tool call
            call.result = result
            call.isExecuting = false

            // Обновляем в массиве
            if let idx = toolCalls.firstIndex(where: { $0.index == call.index }) {
                toolCalls[idx] = call
            }

            // Добавляем результат как сообщение
            let toolMessage = Message(content: result, role: "tool", index: messages.count, sessionId: sessionId)
            messages.append(toolMessage)
        }

        // Рекурсивно генерируем следующий ответ (если есть ещё tool calls)
        await generateResponse(for: sessionId)
    }
}

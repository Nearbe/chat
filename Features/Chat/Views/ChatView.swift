// MARK: - Связь с документацией: Pulse (Версия: 4.0.0). Статус: Синхронизировано.
import SwiftUI
import SwiftData
import PulseUI
import UIKit

// MARK: - Главный экран чата (Chat Screen)

/// - Документация: [Docs/Pulse/README.md](../../../Docs/Pulse/README.md) (инструкция по вызову консоли Pulse через жест)
/// Основной UI-компонент приложения.
/// Отвечает за отображение интерфейса чата, включая:
/// - Экран авторизации (3D щит для ввода токена)
/// - Пустое состояние (при отсутствии сообщений)
/// - Список сообщений с возможностью редактирования/удаления
/// - Поле ввода сообщения с кнопкой отправки
/// - Панель инструментов (история, выбор модели, статус подключения)
///
/// Использует MVVM паттерн через ChatViewModel.
/// Подключается к SwiftData для персистентности сообщений и сессий.
///
/// - Важно: Все сетевые операции выполняются асинхронно через ViewModel
/// - Примечание: Автоматическая прокрутка к последнему сообщению отключена временно
struct ChatView: View {

    // MARK: - Приватные свойства (Private Properties)

    @EnvironmentObject private var sessionManager: ChatSessionManager
    @EnvironmentObject private var chatService: ChatService
    @EnvironmentObject private var networkMonitor: NetworkMonitor

    /// ViewModel содержит всю бизнес-логику чата
    @StateObject private var viewModel = ChatViewModel()

    /// Контекст SwiftData для персистентности данных
    /// Получается из SwiftUI environment автоматически
    @Environment(\.modelContext) private var modelContext

    /// Флаг отображения экрана истории чатов
    /// Управляется через sheet модификатор
    @State private var showingHistory = false

    /// Флаг отображения экрана выбора модели
    /// Управляется через sheet модификатор
    @State private var showingModelPicker = false

    /// Флаг отображения консоли Pulse
    @State private var showingPulse = false

    /// Флаг отображения ShareSheet для экспорта
    @State private var showingExport = false
    @State private var exportText = ""

    /// Прокси-объект для программной прокрутки ScrollView
    /// Используется для автоматической прокрутки к новым сообщениям
    /// Примечание: В данный момент не используется (автоскролл отключён)
    @State private var scrollProxy: ScrollViewProxy?

    // MARK: - Тело представления (Body)

    var body: some View {
        // NavigationStack обеспечивает навигационную структуру iOS
        NavigationStack {
            // Основной контейнер - вертикальный стек без отступов между элементами
            VStack(spacing: 0) {
                // Логика отображения контента на основе состояния авторизации:

                // 1. Если не авторизован - показываем экран ввода токена
                if !viewModel.isAuthenticated {
                    tokenRequiredView

                // 2. Если авторизован, но нет сообщений - показываем пустое состояние
                } else if viewModel.messages.isEmpty {
                    emptyStateView

                // 3. Если есть сообщения - показываем список сообщений
                } else {
                    ChatMessagesView(
                        messages: viewModel.messages,
                        toolCalls: viewModel.toolCalls,
                        showStats: viewModel.config.showStats,
                        isGenerating: viewModel.isGenerating,
                        currentStats: viewModel.currentStats,
                        onDeleteMessage: { viewModel.deleteMessage($0) },
                        onEditMessage: { message, newContent in
                            // Используем Task для вызова async функции в sync контексте
                            Task {
                                await viewModel.editMessage(message, newContent: newContent)
                            }
                        }
                    )
                }

                // Область ввода сообщения - всегда отображается внизу
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
            // Делаем всю область тапляблой для закрытия клавиатуры
            .contentShape(Rectangle())
            .onTapGesture {
                // При тапе на пустое пространство - закрываем клавиатуру
                // Получаем доступное окно через UIApplication
                UIApplication.shared.connectedScenes
                    .compactMap { $0 as? UIWindowScene }  // Фильтруем только WindowScene
                    .flatMap { $0.windows }              // Получаем все окна сцены
                    .first(where: { $0.isKeyWindow })?   // Находим активное окно
                    .endEditing(true)                    // Завершаем редактирование
            }
            // Выполняется при появлении View на экране
            .onAppear {
                viewModel.setup(
                    sessionManager: sessionManager,
                    chatService: chatService,
                    networkMonitor: networkMonitor
                )
                // Обновляем статус авторизации из Keychain
                viewModel.refreshAuthentication()
                // Асинхронно проверяем подключение к серверу
                Task {
                    await viewModel.checkServerConnection()
                }
            }
            // Настройка навигационной панели
            .navigationBarTitleDisplayMode(.inline)  // Компактный заголовок

            // MARK: - Панель инструментов (Toolbar)
            .toolbar {
                // Заголовок с секретным двойным тапом для открытия Pulse
                ToolbarItem(placement: .principal) {
                    Text("Chat")
                        .font(AppTypography.headline)
                        .onTapGesture(count: 2) {
                            showingPulse = true
                        }
                }

                // Кнопка истории чатов (слева)
                ToolbarItem(placement: .topBarLeading) {
                    Button {
                        showingHistory = true
                    } label: {
                        Image(systemName: "list.bullet")
                    }
                    .accessibilityLabel("История чатов")
                }

                // Кнопка выбора модели (по центру)
                ToolbarItem(placement: .principal) {
                    Button {
                        showingModelPicker = true
                    } label: {
                        HStack(spacing: 4) {
                            // Показываем название выбранной модели или плейсхолдер
                            Text(viewModel.config.selectedModel.isEmpty ? "Выбрать модель" : viewModel.config.selectedModel)
                                .lineLimit(1)
                            Image(systemName: "chevron.down")
                                .font(AppTypography.caption)
                        }
                    }
                    .accessibilityLabel("Выбор модели")
                }

                // Индикатор подключения к серверу (слева от центра)
                ToolbarItem(placement: .navigationBarLeading) {
                    // Зелёный - сервер доступен, красный - недоступен
                    Circle()
                        .fill(viewModel.isServerReachable ? Color.green : Color.red)
                        .frame(width: 10, height: 10)
                }

                // Кнопка включения/выключения MCP инструментов (справа)
                ToolbarItem(placement: .navigationBarTrailing) {
                    HStack {
                        Button {
                            if let session = viewModel.currentSession {
                                exportText = session.toMarkdown()
                                showingExport = true
                            }
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                        }
                        .disabled(viewModel.currentSession == nil)

                        Button {
                            // Переключаем состояние MCP инструментов
                            viewModel.config.mcpToolsEnabled.toggle()
                        } label: {
                            Image(systemName: viewModel.config.mcpToolsEnabled ? "wrench.and.screwdriver.fill" : "wrench.and.screwdriver")
                                // Акцентный цвет когда включено, серый когда выключено
                                .foregroundStyle(viewModel.config.mcpToolsEnabled ? ThemeManager.shared.accentColor : .secondary)
                        }
                    }
                }
            }

            // MARK: - Модальные окна (Sheets)

            // Экран истории чатов
            .sheet(isPresented: $showingHistory) {
                HistoryView(
                    onSelectSession: { session in
                        // Загружаем выбранную сессию и закрываем лист
                        viewModel.setSession(session)
                        showingHistory = false
                    },
                    onDeleteSession: { session in
                        // Удаляем сессию
                        viewModel.deleteSession(session)
                    }
                )
            }

            // Экран выбора модели
            .sheet(isPresented: $showingModelPicker) {
                ModelPicker(
                    models: viewModel.availableModels,
                    selectedModel: Binding(
                        get: { viewModel.config.selectedModel },
                        set: { viewModel.config.selectedModel = $0 }
                    )
                )
            }

            // Консоль Pulse для отладки
            .sheet(isPresented: $showingPulse) {
                ConsoleView(store: .shared)
            }

            // Экспорт в Markdown
            .sheet(isPresented: $showingExport) {
                ShareSheet(items: [exportText])
                    .presentationDetents([PresentationDetent.medium, PresentationDetent.large])
            }

            // MARK: - Наблюдение за изменениями (Observers)

            // Следим за ошибками от ViewModel
            // Примечание: Алерты не показываются - ошибки обрабатываются внутри
            .onChange(of: viewModel.errorMessage) {
                // Ошибки обрабатываются без показа алерта
                // viewModel.errorMessage очищается автоматически
            }

            // Выполняем при появлении - загружаем контекст и модели
            .task {
                // Устанавливаем контекст SwiftData в ViewModel
                viewModel.setModelContext(modelContext)
                // Загружаем список доступных моделей с сервера
                await viewModel.loadModels()
            }

            // Следим за изменением настроек UserDefaults
            // Это позволяет реагировать на изменения в системных настройках
            .onReceive(NotificationCenter.default.publisher(for: UserDefaults.didChangeNotification)) { _ in
                // Обновляем статус авторизации при изменении настроек
                viewModel.refreshAuthentication()
            }
        }
    }

    // MARK: - Приватные подпредставления (Private Subviews)

    /// Экран требования авторизации
    /// Показывает интерактивный 3D щит для ввода токена
    /// - Примечание: Токен должен начинаться с префикса "sk-lm"
    private var tokenRequiredView: some View {
        VStack(spacing: 20) {
            // Интерактивный 3D щит
            ShieldView { token in
                // При получении токена сохраняем его через ViewModel
                viewModel.saveToken(token)
            }
            .frame(width: 280, height: 280)
            .accessibilityIdentifier("shield_view")

            Text("Требуется токен")
                .font(AppTypography.headline)
                .accessibilityAddTraits(.isHeader)

            Text("Скопируйте токен и нажмите на щит")
                .font(AppTypography.callout)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .accessibilityLabel("Инструкция: Скопируйте токен и нажмите на щит для ввода")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    /// Экран пустого состояния
    /// Показывается когда нет сообщений в чате
    /// Призывает пользователя начать разговор
    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "bubble.left.and.bubble.right")
                .font(AppTypography.iconLarge)
                .foregroundStyle(.secondary)

            Text("Начните разговор")
                .font(AppTypography.headline)
                .accessibilityIdentifier("empty_state_text")
                .accessibilityAddTraits(.isHeader)

            Text("Отправьте сообщение, чтобы получить ответ от AI")
                .font(AppTypography.callout)
                .foregroundStyle(.secondary)
                .accessibilityLabel("Описание: Отправьте сообщение, чтобы получить ответ от искусственного интеллекта")
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

/// СТРУКТУРА ДЛЯ ПОКАЗА SHARE SHEET (EXPORT)
struct ShareSheet: UIViewControllerRepresentable {
    let items: [Any]

    func makeUIViewController(context: Context) -> UIActivityViewController {
        UIActivityViewController(activityItems: items, applicationActivities: nil)
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: Context) {}
}

// MARK: - Превью

/// Превью компонента для Xcode
/// Позволяет видеть внешний вид в редакторе
/// - Важно: Требует настроенного modelContainer для SwiftData
#Preview {
    ChatView()
        .modelContainer(PersistenceController.shared.container)
}

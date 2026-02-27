# 🧭 Навигация и экраны приложения Chat

> **Версия:** 2.0  
> **Дата обновления:** 2026-02-25  
> **Архитектурный паттерн:** SwiftUI NavigationStack + Router Pattern

---

## 📐 Общая архитектура навигации

```swift
// Главный контейнер навигации
struct ContentView: View {
    @StateObject private var navigationManager = NavigationManager()
    
    var body: some View {
        NavigationStack(path: $navigationManager.navigationPath) {
            TabViewContainer()
                .environmentObject(navigationManager)
        }
        .navigationDestination(for: Route.self) { route in
            buildScreen(for: route)
        }
    }
}
```

### Основные компоненты навигации:

1. **NavigationManager** — центральный менеджер состояния навигации
2. **Route enum** — типобезопасные пути навигации
3. **TabViewContainer** — нижняя таб-бар навигация
4. **Screen builders** — фабрики для создания экранов

---

## 🗺️ Структура маршрутов (Routes)

### Основной enum Route:

```swift
enum Route: Hashable {
    // --- Главная таб-навигация ---
    case chatsList
    case newChat
    case settings
    case profile
    
    // --- Экраны чатов ---
    case chatDetail(chatId: String)
    case messageDetail(messageId: String, chatId: String)
    case editMessage(messageId: String)
    
    // --- Настройки ---
    case settingsGeneral
    case settingsAIProviders
    case settingsDataStorage
    case settingsNotifications
    case settingsPrivacySecurity
    case settingsAbout
    
    // --- Профиль пользователя ---
    case profileEdit
    case accountSettings
    case subscriptionPlan
    
    // --- AI провайдеры ---
    case aiProviderLMStudio
    case aiProviderOllama
    case aiProviderOpenAI
    case aiModelSelection(provider: ProviderType)
    case apiConfiguration(provider: ProviderType)
    
    // --- Данные и хранилище ---
    case dataBackupRestore
    case dataExportImport
    case chatHistoryFilter
    
    // --- Уведомления ---
    case notificationSettings
    case pushNotificationTest
    
    // --- Безопасность ---
    case biometricAuthSetup
    case passcodeSetup
    case privacyPolicy
    case termsOfService
    
    // --- О приложении ---
    case aboutApp
    case versionHistory
    case credits
    
    // --- Глубокие ссылки (Deep Links) ---
    case deepLinkChat(chatId: String)
    case deepLinkMessage(messageId: String)
}
```

---

## 🏗️ NavigationManager — Центральный менеджер навигации

```swift
@MainActor
class NavigationManager: ObservableObject {
    // MARK: - Published Properties
    
    @Published var navigationPath = NavigationPath()
    @Published var currentRoute: Route?
    
    // MARK: - Computed Properties
    
    var canGoBack: Bool {
        !navigationPath.paths.isEmpty
    }
    
    // MARK: - Public Methods
    
    /// Push route to navigation stack
    func push(_ route: Route) {
        DispatchQueue.main.async {
            self.navigationPath.append(route)
            self.currentRoute = route
        }
    }
    
    /// Pop current route from stack
    func pop() {
        DispatchQueue.main.async {
            if !self.navigationPath.paths.isEmpty {
                _ = self.navigationPath.paths.popLast()
            }
        }
    }
    
    /// Pop all routes and return to root
    func popToRoot() {
        DispatchQueue.main.async {
            self.navigationPath = NavigationPath()
            self.currentRoute = nil
        }
    }
    
    /// Navigate to specific route with parameters
    func navigate(to route: Route) {
        switch route {
        case .chatDetail(let chatId):
            push(.chatDetail(chatId: chatId))
        case .settingsAIProviders:
            push(.settingsAIProviders)
        // ... другие кейсы
        }
    }
}
```

---

## 🎨 TabViewContainer — Нижняя таб-бар навигация

```swift
struct TabViewContainer: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        TabView(selection: $currentTab) {
            // --- Chats Tab (Главная) ---
            ChatsListView()
                .tabItem {
                    Label("Чаты", systemImage: "bubble.left.bubble.right")
                }
                .tag(Tab.chats)
            
            // --- New Chat ---
            NewChatView()
                .tabItem {
                    Label("Новый чат", systemImage: "pencil.square")
                }
                .tag(Tab.newChat)
            
            // --- Settings ---
            SettingsView()
                .environmentObject(navigationManager)
                .tabItem {
                    Label("Настройки", systemImage: "gearshape.fill")
                }
                .tag(Tab.settings)
            
            // --- Profile ---
            ProfileView()
                .tabItem {
                    Label("Профиль", systemImage: "person.circle.fill")
                }
                .tag(Tab.profile)
        }
    }
}

enum Tab: String, CaseIterable {
    case chats = "chats"
    case newChat = "new-chat"
    case settings = "settings"
    case profile = "profile"
}
```

---

## 🧩 Экраны и их навигация

### 1. ChatsListView — Список чатов

```swift
struct ChatsListView: View {
    @StateObject private var viewModel = ChatsViewModel()
    
    var body: some View {
        NavigationStack {
            List(viewModel.chats, id: \.id) { chat in
                ChatRowView(chat: chat)
                    .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                        Button(role: .destructive) {
                            viewModel.deleteChat(chat.id)
                        } label: {
                            Label("Удалить", systemImage: "trash")
                        }
                    }
                    .navigationDestination(for: Route.self) { route in
                        buildScreen(for: route)
                    }
            }
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button(action: viewModel.showNewChat) {
                        Image(systemName: "pencil.circle")
                    }
                }
            }
        }
    }
}
```

### 2. ChatDetailView — Детали чата

```swift
struct ChatDetailView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    @StateObject private var viewModel = ChatDetailViewModel()
    
    var body: some View {
        NavigationStack {
            VStack {
                MessagesListView(messages: viewModel.messages)
                    .navigationDestination(for: Route.self) { route in
                        buildMessageScreen(for: route)
                    }
                
                InputBarView(
                    text: $viewModel.inputText,
                    isSending: viewModel.isSending,
                    onSend: viewModel.sendMessage
                )
            }
            .navigationTitle(viewModel.chat.title)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Menu {
                        Button(action: viewModel.shareChat) {
                            Label("Поделиться", systemImage: "square.and.arrow.up")
                        }
                        
                        Button(action: viewModel.exportHistory) {
                            Label("Экспорт", systemImage: "arrow.down.square")
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
            }
        }
    }
}
```

### 3. SettingsView — Настройки приложения

```swift
struct SettingsView: View {
    @EnvironmentObject var navigationManager: NavigationManager
    
    var body: some View {
        Form {
            // --- General Section ---
            Section("Общие") {
                NavigationLink(value: Route.settingsGeneral) {
                    Label("Основные", systemImage: "gearshape")
                }
                
                NavigationLink(value: Route.aiProviderLMStudio) {
                    Label("LM Studio", systemImage: "brain.head.profile")
                }
                
                NavigationLink(value: Route.aiProviderOllama) {
                    Label("Ollama", systemImage: "cpu")
                }
            }
            
            // --- Data Section ---
            Section("Данные и хранилище") {
                NavigationLink(value: Route.dataBackupRestore) {
                    Label("Резервное копирование", systemImage: "cloud.arrow.up")
                }
                
                NavigationLink(value: Route.dataExportImport) {
                    Label("Экспорт/Импорт", systemImage: "square.and.arrow.down")
                }
            }
            
            // --- Notifications Section ---
            Section("Уведомления") {
                NavigationLink(value: Route.notificationSettings) {
                    Label("Настройки уведомлений", systemImage: "bell.badge")
                }
            }
            
            // --- Privacy & Security Section ---
            Section("Конфиденциальность и безопасность") {
                NavigationLink(value: Route.biometricAuthSetup) {
                    Label("Биометрическая аутентификация", systemImage: "faceid")
                }
                
                NavigationLink(value: Route.passcodeSetup) {
                    Label("Пароль приложения", systemImage: "lock.shield")
                }
            }
        }
    }
}
```

---

## 🧭 Глубокие ссылки (Deep Links)

### Universal Links Configuration

```swift
// Info.plist
<key>AssociatedDomains</key>
<array>
    <string>applinks:chat.nearbe.app</string>
</array>
```

### Deep Link Router

```swift
class DeepLinkRouter {
    static let shared = DeepLinkRouter()
    
    private init() {}
    
    /// Handle incoming URL from Universal Links or URL Schemes
    func handle(_ url: URL, in window: UIWindow) -> Bool {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true),
              var pathComponents = components.pathComponents.dropFirst().first else {
            return false
        }
        
        switch pathComponents {
        case "chat":
            handleChatDeepLink(pathComponents[1...], in: window)
        case "message":
            handleMessageDeepLink(pathComponents[1...], in: window)
        default:
            return false
        }
    }
    
    private func handleChatDeepLink(_ components: ArraySlice<String>, in window: UIWindow) {
        guard let chatId = components.first else { return }
        
        // Navigate to chat detail screen
        if let rootVC = window.rootViewController,
           let navManager = rootVC.children.first(where: { $0 is NavigationManager }) as? NavigationManager {
            navManager.push(.chatDetail(chatId: chatId))
        }
    }
}
```

---

## 🎯 Паттерны навигации

### 1. Router Pattern — Централизованная логика маршрутизации

```swift
class NavigationRouter {
    static let shared = NavigationRouter()
    
    private init() {}
    
    /// Navigate to specific screen with parameters
    func navigate(to route: Route, from context: NavigationContext) {
        switch route {
        case .chatDetail(let chatId):
            showChatDetail(chatId: chatId, from: context)
        case .settingsAIProviders:
            showSettingsScreen(.aiProviders, from: context)
        // ... другие кейсы
        }
    }
}
```

### 2. Coordinator Pattern — Локальная навигация для экранов

```swift
class ChatDetailCoordinator: NSObject {
    weak var navigationController: UINavigationController?
    
    func presentChatDetail(chatId: String) {
        let viewModel = ChatDetailViewModel()
        let viewController = ChatDetailView(viewModel: viewModel)
        
        navigationController?.pushViewController(viewController, animated: true)
    }
}
```

---

## 📊 Статус навигации

### Реализованные экраны:

- ✅ ChatsListView — список чатов с фильтрацией и поиском
- ✅ ChatDetailView — детальный просмотр чата с сообщениями
- ✅ SettingsView — настройки приложения по секциям
- ✅ ProfileView — профиль пользователя
- ✅ NewChatView — создание нового чата

### В процессе реализации:

- ⏳ AI Provider Configuration (LM Studio, Ollama, OpenAI)
- ⏳ Data Backup & Restore screens
- ⏳ Notification Settings
- ⏳ Privacy & Security settings

---

## 🔗 Связанные модули

- **[01_project_overview.md](./01_project_overview.md)** — обзор проекта
- **[02_architecture.md](./02_architecture.md)** — MVVM архитектура
- **[04_data_models.md](./04_data_models.md)** — модели данных чатов и сообщений
- **[05_api_integration.md](./05_api_integration.md)** — API интеграции провайдеров AI

---

> **Автор:** Client Architect (Team Nearbe)  
> **Версия:** 2.0 (2026-02-25)

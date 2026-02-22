import SwiftUI

/// Конфигурация приложения, хранимая в UserDefaults
@MainActor
final class AppConfig: ObservableObject {
    /// API Token для авторизации
    @AppStorage("api_token") var apiToken: String = ""

    /// Базовый URL LM Studio API
    @AppStorage("lm_base_url") var baseURL: String = "http://192.168.1.91:64721"

    /// Таймаут запроса в секундах
    @AppStorage("lm_timeout") var timeout: Double = 30.0

    /// Текущая выбранная модель
    @AppStorage("selected_model") var selectedModel: String = ""

    /// Включены ли MCP Tools (серверные инструменты)
    @AppStorage("mcp_tools_enabled") var mcpToolsEnabled: Bool = false

    /// Температура генерации (0.0 - 2.0)
    @AppStorage("temperature") var temperature: Double = 0.7

    /// Максимальное количество токенов
    @AppStorage("max_tokens") var maxTokens: Int = 4096

    /// Показывать статистику генерации
    @AppStorage("show_stats") var showStats: Bool = true

    /// Автоматическая прокрутка к новым сообщениям
    @AppStorage("auto_scroll") var autoScroll: Bool = true

    ///Singleton
    static let shared = AppConfig()

    private init() {}

    /// Полный URL для чата (LM Studio v1 API)
    var chatURL: URL? {
        URL(string: "\(baseURL)/api/v1/chat")
    }

    /// Полный URL для списка моделей (LM Studio v1 API)
    var modelsURL: URL? {
        URL(string: "\(baseURL)/api/v1/models")
    }

    /// Сбросить настройки к значениям по умолчанию
    func reset() {
        baseURL = "http://192.168.1.91:64721"
        timeout = 30.0
        mcpToolsEnabled = false
        temperature = 0.7
        maxTokens = 4096
        showStats = true
        autoScroll = true
    }
}

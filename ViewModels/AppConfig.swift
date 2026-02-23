import SwiftUI

// MARK: - Конфигурация приложения (App Configuration)

/// Управление настройками приложения через UserDefaults.
/// Использует @AppStorage для автоматической синхронизации с UserDefaults.
/// Доступна как синглтон через AppConfig.shared
///
/// Хранимые настройки:
/// - API подключение (URL, токен, таймаут)
/// - Параметры генерации (модель, температура, лимиты)
/// - UI настройки (статистика, автоскролл)
///
/// - Важно: Все свойства синхронизируются автоматически
/// - Примечание: Изменения в одном месте приложения отражаются везде
@MainActor
final class AppConfig: ObservableObject {
    
    // MARK: - Свойства подключения (Connection Properties)
    
    /// API Token для авторизации в LM Studio
    /// Сохраняется в Keychain через DeviceAuthManager, а не здесь
    /// Примечание: Это резервное хранилище, основной токен - в Keychain
    @AppStorage("api_token") var apiToken: String = ""

    /// Базовый URL LM Studio API
    /// По умолчанию: http://192.168.1.91:64721 (локальный IP)
    /// Формат: http://<ip>:<port>
    @AppStorage("lm_base_url") var baseURL: String = "http://192.168.1.91:64721"

    /// Таймаут сетевого запроса в секундах
    /// По умолчанию: 30 секунд
    /// Увеличьте при работе с большими моделями
    @AppStorage("lm_timeout") var timeout: Double = 30.0

    // MARK: - Свойства модели (Model Properties)
    
    /// Текущая выбранная модель для генерации
    /// ID модели из списка доступных от LM Studio
    /// Пустая строка означает "модель не выбрана"
    @AppStorage("selected_model") var selectedModel: String = ""

    /// Включены ли MCP Tools (Server-Side Tools)
    /// true - LM Studio использует свои инструменты
    /// false - инструменты отключены
    @AppStorage("mcp_tools_enabled") var mcpToolsEnabled: Bool = false

    // MARK: - Свойства генерации (Generation Properties)
    
    /// Температура генерации (креативность ответа)
    /// Диапазон: 0.0 - 2.0
    /// - 0.0-0.3: Детерминированные, точные ответы
    /// - 0.4-0.7: Баланс (рекомендуется)
    /// - 0.8-2.0: Креативные, но могут быть бессмысленными
    @AppStorage("temperature") var temperature: Double = 0.7

    /// Максимальное количество токенов в ответе
    /// Ограничивает длину одного ответа модели
    /// Примечание: Реальное ограничение зависит от модели и контекста
    @AppStorage("max_tokens") var maxTokens: Int = 4096

    // MARK: - UI Свойства (UI Properties)
    
    /// Показывать ли статистику генерации
    /// Отображает: количество токенов, скорость, время
    @AppStorage("show_stats") var showStats: Bool = true

    /// Автоматическая прокрутка к последнему сообщению
    /// Включает автоскролл при получении нового сообщения от AI
    /// Примечация: Временно отключено из-за рефакторинга
    @AppStorage("auto_scroll") var autoScroll: Bool = true

    // MARK: - Синглтон (Singleton)
    
    /// Единственный экземпляр конфигурации
    /// Используйте AppConfig.shared для доступа к настройкам
    @MainActor static let shared = AppConfig()

    /// Приватный конструктор
    /// Предотвращает создание нескольких экземпляров
    private init() {}

    // MARK: - Вычисляемые свойства (Computed Properties)
    
    /// Полный URL для чата (LM Studio v1 API)
    /// Используется для отправки сообщений
    /// - Returns: URL для эндпоинта /api/v1/chat
    var chatURL: URL? {
        URL(string: "\(baseURL)/api/v1/chat")
    }

    /// Полный URL для списка моделей (LM Studio v1 API)
    /// Используется для загрузки доступных моделей
    /// - Returns: URL для эндпоинта /api/v1/models
    var modelsURL: URL? {
        URL(string: "\(baseURL)/api/v1/models")
    }

    // MARK: - Публичные методы (Public Methods)
    
    /// Сбросить все настройки к значениям по умолчанию
    /// Используется для сброса конфигурации при проблемах
    /// Примечание: Не сбрашивает выбранную модель и токен
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

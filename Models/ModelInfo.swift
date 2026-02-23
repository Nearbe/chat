// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation

// MARK: - Информация о модели (Model Info)

/// Структура представляющая информацию о доступной модели от LM Studio.
/// Загружается через API /api/v1/models и используется для выбора модели.
///
/// Соответствует LM Studio v1 API формату.
/// Поля маппится через CodingKeys для совместимости с API.
///
/// - Важно: id используется как ключ для API запросов
/// - Примечание: displayName приоритетнее для отображения в UI
struct ModelInfo: Codable, Identifiable, Hashable {

    // MARK: - Основные свойства (Main Properties)

    /// Уникальный идентификатор модели
    /// Используется для API запросов (поле "key" в API)
    let id: String

    /// Тип модели (например, "language_model")
    let type: String?

    /// Издатель/автор модели
    /// Например: "Meta", "Google", "Anthropic"
    let publisher: String?

    /// Отображаемое имя модели
    /// Приоритетнее чем id для показа в UI
    let displayName: String?

    /// Архитектура модели
    /// Например: "Llama", "Mistral", "Gemma"
    let architecture: String?

    /// Уровень квантования
    /// Определяет размер и качество модели
    let quantization: ModelQuantization?

    /// Размер модели в байтах
    /// Используется для оценки места на диске
    let sizeBytes: Int64?

    /// Строковое представление параметров
    /// Например: "7B", "70B", "405B"
    let paramsString: String?

    /// Максимальная длина контекста (в токенах)
    /// Определяет сколько текста модель может обработать
    let maxContextLength: Int?

    /// Формат модели
    /// Например: "gguf", "onnx", "pytorch"
    let format: String?

    /// Возможности модели
    /// Включает поддержку function calling, tools и т.д.
    let capabilities: ModelCapabilities?

    /// Описание модели
    /// Текстовое описание от издателя
    let description: String?

    // MARK: - Coding Keys (API маппинг)

    /// Маппинг JSON ключей к свойствам
    /// LM Studio использует "key" вместо "id"
    enum CodingKeys: String, CodingKey {
        case id = "key"
        case type
        case publisher
        case displayName = "display_name"
        case architecture
        case quantization
        case sizeBytes = "size_bytes"
        case paramsString = "params_string"
        case maxContextLength = "max_context_length"
        case format
        case capabilities
        case description
    }

    // MARK: - Конструкторы (Initializers)

    /// Удобный конструктор для превью и тестов
    /// - Parameters:
    ///   - id: ID модели
    ///   - displayName: Отображаемое имя (опционально)
    init(id: String, displayName: String? = nil) {
        self.id = id
        self.type = nil
        self.publisher = nil
        self.displayName = displayName
        self.architecture = nil
        self.quantization = nil
        self.sizeBytes = nil
        self.paramsString = nil
        self.maxContextLength = nil
        self.format = nil
        self.capabilities = nil
        self.description = nil
    }

    // MARK: - Вычисляемые свойства (Computed Properties)

    /// ID модели для API запросов
    /// Алиас для id - используется для совместимости
    var modelId: String {
        id
    }

    /// Отображаемое имя модели
    /// Использует displayName если доступно,
    /// иначе очищает id от префиксов (lmstudio-community/, ollama/)
    var name: String {
        displayName ?? id.replacingOccurrences(of: "lmstudio-community/", with: "")
            .replacingOccurrences(of: "ollama/", with: "")
    }
}

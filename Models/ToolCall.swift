// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation

// MARK: - Вызов инструмента (Tool Call)

/// Структура представляющая вызов инструмента (function calling) от AI модели.
/// Используется для отображения в UI и обработки результатов.
///
/// Жизненный цикл:
/// 1. Создаётся при получении tool_calls от модели
/// 2. isExecuting = true - идёт выполнение
/// 3. Заполняется result или error
/// 4. isExecuting = false - выполнение завершено
///
/// Поддерживаемые инструменты:
/// - get_current_time - получение текущего времени
/// - calculate - математические вычисления
///
/// - Важно: parsedArguments парсит JSON строку в словарь
/// - Примечание: order сохраняет порядок tool_calls от модели
struct ToolCall: Identifiable, Hashable {

    // MARK: - Свойства (Properties)

    /// Уникальный идентификатор
    /// Автогенерируется при создании
    let id: UUID

    /// Порядковый номер tool_call в ответе модели
    /// Соответствует индексу из API
    let index: Int

    /// Имя вызываемой функции
    /// Должно соответствовать ToolDefinition.name
    let name: String

    /// Аргументы в формате JSON строки
    /// Могут поступать частями при стриминге
    var arguments: String

    /// Результат выполнения инструмента
    /// Заполняется после выполнения
    /// nil пока инструмент выполняется
    var result: String?

    /// Флаг выполняется ли инструмент сейчас
    /// true - ожидание результата
    /// false - выполнено (успешно или с ошибкой)
    var isExecuting: Bool

    /// Сообщение об ошибке при выполнении
    /// nil при успешном выполнении
    var error: String?

    // MARK: - Инициализация (Initialization)

    /// Основной конструктор
    /// - Parameters:
    ///   - id: UUID (по умолчанию новый)
    ///   - index: Порядковый номер
    ///   - name: Имя функции
    ///   - arguments: JSON аргументы (по умолчанию пустая строка)
    ///   - result: Результат (по умолчанию nil)
    ///   - isExecuting: Флаг выполнения (по умолчанию true)
    ///   - error: Ошибка (по умолчанию nil)
    init(
        id: UUID = UUID(),
        index: Int,
        name: String,
        arguments: String = "",
        result: String? = nil,
        isExecuting: Bool = true,
        error: String? = nil
    ) {
        self.id = id
        self.index = index
        self.name = name
        self.arguments = arguments
        self.result = result
        self.isExecuting = isExecuting
        self.error = error
    }

    // MARK: - Вычисляемые свойства (Computed Properties)

    /// Парсинг аргументов из JSON строки
    /// - Returns: Словарь аргументов или nil при ошибке парсинга
    /// Используется для доступа к конкретным аргументам
    var parsedArguments: [String: Any]? {
        guard let data = arguments.data(using: .utf8) else { return nil }
        return try? JSONSerialization.jsonObject(with: data) as? [String: Any]
    }

    /// Успешно ли выполнен инструмент
    /// - Returns: true если есть результат и нет ошибки
    var isSuccessful: Bool {
        result != nil && error == nil
    }
}

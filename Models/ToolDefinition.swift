// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation

// MARK: - Определение инструмента (Tool Definition)

/// Структура для определения инструмента (function calling) в формате OpenAI.
/// Отправляется в API при запросе для указания доступных инструментов.
///
/// Используется в поле "tools" при отправке сообщений.
/// Модель может вызвать функцию если определение доступно.
///
/// Формат соответствует OpenAI Tools API:
/// ```json
/// {
///   "type": "function",
///   "function": {
///     "name": "get_current_time",
///     "description": "Получить текущее время",
///     "parameters": { ... }
///   }
/// }
/// ```
///
/// - Важно: type всегда "function"
/// - Примечание: id вычисляется из имени функции
struct ToolDefinition: Codable, Identifiable, Hashable {

    // MARK: - Свойства (Properties)

    /// Тип инструмента
    /// Всегда "function" для function calling
    let type: String

    /// Определение функции
    /// Содержит имя, описание и параметры
    let function: FunctionDefinition

    /// ID определения
    /// Использует имя функции как идентификатор
    var id: String { function.name }
}

/// Определение функции внутри инструмента
/// Содержит полную информацию о доступной функции
struct FunctionDefinition: Codable, Hashable {

    // MARK: - Свойства (Properties)

    /// Уникальное имя функции
    /// Используется для идентификации при вызове
    let name: String

    /// Описание функции
    /// Показывается модели для понимания назначения
    /// Влияет на решение модели когда вызывать функцию
    let description: String

    /// Схема параметров функции
    /// Формат JSON Schema
    /// Определяет какие аргументы функция принимает
    let parameters: ToolParameters?
}

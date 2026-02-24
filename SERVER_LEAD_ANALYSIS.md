# SERVER_LEAD_ANALYSIS.md

## Анализ серверной части iOS-проекта Chat

**Дата:** 24 февраля 2026  
**Аналитик:** Server Lead  
**Версия проекта:** 1.0.0  
**Статус:** Синхронизировано

---

## Содержание

1. [Обзор архитектуры](#1-обзор-архитектуры)
2. [LM Studio API интеграция](#2-lm-studio-api-интеграция)
3. [NetworkService и HTTPClient архитектура](#3-networkservice-и-httpclient-архитектура)
4. [SSE парсинг и стриминг](#4-sse-парсинг-и-стриминг)
5. [Аутентификация и безопасность](#5-аутентификация-и-безопасность)
6. [Обработка ошибок](#6-обработка-ошибок)
7. [Сервисы (ChatService, ChatStreamService, ChatSessionManager)](#7-сервисы-chatservice-chatstreamservice-chatsessionmanager)
8. [Выводы и рекомендации](#8-выводы-и-рекомендации)

---

## 1. Обзор архитектуры

### Директории и компоненты

```
Services/
├── Auth/                    # Аутентификация и безопасность
│   ├── DeviceAuthManager.swift
│   ├── DeviceConfiguration.swift
│   ├── DeviceIdentity.swift
│   └── KeychainHelper.swift
├── Chat/                    # Бизнес-логика чата
│   ├── ChatService.swift
│   ├── ChatStreamService.swift
│   └── ChatSessionManager.swift
├── Errors/                  # Типы ошибок
│   └── NetworkError.swift
└── Network/                 # Сетевой слой
    ├── AuthorizationProvider.swift
    ├── HTTPClient.swift
    ├── NetworkMonitor.swift
    ├── NetworkService.swift
    └── SSEParser.swift

Models/LMStudio/             # API модели LM Studio
├── LMChatRequest.swift
├── LMChatResponse.swift
├── LMSEvent.swift
├── LMDownloadResponse.swift
├── LMModelLoadRequest.swift
└── ... (другие модели)
```

### Ключевые особенности

- **Базовая URL:** `http://192.168.1.91:64721` (локальный IP)
- **API Version:** v1 (LM Studio REST API)
- **Протокол стриминга:** Server-Sent Events (SSE)
- **Главный актор:** `@MainActor` для UI-связанных сервисов

---

## 2. LM Studio API интеграция

### Поддерживаемые эндпоинты

| Эндпоинт | Метод | Описание |
|----------|-------|----------|
| `/api/v1/models` | GET | Получить список доступных моделей |
| `/api/v1/models/load` | POST | Загрузить модель в память |
| `/api/v1/models/unload` | POST | Выгрузить модель из памяти |
| `/api/v1/models/download` | POST | Скачать модель из репозитория |
| `/api/v1/models/download/{jobId}` | GET | Получить статус скачивания |
| `/api/v1/chat` | POST | Чат-комплишен (стриминг) |

### Модели запросов

#### LMChatRequest
```swift
struct LMChatRequest: Codable {
    let model: String           // ID модели
    let input: LMInput          // Сообщения
    let systemPrompt: String?   // Системная инструкция
    let stream: Bool            // SSE стриминг
    let temperature: Double?    // Креативность (0.0-2.0)
    let maxOutputTokens: Int?   // Лимит токенов
    let reasoning: String?      // Настройки reasoning
    let contextLength: Int?     // Ограничение контекста
    let integrations: [LMIntegration]?  // MCP инструменты
}
```

#### LMChatResponse
```swift
struct LMChatResponse: Codable {
    let modelInstanceId: String
    let output: [LMOutputItem]  // message, toolCall, reasoning
    let stats: LMStats?         // Статистика генерации
    let responseId: String
}
```

### События стриминга (SSE)

| Тип события | Описание |
|-------------|----------|
| `chat.start` | Начало сессии чата |
| `message.start` | Начало сообщения |
| `message.delta` | Часть текста сообщения |
| `message.end` | Конец сообщения |
| `reasoning.start` | Начало рассуждений |
| `reasoning.delta` | Часть рассуждений |
| `reasoning.end` | Конец рассуждений |
| `tool_call.start` | Начало вызова инструмента |
| `tool_call.arguments` | Аргументы инструмента |
| `tool_call.success` | Успешное завершение |
| `tool_call.failure` | Ошибка инструмента |
| `chat.end` | Завершение чата |
| `error` | Ошибка от сервера |

---

## 3. NetworkService и HTTPClient архитектура

### HTTPClient

**Назначение:** Универсальный HTTP-клиент для выполнения запросов к LM Studio API.

**Основные возможности:**

```swift
final class HTTPClient: @unchecked Sendable {
    // GET запрос
    func get(url: URL) async throws -> (Data, URLResponse)
    
    // POST запрос с JSON телом
    func post<T: Encodable>(url: URL, body: T) async throws -> (Data, URLResponse)
    
    // POST запрос с SSE стримингом
    func postStreaming<T: Encodable>(
        url: URL, 
        body: T, 
        accept: String = "text/event-stream"
    ) async throws -> (URLSession.AsyncBytes, URLResponse)
    
    // Декодирование JSON
    func decode<T: Decodable>(_ type: T.Type, from data: Data) throws -> T
}
```

**Особенности:**

- Использует `URLSession.AsyncBytes` для эффективного стриминга
- Поддерживает `Task.checkCancellation()` для отмены
- Интеграция с `AuthorizationProvider` для добавления заголовков авторизации

### NetworkConfiguration

```swift
struct NetworkConfiguration: Sendable {
    let session: URLSession
    let decoder: JSONDecoder
    let encoder: JSONEncoder
    let timeout: TimeInterval  // По умолчанию 120 секунд
    
    static let `default` = NetworkConfiguration(timeout: 120)
}
```

**Интеграции:**
- **Pulse** для логирования сетевых запросов (через `URLSessionProxyDelegate`)

### NetworkService

**Назначение:** Главный сервис для взаимодействия с LM Studio REST API.

```swift
@MainActor
final class NetworkService {
    // Получить список моделей
    func fetchModels() async throws -> [ModelInfo]
    
    // Загрузить модель
    func loadModel(...) async throws -> LMModelLoadResponse
    
    // Выгрузить модель
    func unloadModel(instanceId: String) async throws -> LMModelUnloadResponse
    
    // Скачать модель
    func downloadModel(...) async throws -> LMDownloadResponse
    
    // Статус скачивания
    func getDownloadStatus(jobId: String) async throws -> LMDownloadStatus
    
    // Стриминг чата
    func streamChat(...) -> AsyncThrowingStream<ChatCompletionStreamPart, Error>
}
```

**Архитектура:**
- `@MainActor` для безопасного доступа к UI
- Делегирует HTTP к `HTTPClient`
- Делегирует стриминг к `ChatStreamService`
- Использует `DeviceConfiguration` для настроек устройства

### NetworkMonitor

```swift
@MainActor
final class NetworkMonitor: ObservableObject, NetworkMonitoring {
    @Published private(set) var isConnected: Bool
    @Published private(set) var isWifiOrEthernet: Bool
    
    // Combine publisher для reactivity
    var isConnectedPublisher: AnyPublisher<Bool, Never>
}
```

**Использует:**
- `NWPathMonitor` из фреймворка Network
- Combine для реактивного управления состоянием

---

## 4. SSE парсинг и стриминг

### SSEParser

**Назначение:** Парсер событий Server-Sent Events для обработки потоковой передачи от LM Studio.

```swift
struct SSEParser {
    private var buffer = ""           // Буфер текущей строки
    private var currentEventType = "" // Тип события
    private var messageContent = ""   // Накопленный контент
    private var reasoningContent = "" // Накопленные рассуждения
    
    // Обработка байта
    mutating func parse(byte: UInt8) -> ParsedEvent?
}
```

**Алгоритм работы:**

1. Накапливает байты в буфер до символа новой строки `\n`
2. Проверяет префикс `event: ` для определения типа события
3. Проверяет префикс `data: ` для получения JSON данных
4. Декодирует JSON в `LMSEvent`
5. Преобразует в типизированное событие `ParsedEvent`

### ChatStreamService

**Назначение:** Выполнение стриминга чата и преобразование событий.

```swift
final class ChatStreamService: @unchecked Sendable {
    nonisolated func streamChat(
        url: URL,
        messages: [ChatMessage],
        model: String,
        temperature: Double?,
        maxTokens: Int?
    ) -> AsyncThrowingStream<ChatCompletionStreamPart, Error>
}
```

**Процесс:**

1. Создает `LMChatRequest` с параметрами
2. Вызывает `httpClient.postStreaming()` для получения `AsyncBytes`
3. Итерирует по байтам и парсит через `SSEParser`
4. Конвертирует `ParsedEvent` в `ChatCompletionStreamPart`
5. Возвращает `AsyncThrowingStream` для UI

### Обработка событий

```
Байты из сети
     ↓
SSEParser.parse(byte:) → ParsedEvent
     ↓
ChatStreamService.convertToStreamPart() → ChatCompletionStreamPart
     ↓
AsyncThrowingStream → UI
```

---

## 5. Аутентификация и безопасность

### AuthorizationProvider

```swift
protocol AuthorizationProvider: Sendable {
    func authorizationHeader() -> String?
}

struct DeviceAuthorizationProvider: AuthorizationProvider {
    func authorizationHeader() -> String? {
        // Проверка аргументов запуска
        if ProcessInfo.processInfo.arguments.contains("-auth") {
            return "Bearer sk-lm-test-token"
        }
        
        // Получение токена из Keychain
        let tokenKey = DeviceConfiguration.configuration(for: ...)?.tokenKey ?? "auth_token_test"
        guard let token = KeychainHelper.get(key: tokenKey),
              !token.isEmpty else {
            return nil
        }
        return "Bearer \(token)"
    }
}
```

### KeychainHelper

```swift
enum KeychainHelper {
    static func get(key: String) -> String?
    static func set(key: String, value: String) -> Bool
    static func delete(key: String)
}
```

**Безопасность:**
- Использует `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`
- Токен доступен только на текущем устройстве
- Удаление старого значения перед записью нового

### DeviceConfiguration

```swift
struct DeviceConfiguration {
    static func configuration(for deviceName: String) -> DeviceConfig?
}

struct DeviceConfig {
    let tokenKey: String
    let deviceId: String
}
```

**Хранение конфигурации:**
- Имя устройства: `DeviceIdentity.currentName`
- Конфигурация: предопределенные профили для разных устройств

### AppConfig (настройки подключения)

```swift
@AppStorage("lm_base_url") var baseURL: String = "http://192.168.1.91:64721"
@AppStorage("api_token") var apiToken: String = ""  // Резервное хранилище
@AppStorage("lm_timeout") var timeout: Double = 30.0
```

---

## 6. Обработка ошибок

### NetworkError

```swift
enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(Int, String?)
    case unauthorized        // 401
    case forbidden           // 403
    case rateLimited(retryAfter: Int?)  // 429
    case networkError(Error)
    case unknown
}
```

**Обработка в HTTPClient:**

```swift
private func handleResponse(_ response: URLResponse) throws {
    guard let httpResponse = response as? HTTPURLResponse else {
        throw NetworkError.unknown
    }
    
    switch httpResponse.statusCode {
    case 200...299: return
    case 400: throw NetworkError.serverError(400, "Неверный запрос")
    case 401: throw NetworkError.unauthorized
    case 403: throw NetworkError.forbidden
    case 429: throw NetworkError.rateLimited(retryAfter: ...)
    case 500...503: throw NetworkError.serverError(httpResponse.statusCode, "Сервер недоступен")
    default: throw NetworkError.serverError(httpResponse.statusCode, nil)
    }
}
```

**Особенности:**
- Реализует `LocalizedError` для автоматических сообщений в UI
- Обрабатывает `Retry-After` заголовок для rate limiting
- Поддержка отмены через `CancellationError`

---

## 7. Сервисы (ChatService, ChatStreamService, ChatSessionManager)

### ChatService

```swift
@MainActor
protocol ChatServiceProtocol: AnyObject {
    func fetchModels() async throws -> [ModelInfo]
    func streamChat(...) -> AsyncThrowingStream<ChatCompletionStreamPart, Error>
}

@MainActor
final class ChatService: ObservableObject, ChatServiceProtocol {
    private let networkService: NetworkService
    
    func fetchModels() async throws -> [ModelInfo]
    func streamChat(...) -> AsyncThrowingStream<ChatCompletionStreamPart, Error>
}
```

**Назначение:** Бизнес-логика чата, абстракция над NetworkService.

### ChatStreamService

```swift
final class ChatStreamService: @unchecked Sendable {
    private let httpClient: HTTPClient
    
    nonisolated func streamChat(...) -> AsyncThrowingStream<ChatCompletionStreamPart, Error>
}
```

**Назначение:** Низкоуровневый стриминг, работает в nonisolated контексте.

### ChatSessionManager

```swift
@MainActor
final class ChatSessionManager: ObservableObject {
    private let modelContext: ModelContext
    
    func createSession(modelName: String, title: String?) -> ChatSession
    func addMessage(_ message: Message, to session: ChatSession)
    func deleteSession(_ session: ChatSession)
    func deleteMessage(_ message: Message)
    func deleteMessages(after index: Int, in session: ChatSession)
    func save()
}
```

**Назначение:** Управление сессиями и сообщениями через SwiftData.

---

## 8. Выводы и рекомендации

### Сильные стороны

1. **Четкое разделение ответственности**
   - `HTTPClient` — низкоуровневые запросы
   - `NetworkService` — высокоуровневый API
   - `ChatService` — бизнес-логика

2. **Поддержка современного Swift**
   - `async/await` для асинхронности
   - `AsyncThrowingStream` для стриминга
   - `@MainActor` для thread safety
   - `Sendable` для concurrency

3. **Полная интеграция с LM Studio API**
   - Все основные эндпоинты
   - Поддержка стриминга
   - Инструменты (MCP)

4. **Качественная обработка ошибок**
   - Типизированные ошибки
   - LocalizedError для UI
   - Поддержка отмены

### Области для улучшения

1. **Тестирование**
   - Отсутствуют юнит-тесты для сервисов
   - Рекомендуется добавить `XCTest` для `HTTPClient`, `SSEParser`

2. **Retry логика**
   - Отсутствует автоматический retry при временных ошибках
   - Рекомендуется `RetryPolicy` (например, с использованиемswift-retry)

3. **Connection pooling**
   - Не используется постоянное соединение
   - Для долгих стримов可以考虑 keep-alive

4. **Logging**
   - Базовый logging через Pulse
   - Рекомендуется добавить структурированный логгер (OSLog)

5. **Валидация**
   - Отсутствует валидация URL перед запросом
   - Рекомендуется добавить `URLValidation`

### Рекомендуемые улучшения

| Приоритет | Задача | Описание |
|-----------|--------|----------|
| 🔴 Высокий | Добавить тесты | Покрыть тестами ключевые компоненты |
| 🔴 Высокий | Retry логика | Автоматический retry при 5xx |
| 🟡 Средний | Connection pooling | Оптимизация для долгих соединений |
| 🟡 Средний | Валидация URL | Проверка URL перед запросом |
| 🟢 Низкий | Расширить логирование | Структурированный OSLog |

---

## Зависимости

### Фреймворки (встроенные)

- Foundation
- Network (NWPathMonitor)
- Security (Keychain)
- Combine
- SwiftData

### Внешние

- **Pulse** — логирование сетевых запросов

---

## Контакты

- **Server Lead:** Ответственный за серверную интеграцию
- **CTO:** Техническое руководство
- **Server Developer:** Реализация фич

---

*Документ создан в рамках анализа проекта Chat*

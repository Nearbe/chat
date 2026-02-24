# Анализ серверной части проекта Chat

**Автор:** Server Developer  
**Дата:** 24 февраля 2026  
**Версия:** 1.0

---

## Содержание

1. [NetworkService и HTTPClient](#1-networkservice-и-httpclient)
2. [SSEParser и стриминг](#2-sseparser-и-стриминг)
3. [LM Studio API интеграция](#3-lm-studio-api-интеграция)
4. [Обработка ошибок](#4-обработка-ошибок)
5. [Рекомендации по улучшению](#5-рекомендации-по-улучшению)

---

## 1. NetworkService и HTTPClient

### 1.1 Архитектура

Проект использует многоуровневую архитектуру сетевого взаимодействия:

```
NetworkService (UI-слой, @MainActor)
    └── ChatStreamService (бизнес-логика)
            └── HTTPClient (низкоуровневые запросы)
                    └── URLSession (системный уровень)
```

**NetworkService** — основной класс для взаимодействия с LM Studio API. Работает в основном потоке (`@MainActor`), что упрощает интеграцию с UI, но ограничивает возможности параллелизма.

**HTTPClient** — универсальный HTTP-клиент с поддержкой:
- GET/POST запросов
- JSON кодирования/декодирования
- Streaming (SSE)
- Авторизации через `AuthorizationProvider`

### 1.2 Сильные стороны

- **Чёткое разделение ответственности**: каждый слой делает свою работу
- **Конфигурируемость**: `NetworkConfiguration` позволяет настраивать таймауты и сессии
- **Интеграция с Pulse**: автоматическое логирование сетевых запросов
- **Типобезопасность**: использование Swift Codable для JSON

### 1.3 Проблемы

| Проблема | Описание | Влияние |
|----------|----------|---------|
| `@MainActor` в NetworkService | Весь сервис работает в main thread | Блокировка UI при долгих операциях |
| Отсутствие retry логики | Нет механизма повторных попыток | Ненадёжность при временных сбоях |
| Нет circuit breaker | Нет защиты от каскадных отказов | Риск перегрузки при проблемах |
| Таймаут в NetworkConfiguration | Жёстко задан 120 сек | Не подходит для долгих операций |

---

## 2. SSEParser и стриминг

### 2.1 Реализация

Парсер SSE событий реализован в `SSEParser.swift` и используется в `ChatStreamService`:

```swift
// Поток обработки:
// 1. HTTPClient.postStreaming() → URLSession.AsyncBytes
// 2. ChatStreamService итерирует байты
// 3. SSEParser.parse(byte:) буферизует построчно
// 4. Парсинг JSON через JSONDecoder → LMSEvent
// 5. mapEvent() → SSEParser.ParsedEvent
// 6. convertToStreamPart() → ChatCompletionStreamPart
```

### 2.2 Поддерживаемые события

| Событие | Обработка |
|---------|-----------|
| `chat.start` | Сброс состояния |
| `message.delta` | Генерация контента |
| `reasoning.delta` | Генерация рассуждений |
| `tool_call.*` | Обработка инструментов |
| `chat.end` | Завершение стрима |
| `error` | Проброс ошибки |

### 2.3 Проблемы

**Критические:**

1. **Нет обработки ошибок в парсере** — при некорректном JSON события silently игнорируются:
   ```swift
   } catch {
       return nil  // Потеря данных без уведомления
   }
   ```

2. **Буферизация построчно** — медленная обработка для больших объёмов данных:
   ```swift
   buffer.append(char)  // O(n) для каждого байта
   ```

3. **Нет backpressure handling** — при быстром production и медленном consumption возможен memory bloat

**Улучшения:**

- Использовать `Data` буфер и `split(separator:)` для batch-парсинга
- Добавить логирование пропущенных событий
- Реализовать backpressure через `AsyncStream` с буфером

---

## 3. LM Studio API интеграция

### 3.1 Поддерживаемые эндпоинты

| Метод | Эндпоинт | Статус |
|-------|----------|--------|
| GET | `/api/v1/models` | ✅ Реализовано |
| POST | `/api/v1/models/load` | ✅ Реализовано |
| POST | `/api/v1/models/unload` | ✅ Реализовано |
| POST | `/api/v1/models/download` | ✅ Реализовано |
| GET | `/api/v1/models/download/{jobId}` | ✅ Реализовано |
| POST | `/api/v1/chat` (stream) | ✅ Реализовано |

### 3.2 Модели запросов/ответов

Все модели находятся в `/Models/LMStudio/`:

- `LMChatRequest` — запрос чата с полной поддержкой параметров
- `LMSEvent` — SSE события
- `LMModelLoadRequest`/`LMModelLoadResponse` — загрузка моделей
- `LMDownloadRequest`/`LMDownloadStatus` — скачивание

### 3.3 Проблемы

| Проблема | Описание |
|----------|----------|
| Отсутствует rate limiting на клиенте | Нет ограничения частоты запросов |
| Нет кэширования списка моделей | Каждый раз делается новый запрос |
| Нет версионирования API | При смене версии LM Studio сломается |
| URL хардкодится | Нет fallback при недоступности |

---

## 4. Обработка ошибок

### 4.1 Текущая реализация

Ошибки инкапсулированы в `NetworkError`:

```swift
enum NetworkError: LocalizedError {
    case invalidURL
    case noData
    case decodingError(Error)
    case serverError(Int, String?)
    case unauthorized
    case forbidden
    case rateLimited(retryAfter: Int?)
    case networkError(Error)
    case unknown
}
```

### 4.2 Плюсы

- ✅ Соответствует `LocalizedError` для UI
- ✅ Локализованные сообщения
- ✅ Поддержка retry-after для rate limiting
- ✅ Различение 4xx/5xx ошибок

### 4.3 Минусы

| Проблема | Описание |
|----------|----------|
| Нет retry стратегии | После ошибки — сразу исключение |
| Нет granular recovery | Один тип ошибки — одно действие |
| Нет fallback URL | При недоступности — полный отказ |
| Нет network reachability | Только мониторинг, нет автоматического восстановления |

### 4.4 NetworkMonitor

Реализован в `NetworkMonitor.swift` с использованием `NWPathMonitor`:
- Отслеживает connectivity
- Определяет тип подключения (WiFi/Ethernet)

**Проблема:** Монитор есть, но не используется в `NetworkService` для автоматического retry.

---

## 5. Рекомендации по улучшению

### 5.1 Высокий приоритет

#### 1. Retry Logic с Exponential Backoff

```swift
// Пример реализации
func fetchWithRetry<T>(
    operation: () async throws -> T,
    maxRetries: Int = 3,
    baseDelay: TimeInterval = 1.0
) async throws -> T {
    var lastError: Error?
    for attempt in 0..<maxRetries {
        do {
            return try await operation()
        } catch {
            lastError = error
            let delay = baseDelay * pow(2.0, Double(attempt))
            try await Task.sleep(nanoseconds: UInt64(delay * 1_000_000_000))
        }
    }
    throw lastError!
}
```

#### 2. Circuit Breaker Pattern

Защита от каскадных отказов при недоступности LM Studio:

```swift
actor CircuitBreaker {
    enum State { case closed, open, halfOpen }
    var state: State = .closed
    var failureCount = 0
    let threshold = 5
    
    func recordFailure() { ... }
    func canProceed() -> Bool { ... }
}
```

#### 3. SSE Parser Performance

Использовать batch-парсинг вместо посимвольной обработки:

```swift
mutating func parse(data: Data) -> [ParsedEvent] {
    let lines = data.split(separator: UInt8(ascii: "\n"))
    // Парсить пакетами, а не по одному байту
}
```

### 5.2 Средний приоритет

#### 4. Кэширование моделей

```swift
actor ModelCache {
    private var cachedModels: [ModelInfo]?
    private var lastFetch: Date?
    
    func getModels(refresh: Bool) async throws -> [ModelInfo] {
        // Кэшировать на 5 минут
    }
}
```

#### 5. Rate Limiting (Client-side)

```swift
actor RateLimiter {
    private var requestTimestamps: [Date] = []
    let maxRequestsPerMinute = 30
    
    func throttle() async throws { ... }
}
```

#### 6. Конфигурируемый таймаут

Использовать значение из `AppConfig` вместо жёсткого 120 сек:

```swift
init(timeout: TimeInterval = AppConfig.shared.timeout) { ... }
```

### 5.3 Низкий приоритет

#### 7. Fallback URL

При недоступности основного URL — пробовать fallback:

```swift
let urls = [primaryURL, fallbackURL1, fallbackURL2]
for url in urls {
    // Пробовать подключение
}
```

#### 8. Connection Pooling

Для множественных запросов переиспользовать соединения.

#### 9. WebSocket для долгих сессий

Текущее решение на SSE работает, но для некоторых сценариев WebSocket может быть эффективнее.

---

## Итоговая оценка

| Аспект | Оценка | Комментарий |
|--------|--------|-------------|
| Архитектура | ⭐⭐⭐⭐ | Хорошее разделение слоёв |
| Типобезопасность | ⭐⭐⭐⭐⭐ | Полное использование Swift Codable |
| Обработка ошибок | ⭐⭐⭐ | Базовая, без retry/circuit breaker |
| Производительность | ⭐⭐⭐ | SSEParser требует оптимизации |
| Тестируемость | ⭐⭐⭐⭐ | Есть базовые тесты |
| Надёжность | ⭐⭐⭐ | Нет retry/circuit breaker |

**Общая оценка:** 3.5/5

Проект имеет хорошую базовую архитектуру, но требует улучшений в области надёжности и производительности для production use.

---

## Файлы для ознакомления

- `/Services/Network/NetworkService.swift` — основной сетевой сервис
- `/Services/Network/HTTPClient.swift` — HTTP-клиент
- `/Services/Network/SSEParser.swift` — SSE парсер
- `/Services/Network/NetworkMonitor.swift` — мониторинг сети
- `/Services/Chat/ChatStreamService.swift` — сервис стриминга
- `/Services/Errors/NetworkError.swift` — определение ошибок
- `/Models/LMStudio/*.swift` — модели LM Studio API
- `/ChatTests/HTTPClientTests.swift` — тесты HTTPClient
- `/ChatTests/SSEParserTests.swift` — тесты SSEParser

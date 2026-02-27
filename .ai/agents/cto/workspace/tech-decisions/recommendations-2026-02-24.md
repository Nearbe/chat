# Технические рекомендации CTO

**Дата:** 24 февраля 2026  
**Проект:** Chat (iOS LLM Client)

---

## 1. ТЕХНИЧЕСКИЕ РЕКОМЕНДАЦИИ

### 1.1 Приоритетные улучшения

| # | Область | Рекомендация | Сложность | Влияние |
|---|---------|--------------|-----------|---------|
| 1 | **Error Handling** | Единый ErrorService с User-friendly сообщениями | Medium | High |
| 2 | **Tool Calls** | Реализовать полноценную поддержку MCP tools | High | High |
| 3 | **Offline Mode** | Кэширование моделей, работа без сети | High | Medium |
| 4 | **Image Support** | Multimodal input (vision) для моделей | High | High |

### 1.2 Технический долг

```swift
// TODO в коде:
// ChatViewModel.swift:162 - автоскролл отключён
// MessageInputView - hardcoded цвета в RoundedRectangle
// AppConfig - синглтон без протокола ( затрудняет тестирование )
```

**Рекомендации по долгу:**

1. **AppConfig → Протокол** — выделить интерфейс для мокинга в тестах
2. **Автоскролл** — восстановить с `.scrollDismissesKeyboard(.immediately)`
3. **Hardcoded цвета** — заменить на `AppColors.systemGray4`

---

## 2. АРХИТЕКТУРНЫЕ РЕКОМЕНДАЦИИ

### 2.1 Внедрение зависимостей

**Текущее состояние:**
```swift
// Container+Registrations.swift
var chatService: Factory<ChatService> {
    self { @MainActor in ChatService(networkService: self.networkService()) }.singleton
}
```

**Рекомендация:**
- ✅ Текущая архитектура Factory — правильная
- ➕ Добавить протоколы для всех сервисов (уже есть `ChatServiceProtocol`)
- ➕ Рассмотреть `@MainActor` изоляцию на уровне контейнера

### 2.2 Состояние приложения

| Компонент | Паттерн | Статус |
|-----------|---------|--------|
| AppConfig | Singleton | ⚠️ Сложно мокать |
| ChatViewModel | @MainActor + ObservableObject | ✅ |
| NetworkMonitor | @MainActor + ObservableObject | ✅ |

**Рекомендация:** AppConfig должен быть протоколом с default implementation.

---

## 3. UI/UX РЕКОМЕНДАЦИИ

### 3.1 Дизайн-система

| Элемент | Статус | Рекомендация |
|---------|--------|--------------|
| AppColors | ✅ Готово | — |
| AppSpacing | ✅ Готово | — |
| AppTypography | ✅ Готово | — |
| Тёмная тема | ❌ Нет | Добавить в ThemeManager |

**Рекомендация:**
```swift
// ThemeManager.swift
var currentColorScheme: ColorScheme {
    get { ColorScheme(...) }
    set { ... }
}
```

### 3.2 Новые экраны

| Экран | Приоритет | Описание |
|-------|-----------|----------|
| SettingsView | High | Полноэкранные настройки (URL, temperature, maxTokens) |
| ModelDetailsView | Medium | Информация о модели (размер, квантование) |
| ChatStatsView | Low | Статистика использования |

---

## 4. ФУНКЦИОНАЛЬНЫЕ РЕКОМЕНДАЦИИ

### 4.1 Short-term (1-2 спринта)

| Фича | Описание | Зависимости |
|------|----------|-------------|
| **Settings UI** | Полноэкранные настройки | AppConfig |
| **Model Info** | Показ размера, квантования | ModelPicker → ModelRowView |
| **Share Extensions** | iOS Share Sheet улучшения | ShareSheet |

### 4.2 Medium-term (1 квартал)

| Фича | Описание | Зависимости |
|------|----------|-------------|
| **MCP Tools** | Server-side tools integration | ToolCallView, LMToolCall |
| **Vision** | Image input для multimodal моделей | MessageInputView |
| **Widget** | iOS Widget для быстрого доступа | WidgetKit |

### 4.3 Long-term (2026+)

| Фича | Описание |
|------|----------|
| **Ollama Runtime** | Нативная интеграция с Ollama (не только docs) |
| **Voice Input** | Speech-to-text для ввода |
| **AR Mode** | AR чат с визуализацией |

---

## 5. ИНФРАСТРУКТУРА

### 5.1 CI/CD

**Текущее:** `check` + `ship` через Swift Scripts

**Рекомендации:**

1. ✅ **GitHub Actions / GitLab CI** — добавить CI для PR checks
2. ✅ **TestFlight** — автоматический деплой в TestFlight
3. ➕ **Danger** — автоматические проверки PR

### 5.2 Мониторинг

| Инструмент | Статус |
|------------|--------|
| Pulse | ✅ Интегрирован |
| ConsoleView | ✅ Двойной тап |
| Логи в файл | ❌ Нет |

**Рекомендация:** Добавить FileLogger для офлайн-диагностики.

---

## 6. ТЕСТИРОВАНИЕ

### 6.1 Покрытие

**Текущее:** 100% (по заявлению в QWEN.md)

### 6.2 Рекомендации

| Область | Рекомендация |
|---------|--------------|
| UI Tests | Расширить Page Object Model |
| Snapshot | Добавить темную тему в превью |
| Integration | Добавить тесты с реальным LM Studio (mock server) |
| Performance | Добавить тесты на время загрузки |

---

## 7. БЕЗОПАСНОСТЬ

### 7.1 Текущее состояние

✅ Keychain для токенов  
✅ kSecAttrAccessibleWhenUnlockedThisDeviceOnly  
✅ Нет хардкода  
✅ AuthorizationProvider изолирован  

### 7.2 Рекомендации

1. **Biometric Auth** — Face ID / Touch ID для разблокировки токена
2. **Certificate Pinning** — для production API
3. **Jailbreak Detection** — предупреждение при запуске на jailbroken устройстве

---

## 8. ПРОИЗВОДИТЕЛЬНОСТЬ

### 8.1 bottlenecks

| Область | Проблема | Решение |
|---------|----------|---------|
| SwiftData | Сохранение при каждом чанке | Batch update |
| SSE Parser | String concatenation | StringBuilder pattern |
| ChatViewModel | Много @Published | DiffableDataSource |

### 8.2 Рекомендации

```swift
// Оптимизация SwiftData
// Вместо:
sessionManager.save() // каждый чанк

// Делать:
actor SessionCache {
    private var pendingChanges: [Message] = []
    func scheduleSave(_ message: Message) { ... }
}
```

---

## 9. ДОКУМЕНТАЦИЯ

### 9.1 Текущее состояние

✅ QWEN.md (полный)  
✅ CHANGELOG.md  
✅ GUIDELINES.md  
✅ API Docs в Docs/  

### 9.2 Рекомендации

- ARCHITECTURE.md — обновить диаграммы
- Inline docs — проверить все public API
- Видео-туториал для новых разработчиков

---

## 10. ПРИОРИТЕТЫ РАЗВИТИЯ

### Roadmap 2026

| Квартал | Фокус | Ключевые фичи |
|---------|-------|---------------|
| Q1 | Stability | Settings UI, Error Handling, Tool Calls |
| Q2 | Features | Vision, Offline Mode |
| Q3 | Platform | Widgets, Share Extension |
| Q4 | Scale | Voice Input, Performance |

---

## ИТОГ

Проект имеет **зрелую архитектуру** и **отличную инфраструктуру**. 

**Главные приоритеты:**
1. ✅ Tool Calls (MCP) — главная фича для LLM чата
2. ✅ Error Handling — улучшить UX при ошибках
3. ✅ Settings UI — дать пользователю контроль

**Конкретные действия:**
1. Создать `SettingsView` с редактированием AppConfig
2. Добавить `ErrorService` с человеческими сообщениями
3. Реализовать полный flow Tool Calls

---

*Рекомендации подготовлены в рамках роли CTO*
*Требуют согласования с @nearbe перед реализацией*

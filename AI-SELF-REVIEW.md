# AI Self-Review — Чеклист перед коммитом

## Назначение

Этот файл оптимизирован для JetBrains AI Assistant → AI Self-Review. Используй как инструкции при каждом коммите.

---

## Чеклист (выполни ВСЕ пункты)

### Компиляция
- [ ] Код компилируется без ошибок: `xcodebuild build`
- [ ] Нет warnings компилятора

### Линтинг
- [ ] SwiftLint проходит без ошибок
- [ ] Максимум 160 символов в строке
- [ ] Все ViewModels имеют `@MainActor`
- [ ] Используется дизайн-система (`AppColors`, `AppSpacing`, `AppTypography`)

### Тесты
- [ ] Unit-тесты проходят
- [ ] UI-тесты проходят
- [ ] Покрытие соответствует цели

### Безопасность
- [ ] Нет hardcoded secrets (API keys, токены, пароли)
- [ ] Секреты в Keychain
- [ ] Нет утечек данных в логах

### Архитектура
- [ ] MVVM: логика в ViewModels, не в Views
- [ ] SwiftData: корректные связи с cascade delete
- [ ] DI: используется `@Injected` из Factory

---

## Swift-стандарты

| Правило | Описание |
|---------|----------|
| `@MainActor` | Обязательно для ViewModels |
| Value Types | Предпочитать `struct` вместо `class` |
| Optionals | Избегать force unwrap (`!`), использовать `guard` |
| Concurrency | `async/await`, не `@escaping` closures |
| Error handling | `throws` вместо optional returns |

---

## SwiftUI-стандарты

| Правило | Описание |
|---------|----------|
| State | `@State`, `@Binding`, `@StateObject`, `@ObservedObject` |
| Design System | Только `AppColors.`, `AppSpacing.`, `AppTypography.` |
| Modifiers | Порядок: frame → padding → background → foreground → cornerRadius |

---

## SwiftData-стандарты

| Правило | Описание |
|---------|----------|
| Models | Все модели — `@Model` class |
| Relationships | `@Relationship` с cascade delete |
| Context | mainContext для UI |

---

## Типичные ошибки

### 1. Memory Leaks
```swift
// ❌ Плохо
var onComplete: (() -> Void)?

// ✅ Хорошо
DispatchQueue.main.async { [weak self] in
    self?.onComplete?()
}
```

### 2. Thread Safety
```swift
// ❌ Плохо — UI на background thread
self.messages = messages

// ✅ Хорошо
@MainActor
func updateMessages(_ messages: [Message]) {
    self.messages = messages
}
```

### 3. Force Unwrapping
```swift
// ❌ Плохо
let name = user.name!

// ✅ Хорошо
guard let name = user.name else { return }
```

### 4. Magic Numbers
```swift
// ❌ Плохо
.padding(16)

// ✅ Хорошо
.padding(AppSpacing.medium)
```

---

## Git-процесс (обязательно)

1. Создать ветку: `feature/FTD-12345-description`
2. Внести изменения
3. Запустить `./scripts check`
4. Если check прошёл → автоматический коммит
5. Если нет → исправить и повторить

---

## Когда НЕ коммитить

- [ ] Есть errors компиляции
- [ ] Есть SwiftLint warnings
- [ ] Тесты падают
- [ ] Добавлены hardcoded secrets
- [ ] Нарушена архитектура

---

## Команды проверки

```bash
# Линтинг
swiftlint lint

# Компиляция
xcodebuild build -scheme Chat -destination 'platform=iOS Simulator,name=iPhone 16'

# Полный check
./scripts check
```

---

## Контекст проекта

| Параметр | Значение |
|----------|----------|
| Платформа | iOS |
| Язык | Swift 6.0 |
| UI | SwiftUI |
| Данные | SwiftData |
| Архитектура | MVVM |
| DI | Factory |
| Целевая iOS | 26.2 |

---

## Настройка в JetBrains IDE (ОБЯЗАТЕЛЬНО)

Для работы AI Self-Review необходимо вручную указать путь к этому файлу в настройках IDE.

### Инструкция

1. **Settings** → **Tools** → **AI Assistant** → **Project Settings** (или AI Self-Review)
2. В поле **Path to rules for AI Self-Review** указать полный путь:
   ```
   /Users/nearbe/repositories/Chat/AI-SELF-REVIEW.md
   ```
3. Включить **Enable AI Self-Review** (если есть)
4. Нажать **Apply** → **OK**

### Альтернативный способ

1. **Settings** → **Tools** → **AI Assistant** → **AI Self-Review**
2. Нажать **+** рядом с "Custom instructions"
3. Выбрать этот файл `AI-SELF-REVIEW.md`

### Проверка работы

После настройки:
1. Откройте Commit tool window: **Alt + 0** (Windows/Linux) или **⌘ + 0** (macOS)
2. Выберите файлы для коммита
3. Нажмите **Self-Review with AI**
4. Откроется вкладка **AI Self-Review** в Problems tool window

### Важно

- Эта настройка хранится локально в IDE и **не синхронизируется** через VCS
- Каждый новый член команды должен настроить это вручную
- Инструкция также есть в `SETUP.md`

---

## Документация

- `QWEN.md` — полный контекст
- `AGENTS.md` — руководство для агентов
- `GUIDELINES.md` — руководство разработчика
- `SETUP.md` — настройка окружения
- `TESTING.md` — тестирование
- `ARCHITECTURE.md` — архитектура
- `SECURITY.md` — безопасность

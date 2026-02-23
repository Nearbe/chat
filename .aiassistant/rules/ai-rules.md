---
apply: by model decision
---

# Chat Project — AI Rules

Правила для JetBrains AI Assistant. Применяются ко всем файлам проекта.

---

## Model Decision — Инструкции для AI

When analyzing changes and deciding what checks to run, follow these rules:

### 1. Determine what was changed

Check file extensions and paths:

- **Swift files** → `.swift`
- **Design system** → `Design/`, `Resources/`
- **Configuration** → `project.yml`, `swiftgen.yml`, `.swiftlint.yml`
- **Scripts** → `Tools/Scripts/`
- **Tests** → `ChatTests/`, `ChatUITests/`
- **Features** → `Features/`
- **Services** → `Services/`
- **Models** → `Models/`

### 2. Decide which checks to apply

| If changed files include...                                    | Run these checks...       |
|----------------------------------------------------------------|---------------------------|
| `.swift` files                                                 | SwiftLint, compile check  |
| `project.yml` or `Tools/`                                      | XcodeGen regeneration     |
| `Design/` or `Resources/`                                      | SwiftGen regeneration     |
| `Chat/`, `Features/`, `Services/`, `Models/`, `Core/`, `Data/` | Unit tests + UI tests     |
| `ChatUITests/`                                                 | UI tests only             |
| Only documentation (`.md`, `.txt`)                             | Skip all tests            |
| Only config files                                              | Skip tests, run lint only |

### 3. Smart skip rules

**Skip SwiftLint** if:

- Only `.md`, `.json`, `.yml`, `.yaml` files changed
- Only comments or documentation changed

**Skip tests** if:

- No Swift code was modified
- Only documentation changed
- Only config/YAML files changed

**Skip XcodeGen** if:

- No changes to `project.yml`
- No changes to `Tools/` directory

**Skip SwiftGen** if:

- No changes to `Design/` directory
- No changes to `Resources/` directory

### 4. Always run (mandatory)

Regardless of changes, always:

- Check for hardcoded secrets (API keys, passwords, tokens)
- Verify no sensitive data in logs
- Confirm Keychain is used for secrets

### 5. Test execution commands

If tests are needed, use:

```bash
# Unit tests
xcodebuild test -scheme Chat -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:ChatTests

# UI tests
xcodebuild test -scheme Chat -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:ChatUITests

# Full check (if unsure)
./scripts check
```

---

## Swift Style

- Максимум **160 символов** в строке
- camelCase для переменных и функций
- PascalCase для типов и enum
- Все **ViewModels** обязательно с `@MainActor`
- Использовать дизайн-систему: `AppColors`, `AppSpacing`, `AppTypography`
- Русские **Docstrings** для всех публичных API
- Предпочитать `struct` вместо `class`
- Избегать force unwrap (`!`), использовать `guard let` и `if let`

---

## Architecture (MVVM)

- Бизнес-логика в **ViewModels**, не в Views
- Использовать `@Injected` из Factory для dependency injection
- Services должны соответствовать **протоколам**
- SwiftData модели с атрибутом `@Model`
- Relationships использовать с `cascade delete`
- Использовать `mainContext` для UI операций

---

## Error Handling

- Использовать `throws` вместо optional returns
- Создавать кастомные Error enums с `LocalizedError`
- **НИКОГДА** не хардкодить API keys или secrets
- Secrets хранить **только в Keychain**
- Логировать ошибки без чувствительных данных

---

## Testing

- Использовать **Swift Testing** с `@Suite` и `@Test`
- Паттерн **AAA** (Arrange, Act, Assert)
- Использовать `#expect` для assertions
- Mock внешние зависимости через протоколы
- Именование тестов: `Method_Scenario_ExpectedResult`

---

## SwiftUI

- Использовать правильно: `@State`, `@Binding`, `@StateObject`, `@ObservedObject`
- **НЕ** использовать `.padding(16)` — только `.padding(AppSpacing.*)`
- **НЕ** использовать `Color.primary` — только `AppColors.*`
- Порядок модификаторов: `frame → padding → background → foreground → cornerRadius`
- Использовать `LazyVStack/LazyHStack` для длинных списков

---

## Security

- **НИКОГДА** не хардкодить API keys, токены, пароли
- Использовать `KeychainHelper` для secrets
- Использовать `kSecAttrAccessibleWhenUnlockedThisDeviceOnly`
- Не логировать чувствительные данные
- Использовать **https** для всех сетевых запросов

---

## Concurrency

- Использовать **async/await** вместо completion handlers
- Избегать `@escaping` closures
- Использовать `AsyncThrowingStream` для стриминга
- Все ViewModels и UI-bound services: **@MainActor**
- Использовать `Task` для фоновых операций

---

## Git Commits

- **Русский язык** для commit messages
- Формат: `<type>(<module>): <description>`
- Types: `feat`, `fix`, `refactor`, `docs`, `test`, `chrole`
- Все изменения в одной ветке = **один коммит** (использовать amend)
- Force push только с `--force-with-lease`

---

## Тестирование правил

После добавления файла:

1. **Settings** → **Tools** → **AI Assistant** → **Rules**
2. Нажми **"New Project Rules File"** или **+**
3. Выбери файл `.aiassistant/rules/ai-rules.md`
4. Проверь, что правила применяются к Swift файлам

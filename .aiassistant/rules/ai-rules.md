---
apply: by model decision
---

# Chat Project — AI Rules

Правила для JetBrains AI Assistant. Применяются ко всем файлам проекта.

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

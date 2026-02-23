# Руководство для контрибьюторов

Спасибо за интерес к проекту Chat! Этот документ поможет вам внести вклад в развитие проекта.

---

## Быстрый старт

```bash
# Клонирование репозитория
git clone https://github.com/your-org/Chat.git
cd Chat

# Генерация проекта
./scripts setup

# Запуск приложения
open Chat.xcodeproj
```

---

## Процесс разработки

### Workflow для людей

1. **Создайте ветку** от актуальной `release/X.X.X`:
   ```bash
   git checkout -b feature/FTD-12345-description
   ```

2. **Внесите изменения** согласно coding standards

3. **Запустите проверку**:
   ```bash
   ./scripts check
   ```

4. **Создайте Pull Request** с описанием изменений

5. **После approve** — merge в release ветку

### Workflow для AI-агентов

AI-агенты должны следовать `AI-SELF-REVIEW.md` чеклисту.

---

## Требования к коду

### Обязательные правила

| Правило | Описание |
|---------|----------|
| SwiftLint | Прохождение без warnings |
| `@MainActor` | Все ViewModels |
| Дизайн-система | `AppColors`, `AppSpacing`, `AppTypography` |
| Docstrings | Русский язык для публичных API |
| Лимит строки | Максимум 160 символов |

### Структура коммитов

```
<тип>(<модуль>): <краткое описание>

[опционально: подробное описание]

[опционально: ссылки на issue]
```

**Типы:**
- `feat` — новая функциональность
- `fix` — исправление бага
- `refactor` — рефакторинг
- `docs` — документация
- `test` — тесты
- `chore` — инфраструктура

**Примеры:**
```
feat(chat): добавлен стриминг сообщений
fix(network): исправлен краш при потере соединения
docs(api): обновлена документация LM Studio
```

---

## Тестирование

### Требования

- **Unit-тесты** — для всех новых компонентов
- **Покрытие** — минимум 50%, цель 100%
- **UI-тесты** — для критических пользовательских сценариев

### Запуск тестов

```bash
# Все тесты
./scripts check

# Только Unit-тесты
xcodebuild test -scheme Chat -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:ChatTests

# Только UI-тесты
xcodebuild test -scheme Chat -destination 'platform=iOS Simulator,name=iPhone 16' -only-testing:ChatUITests
```

---

## Архитектура

### Основные принципы

- **MVVM** — разделение UI и бизнес-логики
- **SwiftData** — персистентность
- **Factory** — dependency injection
- **Single Responsibility** — сервисы с узкой ответственностью

### Структура проекта

```
Chat/
├── Features/       # Функциональные модули
├── Services/       # Бизнес-логика
├── Models/         # Доменные модели + API
├── Core/           # Утилиты и расширения
└── Design/         # Дизайн-система
```

Подробнее в `ARCHITECTURE.md`.

---

## Code Review

### Чеклист ревьюера

- [ ] Код компилируется без ошибок
- [ ] SwiftLint проходит
- [ ] Тесты проходят
- [ ] Нет hardcoded secrets
- [ ] Соблюдена архитектура
- [ ] Есть документация для новых API

### Время на ревью

| Тип PR | Ожидаемое время |
|--------|-----------------|
| Small (< 100 строк) | 24 часа |
| Medium (< 500 строк) | 48 часов |
| Large (> 500 строк) | 72 часа |

---

## Вопросы

- **Issues** — для багов и предложений
- **Discussions** — для вопросов
- **Security** — см. `SECURITY.md`

---

## Лицензия

Проект использует [MIT License](LICENSE).

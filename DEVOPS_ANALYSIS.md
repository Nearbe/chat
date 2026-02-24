# DEVOPS_ANALYSIS.md

## DevOps анализ iOS проекта Chat

**Дата анализа:** 24 февраля 2026  
**Аналитик:** DevOps Engineer  
**Версия проекта:** 1.0  

---

## 1. XcodeGen конфигурация

### Текущее состояние: ✅ Хорошо настроено

**Файл:** `project.yml`

#### Ключевые характеристики:

| Параметр | Значение |
|----------|----------|
| Версия XcodeGen | 2.44.1 |
| Target iOS | 26.2 |
| Swift Version | 6.0 |
| Bundle ID | ru.nearbe.chat |
| Deployment Target | iOS 26.2 |

#### Используемые зависимости (SPM):

- **Factory** (v2.3.0+) — Dependency Injection
- **Pulse** (v4.0.0+) — Логирование и отладка
- **PulseUI** (v4.0.0+) — UI для Pulse
- **SnapshotTesting** (v1.15.4+) — Snapshot тесты
- **SQLite** (v0.15.3+) — Локальная база данных

#### Настройки сборки:

```yaml
settings:
  base:
    SWIFT_VERSION: "6.0"
    SWIFT_TREAT_WARNINGS_AS_ERRORS: YES
    GCC_TREAT_WARNINGS_AS_ERRORS: YES
    DEVELOPMENT_TEAM: QP3VV6YM6A
    CODE_SIGN_STYLE: Automatic
    ENABLE_USER_SCRIPT_SANDBOXING: "NO"
```

#### Цели проекта:

1. **Chat** — Основное приложение (iOS)
2. **ChatTests** — Unit тесты
3. **ChatUITests** — UI тесты
4. **Scripts** — Инструменты командной строки (macOS)

#### Схемы (Schemes):

- `Chat` — основная схема с build, run, test, archive
- `🛠️ Setup` — подготовка проекта
- `🔍 Check` — линтинг + сборка + тесты
- `🚢 Ship` — релиз + деплой
- `📚 Download Docs` — загрузка документации
- `🔐 Configure Sudo` — настройка sudo
- `🔗 Update Docs Links` — обновление ссылок документации

#### Post-build скрипты:

- **SwiftLint** — проверка качества кода

---

## 2. SwiftGen настройка

### Текущее состояние: ⚠️ Требует внимания

**Статус:** SwiftGen установлен через Homebrew, но **не интегрирован в XcodeGen**

#### Проблемы:

1. **Отсутствует `swiftgen.yml`** — нет конфигурационного файла для SwiftGen
2. **Нет Build Phase интеграции** — генерация ресурсов не автоматизирована в Xcode
3. **Документация есть, но конфигурация не завершена** — в Docs есть полная документация по SwiftGen, но в project.yml нет генерации ресурсов

#### Что должно генерироваться:

- Assets Catalogs (xcassets)
- Colors
- Localizable strings
- Fonts
- Interface Builder файлы

#### Рекомендуемая конфигурация:

```yaml
# swiftgen.yml (требуется создать)
xcassets:
  inputs:
    - Resources/Assets.xcassets
  outputs:
    - templateName: swift5
      output: Core/Generated/Assets.swift

strings:
  inputs: Resources/Base.lproj
  outputs:
    - templateName: structured-swift5
      output: Core/Generated/Strings.swift
```

---

## 3. Scripts автоматизация

### Текущее состояние: ✅ Отлично

Проект имеет развитую систему автоматизации через Swift-based CLI инструменты.

#### Структура Scripts:

```
Tools/Scripts/
├── Package.swift           # SPM конфигурация
├── Sources/Scripts/
│   ├── Commands/           # Команды
│   │   ├── Setup.swift
│   │   ├── Check.swift
│   │   ├── Ship.swift
│   │   ├── DownloadDocs.swift
│   │   ├── UpdateDocsLinks.swift
│   │   ├── ConfigureSudo.swift
│   │   └── RegisterAgents.swift
│   ├── Services/           # Сервисы
│   │   ├── BuildService.swift
│   │   ├── SwiftGenService.swift
│   │   ├── SwiftLintService.swift
│   │   ├── TestService.swift
│   │   ├── GitService.swift
│   │   ├── DependencyService.swift
│   │   ├── MetricsService.swift
│   │   └── ...
│   └── Models/
│       ├── CheckModels.swift
│       └── Versions.swift
└── Agents/metrics/         # Метрики
```

#### Доступные команды:

| Команда | Описание |
|---------|----------|
| `Setup` | Подготовка проекта (XcodeGen + SwiftGen + регистрация агентов) |
| `Check` | Линтинг + сборка + тесты + пуш |
| `Ship` | Релиз + деплой на устройство |
| `DownloadDocs` | Загрузка документации |
| `UpdateDocsLinks` | Обновление ссылок документации |
| `ConfigureSudo` | Настройка sudo прав |

#### Shell скрипты:

1. **chat-scripts.sh** — обёртка для запуска CLI команд
2. **deploy.sh** — автоматическое разворачивание окружения

---

## 4. Процесс сборки

### Текущее состояние: ✅ Настроено

#### Процесс сборки:

1. **XcodeGen** генерирует `Chat.xcodeproj`
2. **SPM** разрешает зависимости автоматически
3. **SwiftLint** запускается после сборки
4. **Scripts CLI** предоставляет команды для сборки

#### BuildService возможности:

```swift
// Release сборка
BuildService.buildRelease()

// Установка на устройство
BuildService.installToDevice(deviceName: "iPhone")

// Запуск приложения
BuildService.launchApp(deviceName: "iPhone")

// Полный цикл доставки
BuildService.ship(deviceName: "iPhone")
```

#### Build команды:

```bash
# Локальная сборка
xcodebuild -project Chat.xcodeproj -scheme Chat -configuration Debug build

# Release сборка
xcodebuild -project Chat.xcodeproj -scheme Chat -configuration Release \
  -destination "generic/platform=iOS" \
  SYMROOT="$(pwd)/build" build
```

---

## 5. Рекомендации по улучшению DevOps

### 🔴 Высокий приоритет

#### 1. Добавить CI/CD пайплайн

**Проблема:** Нет GitHub Actions или GitLab CI

**Рекомендация:** Создать `.github/workflows/ci.yml`

```yaml
name: CI

on:
  push:
    branches: [main, develop]
  pull_request:
    branches: [main]

jobs:
  build:
    runs-on: macos-latest
    steps:
      - uses: actions/checkout@v4
      - name: Setup
        run: |
          brew install xcodegen swiftgen swiftlint
          swift build -c release --path Tools/Scripts
      - name: Check
        run: ./chat-scripts check
      - name: Build
        run: xcodebuild -project Chat.xcodeproj -scheme Chat -configuration Debug build
      - name: Test
        run: xcodebuild -project Chat.xcodeproj -scheme Chat test
```

#### 2. Интегрировать SwiftGen в проект

**Проблема:** SwiftGen не интегрирован в build phase

**Рекомендация:**
- Создать `swiftgen.yml` с конфигурацией
- Добавить Run Script Phase в XcodeGen:
```yaml
preBuildScripts:
  - name: SwiftGen
    script: |
      if which swiftgen >/dev/null; then
        swiftgen
      fi
    inputFiles:
      - $(SRCROOT)/Resources/**/*.xcassets
      - $(SRCROOT)/Resources/**/Localizable.strings
    outputFiles:
      - $(SRCROOT)/Core/Generated/Assets.swift
```

#### 3. Настроить кэширование зависимостей

**Проблема:** Каждый раз зависимости скачиваются заново

**Рекомендация:** Добавить кэширование в CI:
```yaml
- name: Cache Swift packages
  uses: actions/cache@v4
  with:
    path: |
      ~/.swiftpm
      Tools/Scripts/.build
    key: ${{ runner.os }}-spm-${{ hashFiles('Tools/Scripts/Package.resolved') }}
```

### 🟡 Средний приоритет

#### 4. Добавить тесты производительности

**Проблема:** Нет бенчмарков

**Рекомендация:** Добавить Benchmark платформу:
```swift
// Использовать Swift Benchmark
import Benchmark

Benchmark("Chat List Rendering") {
    // Тестирование рендеринга списка
}
```

#### 5. Настроить code coverage отчётность

**Проблема:** Нет отчётов о покрытии кода

**Рекоменендуемые инструменты:**
- **Slather** — генерация coverage отчётов
- **SonarQube** — анализ качества кода

#### 6. Добавить автоматический versioning

**Проблема:** Версии задаются вручную в project.yml

**Рекомендация:** Использовать:
- **git tags** для версий
- **GitHub Releases** для релизов
- **fastlane** для автоматизации

```ruby
# Fastfile
lane :bump_version do
  increment_version_number(
    version_number: ENV['VERSION'] || '1.0.0'
  )
end
```

### 🟢 Низкий приоритет

#### 7. Настроить предварительные проверки (Pre-commit hooks)

**Проблема:** Нет автоматической проверки перед коммитом

**Рекомендация:** Добавить `.git/hooks/pre-commit`:
```bash
#!/bin/bash
swiftlint || exit 1
```

#### 8. Добавить Docker для CI

**Проблема:** CI зависит от macOS

**Рекомендация:** Для Linux-based CI использовать macos-builder или external CI (GitHub macOS runners)

#### 9. Настроить метрики производительности сборки

**Рекоменендуемые инструменты:**
- **BuildTimeAnalyzer** — анализ времени сборки
- **XcodeBuildMetrics** — метрики сборки

---

## 6. Итоговая оценка

| Категория | Оценка | Комментарий |
|-----------|--------|-------------|
| XcodeGen | ✅ 5/5 | Полностью настроен и документирован |
| SwiftGen | ⚠️ 2/5 | Установлен, но не интегрирован в проект |
| Scripts | ✅ 5/5 | Отличная система автоматизации |
| CI/CD | 🔴 1/5 | Отсутствует полностью |
| Build Process | ✅ 4/5 | Хорошо настроен, нет автоматизации |
| Monitoring | ⚠️ 2/5 | Есть базовые метрики, нет продвинутых |

### Общая оценка: **3.4 / 5**

---

## 7. План действий

1. **Немедленно (1 неделя):**
   - Создать GitHub Actions workflow
   - Интегрировать SwiftGen в build phase
   - Добавить кэширование зависимостей

2. **Краткосрочно (1 месяц):**
   - Настроить code coverage
   - Добавить pre-commit hooks
   - Настроить автоматический versioning

3. **Среднесрочно (3 месяца):**
   - Внедрить fastlane для релизов
   - Настроить SonarQube
   - Добавить бенчмарки производительности

---

## 8. Ссылки

- [XcodeGen Documentation](Docs/Codegen/XcodeGen/README.md)
- [SwiftGen Documentation](Docs/Codegen/SwiftGen/README.md)
- [project.yml](project.yml)
- [chat-scripts.sh](chat-scripts.sh)
- [deploy.sh](deploy.sh)

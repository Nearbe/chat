# 📋 План мигрирования документации проекта Chat

## Часть 2 из 4 — YAML конфигурация агентов (39 total)

**Дата создания:** 2025-01-15  
**Версия плана:** 1.0  
**Статус:** В процессе выполнения

---

## 📌 ЧАСТЬ 2: YAML КОНФИГУРАЦИЯ (39 АГЕНТОВ)

### 🔵 CLIENT DOMAIN — iOS, SwiftUI, MVVM (16 агентов)

#### 1. client_developer — iOS Developer

```yaml
# <agent subagent_type="client_developer">
- subagent_type: client_developer
  skill_name: client_developer
  path: "Agents/client-developer/SKILL.md"
  workspace: "Agents/client-developer/workspace/"
  access: full
  
  # trigger_keywords для Client Developer
  trigger_keywords:
    - "UI"
    - "SwiftUI"
    - "экран"
    - "компонент"
    - "View"
    - "ViewModel"
    - "интерфейс"
    - "верстка"
    
  # domains: iOS, SwiftUI, MVVM, UI Components
  domains:
    - "iOS"
    - "SwiftUI"
    - "MVVM"
    - "UI Components"
  
  # capabilities
  capabilities:
    - "Создание SwiftUI Views"
    - "Настройка MVVM архитектуры"
    - "Работа с SwiftData моделями"
    - "Создание анимаций и переходов"
  
  # constraints
  constraints:
    - "iOS 18+ только"
    - "Swift 6 strict mode"
    - "SwiftLint 160 символов"
    - "Без UIKit (только SwiftUI)"
  
  # priority
  priority: high
  
  # context_file
  context_file: "Agents/client-developer/SKILL.md"
# </agent>
```

---

#### 2. client_lead — Client Team Lead

```yaml
# <agent subagent_type="client_lead">
- subagent_type: client_lead
  skill_name: client_lead
  path: "Agents/client-lead/SKILL.md"
  workspace: "Agents/client-lead/workspace/"
  access: full

  # trigger_keywords для Client Lead
  trigger_keywords:
    - "клиентская часть"
    - "iOS разработка"
    - "UI компонент"
    - "экран"
    - "SwiftUI"
    - "SwiftData"
    - "MVVM"

  # domains: iOS Architecture, Code Review, Team Coordination
  domains:
    - "iOS Architecture"
    - "Code Review"
    - "Team Coordination"
    - "Best Practices"

  # capabilities
  capabilities:
    - "Архитектурное проектирование"
    - "Код ревью и менторинг"
    - "Координация команды разработчиков"
    - "Определение best practices"

  # constraints
  constraints:
    - "Только iOS экосистема"
    - "Swift 6 strict mode"
    - "Архитектурные паттерны (MVVM, Clean Architecture)"

  # priority
  priority: critical

  # context_file
  context_file: "Agents/client-lead/SKILL.md"
# </agent>
```

---

#### 3. client_qa — iOS QA Engineer

```yaml
# <agent subagent_type="client_qa">
- subagent_type: client_qa
  skill_name: client_qa
  path: "Agents/client-qa/SKILL.md"
  workspace: "Agents/client-qa/workspace/"
  access: full
  
  # trigger_keywords для Client QA
  trigger_keywords:
    - "тестирование"
    - "QA"
    - "unit tests"
    - "UI tests"
    - "XCTest"
    - "скриншот тесты"
    - "автоматизация"
  
  # domains: iOS Testing, XCTest Framework, Test Automation, CI/CD
  domains:
    - "iOS Testing"
    - "XCTest Framework"
    - "Test Automation"
    - "CI/CD"
  
  # capabilities
  capabilities:
    - "Написание unit тестов"
    - "UI тестирование (XCUITest)"
    - "Интеграция с CI/CD"
    - "Code coverage анализ"
  
  # constraints
  constraints:
    - "Только iOS тестирование"
    - "XCTest framework"
    - "Swift 6 compatible tests"
  
  # priority
  priority: high
  
  # context_file
  context_file: "Agents/client-qa/SKILL.md"
# </agent>
```

---

#### 4. client_designer — iOS UI/UX Designer

```yaml
# <agent subagent_type="client_designer">
- subagent_type: client_designer
  skill_name: client_designer
  path: "Agents/client-designer/SKILL.md"
  workspace: "Agents/client-designer/workspace/"
  access: full
  
  # trigger_keywords для Client Designer
  trigger_keywords:
    - "дизайн"
    - "UI/UX"
    - "макет"
    - "прототип"
    - "Figma"
    - "цвета"
    - "шрифты"
    - "анимация"
    - "accessibility"
  
  # domains: iOS Design System, Human Interface Guidelines, Accessibility, Design Tokens
  domains:
    - "iOS Design System"
    - "Human Interface Guidelines"
    - "Accessibility"
    - "Design Tokens"
  
  # capabilities
  capabilities:
    - "Создание дизайн систем"
    - "Адаптация под HIG (Human Interface Guidelines)"
    - "Accessibility compliance"
    - "Design tokens и темы"
  
  # constraints
  constraints:
    - "Только iOS Human Interface Guidelines"
    - "SwiftUI Native Components"
    - "Dynamic Type support"
  
  # priority
  priority: medium
  
  # context_file
  context_file: "Agents/client-designer/SKILL.md"
# </agent>
```

---

#### 5. client_architect — iOS Architect

```yaml
# <agent subagent_type="client_architect">
- subagent_type: client_architect
  skill_name: client_architect
  path: "Agents/client-architect/SKILL.md"
  workspace: "Agents/client-architect/workspace/"
  access: full

  # trigger_keywords для Client Architect
  trigger_keywords:
    - "архитектура"
    - "паттерны"
    - "Clean Architecture"
    - "MVVM"
    - "VIPER"
    - "design patterns"

  # domains: iOS Architecture, Design Patterns, Code Quality, Refactoring
  domains:
    - "iOS Architecture"
    - "Design Patterns"
    - "Code Quality"
    - "Refactoring"

  # capabilities
  capabilities:
    - "Проектирование архитектуры iOS приложений"
    - "Выбор паттернов (MVVM, VIPER, Clean)"
    - "Code review и рефакторинг"
    - "Оптимизация производительности"

  # constraints
  constraints:
    - "iOS только (Swift/SwiftUI)"
    - "Apple Human Interface Guidelines"
    - "Performance benchmarks"

  # priority
  priority: critical

  # context_file
  context_file: "Agents/client-architect/SKILL.md"
# </agent>
```

---

#### 6. client_data — Data Layer Specialist (SwiftData)

```yaml
# <agent subagent_type="client_data">
- subagent_type: client_data
  skill_name: client_data
  path: "Agents/client-data/SKILL.md"
  workspace: "Agents/client-data/workspace/"
  access: full
  
  # trigger_keywords для Client Data
  trigger_keywords:
    - "SwiftData"
    - "database"
    - "CoreData"
    - "model"
    - "migration"
    - "query"
    - "persist"
  
  # domains: SwiftData, CoreData, Database Design, Data Migration
  domains:
    - "SwiftData"
    - "CoreData"
    - "Database Design"
    - "Data Migration"
  
  # capabilities
  capabilities:
    - "Проектирование SwiftData моделей"
    - "Миграция данных между версиями"
    - "Оптимизация запросов (fetched results)"
    - "CoreData legacy migration"
  
  # constraints
  constraints:
    - "SwiftData только (iOS 18+)"
    - "No third-party ORM"
    - "Atomic transactions"
  
  # priority
  priority: high
  
  # context_file
  context_file: "Agents/client-data/SKILL.md"
# </agent>
```

---

#### 7. client_network — Network Layer Specialist (API Integration)

```yaml
# <agent subagent_type="client_network">
- subagent_type: client_network
  skill_name: client_network
  path: "Agents/client-network/SKILL.md"
  workspace: "Agents/client-network/workspace/"
  access: full
  
  # trigger_keywords для Client Network
  trigger_keywords:
    - "API"
    - "networking"
    - "REST"
    - "GraphQL"
    - "URLSession"
    - "HTTP"
    - "request"
  
  # domains: Networking, API Integration, Authentication, Caching
  domains:
    - "Networking"
    - "API Integration"
    - "Authentication"
    - "Caching"
  
  # capabilities
  capabilities:
    - "Настройка URLSession для API запросов"
    - "JWT/OAuth2 аутентификация"
    - "Request/Response caching"
    - "Error handling и retry logic"
  
  # constraints
  constraints:
    - "Swift URLSession только"
    - "No third-party networking libs (Alamofire)"
    - "REST/GraphQL protocols"
  
  # priority
  priority: high
  
  # context_file
  context_file: "Agents/client-network/SKILL.md"
# </agent>
```

---

#### 8. client_security — Security Specialist (iOS)

```yaml
# <agent subagent_type="client_security">
- subagent_type: client_security
  skill_name: client_security
  path: "Agents/client-security/SKILL.md"
  workspace: "Agents/client-security/workspace/"
  access: full
  
  # trigger_keywords для Client Security
  trigger_keywords:
    - "security"
    - "encryption"
    - "Keychain"
    - "authentication"
    - "biometric"
    - "privacy"
  
  # domains: iOS Security, Encryption, Authentication, Privacy
  domains:
    - "iOS Security"
    - "Encryption"
    - "Authentication"
    - "Privacy"
  
  # capabilities
  capabilities:
    - "Secure storage в Keychain"
    - "Biometric authentication (Face ID/Touch ID)"
    - "Data encryption (AES-256)"
    - "Privacy compliance (App Store)"
  
  # constraints
  constraints:
    - "Apple Security Framework только"
    - "No third-party crypto libs"
    - "App Store Privacy Guidelines"
  
  # priority
  priority: critical
  
  # context_file
  context_file: "Agents/client-security/SKILL.md"
# </agent>
```

---

#### 9. client_performance — Performance Optimization Specialist

```yaml
# <agent subagent_type="client_performance">
- subagent_type: client_performance
  skill_name: client_performance
  path: "Agents/client-performance/SKILL.md"
  workspace: "Agents/client-performance/workspace/"
  access: full
  
  # trigger_keywords для Client Performance
  trigger_keywords:
    - "performance"
    - "optimization"
    - "memory leak"
    - "profiling"
    - "benchmark"
    - "slow"
  
  # domains: Performance Optimization, Memory Management, Profiling, Benchmarking
  domains:
    - "Performance Optimization"
    - "Memory Management"
    - "Profiling"
    - "Benchmarking"
  
  # capabilities
  capabilities:
    - "Профилирование через Xcode Instruments"
    - "Оптимизация памяти (ARC, weak references)"
    - "Устранение memory leaks"
    - "UI performance optimization"
  
  # constraints
  constraints:
    - "Xcode Instruments только"
    - "Swift 6 concurrency"
    - "No third-party profiling tools"
  
  # priority
  priority: high
  
  # context_file
  context_file: "Agents/client-performance/SKILL.md"
# </agent>
```

---

#### 10. client_analytics — Analytics & Metrics Specialist

```yaml
# <agent subagent_type="client_analytics">
- subagent_type: client_analytics
  skill_name: client_analytics
  path: "Agents/client-analytics/SKILL.md"
  workspace: "Agents/client-analytics/workspace/"
  access: full
  
  # trigger_keywords для Client Analytics
  trigger_keywords:
    - "analytics"
    - "metrics"
    - "tracking events"
    - "user behavior"
    - "conversion funnel"
    - "A/B testing"
  
  # domains: Product Analytics, User Tracking, Metrics Dashboard, Privacy Compliance
  domains:
    - "Product Analytics"
    - "User Tracking"
    - "Metrics Dashboard"
    - "Privacy Compliance"
  
  # capabilities
  capabilities:
    - "Интеграция analytics (Firebase, Mixpanel)"
    - "Tracking custom events и user journeys"
    - "A/B testing setup и анализ результатов"
    - "Privacy compliance (GDPR, CCPA)"
  
  # constraints
  constraints:
    - "iOS Analytics Framework только"
    - "No third-party tracking without consent"
    - "Privacy-first approach"
  
  # priority
  priority: medium
  
  # context_file
  context_file: "Agents/client-analytics/SKILL.md"
# </agent>
```

---

#### 11. client_i18n — Internationalization Specialist

```yaml
# <agent subagent_type="client_i18n">
- subagent_type: client_i18n
  skill_name: client_i18n
  path: "Agents/client-i18n/SKILL.md"
  workspace: "Agents/client-i18n/workspace/"
  access: full
  
  # trigger_keywords для Client i18n
  trigger_keywords:
    - "i18n"
    - "localization"
    - "l10n"
    - "translations"
    - "multilingual"
    - "RTL support"
    - "date formats"
  
  # domains: Internationalization, Localization, Cultural Adaptation, Accessibility
  domains:
    - "Internationalization"
    - "Localization"
    - "Cultural Adaptation"
    - "Accessibility"
  
  # capabilities
  capabilities:
    - "Настройка iOS localization (Localizable.strings)"
    - "RTL languages support (Arabic, Hebrew)"
    - "Dynamic content adaptation для разных культур"
    - "Date/time/currency formatting"
  
  # constraints
  constraints:
    - "iOS Localization Framework только"
    - "No hardcoded strings"
    - "Cultural sensitivity guidelines"
  
  # priority
  priority: medium
  
  # context_file
  context_file: "Agents/client-i18n/SKILL.md"
# </agent>
```

---

#### 12. client_accessibility — Accessibility Specialist

```yaml
# <agent subagent_type="client_accessibility">
- subagent_type: client_accessibility
  skill_name: client_accessibility
  path: "Agents/client-accessibility/SKILL.md"
  workspace: "Agents/client-accessibility/workspace/"
  access: full
  
  # trigger_keywords для Client Accessibility
  trigger_keywords:
    - "accessibility"
    - "VoiceOver"
    - "Dynamic Type"
    - "contrast ratio"
    - "WCAG compliance"
    - "assistive tech"
  
  # domains: Accessibility Compliance, Inclusive Design, Assistive Technologies, WCAG Standards
  domains:
    - "Accessibility Compliance"
    - "Inclusive Design"
    - "Assistive Technologies"
    - "WCAG Standards"
  
  # capabilities
  capabilities:
    - "VoiceOver integration и testing"
    - "Dynamic Type support для всех экранов"
    - "Contrast ratio compliance (WCAG 2.1 AA)"
    - "Accessibility Inspector integration"
  
  # constraints
  constraints:
    - "iOS Accessibility Framework только"
    - "WCAG 2.1 AA compliance mandatory"
    - "No hardcoded font sizes"
  
  # priority
  priority: high
  
  # context_file
  context_file: "Agents/client-accessibility/SKILL.md"
# </agent>
```

---

#### 13. client_push — Push Notifications Specialist

```yaml
# <agent subagent_type="client_push">
- subagent_type: client_push
  skill_name: client_push
  path: "Agents/client-push/SKILL.md"
  workspace: "Agents/client-push/workspace/"
  access: full
  
  # trigger_keywords для Client Push
  trigger_keywords:
    - "push notifications"
    - "APNs"
    - "notification center"
    - "badge count"
    - "silent push"
    - "local notification"
  
  # domains: Push Notifications, APNs Integration, Notification Center, User Engagement
  domains:
    - "Push Notifications"
    - "APNs Integration"
    - "Notification Center"
    - "User Engagement"
  
  # capabilities
  capabilities:
    - "APNs (Apple Push Notification service) integration"
    - "Local notifications scheduling"
    - "Notification center customization"
    - "Badge count management"
  
  # constraints
  constraints:
    - "iOS UserNotifications Framework только"
    - "No third-party push libs (Firebase)"
    - "Privacy-first notification handling"
  
  # priority
  priority: medium
  
  # context_file
  context_file: "Agents/client-push/SKILL.md"
# </agent>
```

---

#### 14. client_deep_link — Deep Linking Specialist

```yaml
# <agent subagent_type="client_deep_link">
- subagent_type: client_deep_link
  skill_name: client_deep_link
  path: "Agents/client-deep-link/SKILL.md"
  workspace: "Agents/client-deep-link/workspace/"
  access: full
  
  # trigger_keywords для Client Deep Link
  trigger_keywords:
    - "deep link"
    - "universal link"
    - "app link"
    - "URL scheme"
    - "deferred deep linking"
  
  # domains: Deep Linking, Universal Links, App Navigation, User Journey
  domains:
    - "Deep Linking"
    - "Universal Links"
    - "App Navigation"
    - "User Journey"
  
  # capabilities
  capabilities:
    - "iOS Universal Links setup"
    - "URL schemes configuration"
    - "Deferred deep linking (Firebase)"
    - "App navigation state management"
  
  # constraints
  constraints:
    - "iOS Universal Links только"
    - "No third-party deep linking libs"
    - "Security validation for all links"
  
  # priority
  priority: medium
  
  # context_file
  context_file: "Agents/client-deep-link/SKILL.md"
# </agent>
```

---

#### 15. client_backup — Backup & Restore Specialist (iCloud)

```yaml
# <agent subagent_type="client_backup">
- subagent_type: client_backup
  skill_name: client_backup
  path: "Agents/client-backup/SKILL.md"
  workspace: "Agents/client-backup/workspace/"
  access: full
  
  # trigger_keywords для Client Backup
  trigger_keywords:
    - "iCloud backup"
    - "cloud sync"
    - "data migration"
    - "backup restore"
    - "cloud storage"
  
  # domains: iCloud Sync, Data Backup, Cloud Storage, Data Migration
  domains:
    - "iCloud Sync"
    - "Data Backup"
    - "Cloud Storage"
    - "Data Migration"
  
  # capabilities
  capabilities:
    - "iCloud CloudKit integration"
    - "Automatic backup & restore"
    - "Conflict resolution для данных"
    - "Selective sync (по выбору пользователя)"
  
  # constraints
  constraints:
    - "CloudKit только (iCloud)"
    - "No third-party cloud storage"
    - "Privacy-first data handling"
  
  # priority
  priority: medium
  
  # context_file
  context_file: "Agents/client-backup/SKILL.md"
# </agent>
```

---

#### 16. client_i18n_extended — Additional i18n Specialist (если нужно)

```yaml
# <agent subagent_type="client_localization">
- subagent_type: client_localization
  skill_name: client_localization
  path: "Agents/client-localization/SKILL.md"
  workspace: "Agents/client-localization/workspace/"
  access: full
  
  # trigger_keywords для Client Localization
  trigger_keywords:
    - "localization"
    - "translation strings"
    - "language pack"
    - "locale settings"
  
  # domains: Localization, Translation Management, Locale Configuration
  domains:
    - "Localization"
    - "Translation Management"
    - "Locale Configuration"
  
  # capabilities
  capabilities:
    - "Xcode localization files (.strings)"
    - "String catalog management"
    - "External translation service integration"
  
  # constraints
  constraints:
    - "iOS Localization Framework только"
    - "No hardcoded strings"
  
  # priority
  priority: low
  
  # context_file
  context_file: "Agents/client-localization/SKILL.md"
# </agent>
```

---

## 📊 ИТОГИ ЧАСТИ 2 (Client Domain)

| Секция            | Агентов                         | Статус    |
|-------------------|---------------------------------|-----------|
| **Client Domain** | 16 агентов (iOS, SwiftUI, MVVM) | ✅ ОПИСАНО |

---

## 📌 ЧТО ДАЛЬШЕ?

### Часть 3: Server + AI/ML + QA + Documentation (~23 агента)

- Server domain (server_lead, server_developer, server_qa, server_devops) — 4 агента
- AI/ML Domain (ai_engineer, llm_specialist) — 2 агента
- Additional Client Specialists (client_analytics, client_i18n и др.) — уже описаны в части 2
- QA/Testing specialists — 2 агента
- Documentation writers — 2 агента

---

**Готово к продолжению в Части 3!** 🚀
</parameter>}}] | end_of_message

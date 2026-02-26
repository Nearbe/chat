# 📋 План мигрирования документации проекта Chat

## Часть 3 из 4 — Оставшиеся агенты и специализации

**Дата создания:** 2025-01-15  
**Версия плана:** 1.0  
**Статус:** В процессе выполнения

---

## 📌 ЧАСТЬ 3: ОСТАВШИЕСЯ АГЕНТЫ (~16)

### 🔴 SERVER DOMAIN (4 агента)

#### 1. server_lead — Server Team Lead

```json
{
  "subagent_type": "server_lead",
  "skill_name": "server_lead",
  "path": "Agents/server-lead/SKILL.md",
  "workspace": "Agents/server-lead/workspace/",
  "access": "full",
  
  /* <trigger_keywords>
     Ключевые слова для маршрутизации задач Server Lead */
  "trigger_keywords": [
    "бэкенд", "сервер", "API архитектура", "микросервисы",
    "backend team lead", "архитектура API"
  ],
  /* </trigger_keywords> */
  
  /* <domains>
     Основные домены компетенции Server Lead */
  "domains": ["Backend Architecture", "API Design", "Microservices", "System Design"],
  /* </domains> */
  
  /* <capabilities>
     Что умеет делать этот агент */
  "capabilities": [
    "Проектирование архитектуры бэкенда",
    "Разработка REST/GraphQL API",
    "Микросервисная архитектура",
    "Code review backend кода",
    "Менторинг команды разработчиков"
  ],
  /* </capabilities> */
  
  /* <constraints>
     Ограничения для этого агента */
  "constraints": [
    "Backend только (Swift/Python/Node.js)",
    "RESTful API design patterns",
    "Microservices architecture best practices"
  ],
  /* </constraints> */
  
  /* <priority>
     Приоритет выполнения задач */
  "priority": "critical",
  /* </priority> */
  
  /* <context_file>
     Ссылка на доп. документацию */
  "context_file": "Agents/server-lead/SKILL.md"
  /* </context_file> */
}
/* </agent subagent_type="server_lead"> */
```

---

#### 2. server_developer — Backend Developer

```json
{
  "subagent_type": "server_developer",
  "skill_name": "server_developer",
  "path": "Agents/server-developer/SKILL.md",
  "workspace": "Agents/server-developer/workspace/",
  "access": "full",
  
  /* <trigger_keywords>
     Ключевые слова для маршрутизации задач Server Developer */
  "trigger_keywords": [
    "API endpoint", "REST API", "GraphQL query",
    "backend logic", "database query", "authentication middleware"
  ],
  /* </trigger_keywords> */
  
  /* <domains>
     Основные домены компетенции Server Developer */
  "domains": ["Backend Development", "API Design", "Database Integration", "Authentication"],
  /* </domains> */
  
  /* <capabilities>
     Что умеет делать этот агент */
  "capabilities": [
    "Разработка REST/GraphQL API endpoints",
    "Работа с базами данных (PostgreSQL, MongoDB)",
    "JWT/OAuth2 аутентификация",
    "API rate limiting и caching",
    "Error handling и logging"
  ],
  /* </capabilities> */
  
  /* <constraints>
     Ограничения для этого агента */
  "constraints": [
    "Backend только (Swift/Python/Node.js)",
    "RESTful API design patterns",
    "Database migrations best practices"
  ],
  /* </constraints> */
  
  /* <priority>
     Приоритет выполнения задач */
  "priority": "high",
  /* </priority> */
  
  /* <context_file>
     Ссылка на доп. документацию */
  "context_file": "Agents/server-developer/SKILL.md"
  /* </context_file> */
}
/* </agent subagent_type="server_developer"> */
```

---

#### 3. server_qa — Backend QA Engineer

```json
{
  "subagent_type": "server_qa",
  "skill_name": "server_qa",
  "path": "Agents/server-qa/SKILL.md",
  "workspace": "Agents/server-qa/workspace/",
  "access": "full",
  
  /* <trigger_keywords>
     Ключевые слова для маршрутизации задач Server QA */
  "trigger_keywords": [
    "API тестирование", "integration tests", "Postman collection",
    "JMeter load test", "API validation", "backend testing"
  ],
  /* </trigger_keywords> */
  
  /* <domains>
     Основные домены компетенции Server QA */
  "domains": ["Backend Testing", "API Validation", "Performance Testing", "CI/CD"],
  /* </domains> */
  
  /* <capabilities>
     Что умеет делать этот агент */
  "capabilities": [
    "Тестирование REST/GraphQL API endpoints",
    "Load testing (JMeter, k6)",
    "CI/CD интеграция тестов",
    "API documentation testing (OpenAPI/Swagger)",
    "Security testing (OWASP Top 10)"
  ],
  /* </capabilities> */
  
  /* <constraints>
     Ограничения для этого агента */
  "constraints": [
    "Backend API только",
    "REST/GraphQL protocols",
    "Performance benchmarks (95th percentile)"
  ],
  /* </constraints> */
  
  /* <priority>
     Приоритет выполнения задач */
  "priority": "high",
  /* </priority> */
  
  /* <context_file>
     Ссылка на доп. документацию */
  "context_file": "Agents/server-qa/SKILL.md"
  /* </context_file> */
}
/* </agent subagent_type="server_qa"> */
```

---

#### 4. server_devops — DevOps Engineer

```json
{
  "subagent_type": "server_devops",
  "skill_name": "server_devops",
  "path": "Agents/server-devops/SKILL.md",
  "workspace": "Agents/server-devops/workspace/",
  "access": "full",
  
  /* <trigger_keywords>
     Ключевые слова для маршрутизации задач Server DevOps */
  "trigger_keywords": [
    "CI/CD pipeline", "Docker container", "Kubernetes cluster",
    "AWS deployment", "infrastructure as code", "monitoring"
  ],
  /* </trigger_keywords> */
  
  /* <domains>
     Основные домены компетенции Server DevOps */
  "domains": ["DevOps", "Cloud Infrastructure", "CI/CD Pipelines", "Monitoring"],
  /* </domains> */
  
  /* <capabilities>
     Что умеет делать этот агент */
  "capabilities": [
    "Настройка CI/CD (GitHub Actions, GitLab CI)",
    "Docker & Kubernetes orchestration",
    "AWS/GCP/Azure deployment strategies",
    "Monitoring & logging (Prometheus, Grafana, ELK)",
    "Infrastructure as Code (Terraform, Pulumi)"
  ],
  /* </capabilities> */
  
  /* <constraints>
     Ограничения для этого агента */
  "constraints": [
    "Cloud-native architecture only",
    "Infrastructure as Code (Terraform)",
    "Security compliance (SOC2, GDPR)"
  ],
  /* </constraints> */
  
  /* <priority>
     Приоритет выполнения задач */
  "priority": "high",
  /* </priority> */
  
  /* <context_file>
     Ссылка на доп. документацию */
  "context_file": "Agents/server-devops/SKILL.md"
  /* </context_file> */
}
/* </agent subagent_type="server_devops"> */
```

---

### 🔵 CLIENT DOMAIN (дополнительные специалисты — 6 агентов)

#### 5. client_analytics — Analytics & Metrics Specialist

```json
{
  "subagent_type": "client_analytics",
  "skill_name": "client_analytics",
  "path": "Agents/client-analytics/SKILL.md",
  "workspace": "Agents/client-analytics/workspace/",
  "access": "full",
  
  /* <trigger_keywords>
     Ключевые слова для маршрутизации задач Client Analytics */
  "trigger_keywords": [
    "analytics", "metrics", "tracking events",
    "user behavior", "conversion funnel", "A/B testing"
  ],
  /* </trigger_keywords> */
  
  /* <domains>
     Основные домены компетенции Client Analytics */
  "domains": ["Product Analytics", "User Tracking", "Metrics Dashboard", "Privacy Compliance"],
  /* </domains> */
  
  /* <capabilities>
     Что умеет делать этот агент */
  "capabilities": [
    "Интеграция analytics (Firebase, Mixpanel)",
    "Tracking custom events и user journeys",
    "A/B testing setup и анализ результатов",
    "Privacy compliance (GDPR, CCPA)"
  ],
  /* </capabilities> */
  
  /* <constraints>
     Ограничения для этого агента */
  "constraints": [
    "iOS Analytics Framework только",
    "No third-party tracking without consent",
    "Privacy-first approach"
  ],
  /* </constraints> */
  
  /* <priority>
     Приоритет выполнения задач */
  "priority": "medium",
  /* </priority> */
  
  /* <context_file>
     Ссылка на доп. документацию */
  "context_file": "Agents/client-analytics/SKILL.md"
  /* </context_file> */
}
/* </agent subagent_type="client_analytics"> */
```

---

#### 6. client_i18n — Internationalization Specialist

```json
{
  "subagent_type": "client_i18n",
  "skill_name": "client_i18n",
  "path": "Agents/client-i18n/SKILL.md",
  "workspace": "Agents/client-i18n/workspace/",
  "access": "full",
  
  /* <trigger_keywords>
     Ключевые слова для маршрутизации задач Client i18n */
  "trigger_keywords": [
    "i18n", "localization", "l10n", "translations",
    "multilingual", "RTL support", "date formats"
  ],
  /* </trigger_keywords> */
  
  /* <domains>
     Основные домены компетенции Client i18n */
  "domains": ["Internationalization", "Localization", "Cultural Adaptation", "Accessibility"],
  /* </domains> */
  
  /* <capabilities>
     Что умеет делать этот агент */
  "capabilities": [
    "Настройка iOS localization (Localizable.strings)",
    "RTL languages support (Arabic, Hebrew)",
    "Dynamic content adaptation для разных культур",
    "Date/time/currency formatting"
  ],
  /* </capabilities> */
  
  /* <constraints>
     Ограничения для этого агента */
  "constraints": [
    "iOS Localization Framework только",
    "No hardcoded strings",
    "Cultural sensitivity guidelines"
  ],
  /* </constraints> */
  
  /* <priority>
     Приоритет выполнения задач */
  "priority": "medium",
  /* </priority> */
  
  /* <context_file>
     Ссылка на доп. документацию */
  "context_file": "Agents/client-i18n/SKILL.md"
  /* </context_file> */
}
/* </agent subagent_type="client_i18n"> */
```

---

#### 7. client_accessibility — Accessibility Specialist

```json
{
  "subagent_type": "client_accessibility",
  "skill_name": "client_accessibility",
  "path": "Agents/client-accessibility/SKILL.md",
  "workspace": "Agents/client-accessibility/workspace/",
  "access": "full",
  
  /* <trigger_keywords>
     Ключевые слова для маршрутизации задач Client Accessibility */
  "trigger_keywords": [
    "accessibility", "VoiceOver", "Dynamic Type",
    "contrast ratio", "WCAG compliance", "assistive tech"
  ],
  /* </trigger_keywords> */
  
  /* <domains>
     Основные домены компетенции Client Accessibility */
  "domains": ["Accessibility Compliance", "Inclusive Design", "Assistive Technologies", "WCAG Standards"],
  /* </domains> */
  
  /* <capabilities>
     Что умеет делать этот агент */
  "capabilities": [
    "VoiceOver integration и testing",
    "Dynamic Type support для всех экранов",
    "Contrast ratio compliance (WCAG 2.1 AA)",
    "Accessibility Inspector integration"
  ],
  /* </capabilities> */
  
  /* <constraints>
     Ограничения для этого агента */
  "constraints": [
    "iOS Accessibility Framework только",
    "WCAG 2.1 AA compliance mandatory",
    "No hardcoded font sizes"
  ],
  /* </constraints> */
  
  /* <priority>
     Приоритет выполнения задач */
  "priority": "high",
  /* </priority> */
  
  /* <context_file>
     Ссылка на доп. документацию */
  "context_file": "Agents/client-accessibility/SKILL.md"
  /* </context_file> */
}
/* </agent subagent_type="client_accessibility"> */
```

---

#### 8. client_push — Push Notifications Specialist

```json
{
  "subagent_type": "client_push",
  "skill_name": "client_push",
  "path": "Agents/client-push/SKILL.md",
  "workspace": "Agents/client-push/workspace/",
  "access": "full",
  
  /* <trigger_keywords>
     Ключевые слова для маршрутизации задач Client Push */
  "trigger_keywords": [
    "push notifications", "APNs", "notification center",
    "badge count", "silent push", "local notification"
  ],
  /* </trigger_keywords> */
  
  /* <domains>
     Основные домены компетенции Client Push */
  "domains": ["Push Notifications", "APNs Integration", "Notification Center", "User Engagement"],
  /* </domains> */
  
  /* <capabilities>
     Что умеет делать этот агент */
  "capabilities": [
    "APNs (Apple Push Notification service) integration",
    "Local notifications scheduling",
    "Notification center customization",
    "Badge count management"
  ],
  /* </capabilities> */
  
  /* <constraints>
     Ограничения для этого агента */
  "constraints": [
    "iOS UserNotifications Framework только",
    "No third-party push libs (Firebase)",
    "Privacy-first notification handling"
  ],
  /* </constraints> */
  
  /* <priority>
     Приоритет выполнения задач */
  "priority": "medium",
  /* </priority> */
  
  /* <context_file>
     Ссылка на доп. документацию */
  "context_file": "Agents/client-push/SKILL.md"
  /* </context_file> */
}
/* </agent subagent_type="client_push"> */
```

---

#### 9. client_deep_link — Deep Linking Specialist

```json
{
  "subagent_type": "client_deep_link",
  "skill_name": "client_deep_link",
  "path": "Agents/client-deep-link/SKILL.md",
  "workspace": "Agents/client-deep-link/workspace/",
  "access": "full",
  
  /* <trigger_keywords>
     Ключевые слова для маршрутизации задач Client Deep Link */
  "trigger_keywords": [
    "deep link", "universal link", "app link",
    "URL scheme", "deferred deep linking"
  ],
  /* </trigger_keywords> */
  
  /* <domains>
     Основные домены компетенции Client Deep Link */
  "domains": ["Deep Linking", "Universal Links", "App Navigation", "User Journey"],
  /* </domains> */
  
  /* <capabilities>
     Что умеет делать этот агент */
  "capabilities": [
    "iOS Universal Links setup",
    "URL schemes configuration",
    "Deferred deep linking (Firebase)",
    "App navigation state management"
  ],
  /* </capabilities> */
  
  /* <constraints>
     Ограничения для этого агента */
  "constraints": [
    "iOS Universal Links только",
    "No third-party deep linking libs",
    "Security validation for all links"
  ],
  /* </constraints> */
  
  /* <priority>
     Приоритет выполнения задач */
  "priority": "medium",
  /* </priority> */
  
  /* <context_file>
     Ссылка на доп. документацию */
  "context_file": "Agents/client-deep-link/SKILL.md"
  /* </context_file> */
}
/* </agent subagent_type="client_deep_link"> */
```

---

#### 10. client_backup — Backup & Restore Specialist (iCloud)

```json
{
  "subagent_type": "client_backup",
  "skill_name": "client_backup",
  "path": "Agents/client-backup/SKILL.md",
  "workspace": "Agents/client-backup/workspace/",
  "access": "full",
  
  /* <trigger_keywords>
     Ключевые слова для маршрутизации задач Client Backup */
  "trigger_keywords": [
    "iCloud backup", "cloud sync", "data migration",
    "backup restore", "cloud storage"
  ],
  /* </trigger_keywords> */
  
  /* <domains>
     Основные домены компетенции Client Backup */
  "domains": ["iCloud Sync", "Data Backup", "Cloud Storage", "Data Migration"],
  /* </domains> */
  
  /* <capabilities>
     Что умеет делать этот агент */
  "capabilities": [
    "iCloud CloudKit integration",
    "Automatic backup & restore",
    "Conflict resolution для данных",
    "Selective sync (по выбору пользователя)"
  ],
  /* </capabilities> */
  
  /* <constraints>
     Ограничения для этого агента */
  "constraints": [
    "CloudKit только (iCloud)",
    "No third-party cloud storage",
    "Privacy-first data handling"
  ],
  /* </constraints> */
  
  /* <priority>
     Приоритет выполнения задач */
  "priority": "medium",
  /* </priority> */
  
  /* <context_file>
     Ссылка на доп. документацию */
  "context_file": "Agents/client-backup/SKILL.md"
  /* </context_file> */
}
/* </agent subagent_type="client_backup"> */
```

---

### 🔴 QA/TESTING DOMAIN (2 агента)

#### 11. qa_mobile — Mobile QA Engineer (iOS + Android)

```json
{
  "subagent_type": "qa_mobile",
  "skill_name": "qa_mobile",
  "path": "Agents/qa-mobile/SKILL.md",
  "workspace": "Agents/qa-mobile/workspace/",
  "access": "full",
  
  /* <trigger_keywords>
     Ключевые слова для маршрутизации задач QA Mobile */
  "trigger_keywords": [
    "mobile testing", "cross-platform test",
    "device farm", "emulator testing"
  ],
  /* </trigger_keywords> */
  
  /* <domains>
     Основные домены компетенции QA Mobile */
  "domains": ["Mobile Testing", "Cross-Platform QA", "Device Compatibility", "Test Automation"],
  /* </domains> */
  
  /* <capabilities>
     Что умеет делать этот агент */
  "capabilities": [
    "iOS + Android cross-platform testing",
    "Device farm integration (BrowserStack, Sauce Labs)",
    "Emulator/simulator testing strategies",
    "Performance benchmarks на разных устройствах"
  ],
  /* </capabilities> */
  
  /* <constraints>
     Ограничения для этого агента */
  "constraints": [
    "iOS + Android platforms only",
    "No web testing (separate QA Web)",
    "Device compatibility matrix"
  ],
  /* </constraints> */
  
  /* <priority>
     Приоритет выполнения задач */
  "priority": "high",
  /* </priority> */
  
  /* <context_file>
     Ссылка на доп. документацию */
  "context_file": "Agents/qa-mobile/SKILL.md"
  /* </context_file> */
}
/* </agent subagent_type="qa_mobile"> */
```

---

#### 12. qa_automation — Test Automation Engineer

```json
{
  "subagent_type": "qa_automation",
  "skill_name": "qa_automation",
  "path": "Agents/qa-automation/SKILL.md",
  "workspace": "Agents/qa-automation/workspace/",
  "access": "full",
  
  /* <trigger_keywords>
     Ключевые слова для маршрутизации задач QA Automation */
  "trigger_keywords": [
    "test automation", "CI/CD pipeline test",
    "Selenium", "Appium", "unit test coverage"
  ],
  /* </trigger_keywords> */
  
  /* <domains>
     Основные домены компетенции QA Automation */
  "domains": ["Test Automation", "CI/CD Integration", "Code Coverage", "Performance Testing"],
  /* </domains> */
  
  /* <capabilities>
     Что умеет делать этот агент */
  "capabilities": [
    "iOS UI automation (XCUITest)",
    "CI/CD pipeline integration (GitHub Actions, Bitrise)",
    "Code coverage analysis (Xcode Coverage Report)",
    "Performance testing benchmarks"
  ],
  /* </capabilities> */
  
  /* <constraints>
     Ограничения для этого агента */
  "constraints": [
    "iOS automation only",
    "No manual test scripts",
    "Minimum 80% code coverage target"
  ],
  /* </constraints> */
  
  /* <priority>
     Приоритет выполнения задач */
  "priority": "high",
  /* </priority> */
  
  /* <context_file>
     Ссылка на доп. документацию */
  "context_file": "Agents/qa-automation/SKILL.md"
  /* </context_file> */
}
/* </agent subagent_type="qa_automation"> */
```

---

### 🟡 DOCUMENTATION & CONTENT (2 агента)

#### 13. docs_writer — Technical Documentation Writer

```json
{
  "subagent_type": "docs_writer",
  "skill_name": "docs_writer",
  "path": "Agents/docs-writer/SKILL.md",
  "workspace": "Agents/docs-writer/workspace/",
  "access": "full",
  
  /* <trigger_keywords>
     Ключевые слова для маршрутизации задач Docs Writer */
  "trigger_keywords": [
    "documentation", "README update",
    "API docs", "user guide"
  ],
  /* </trigger_keywords> */
  
  /* <domains>
     Основные домены компетенции Docs Writer */
  "domains": ["Technical Writing", "Documentation Standards", "API Documentation", "User Guides"],
  /* </domains> */
  
  /* <capabilities>
     Что умеет делать этот агент */
  "capabilities": [
    "Markdown documentation writing",
    "OpenAPI/Swagger API docs generation",
    "README.md updates и best practices",
    "Code comments и docstrings"
  ],
  /* </capabilities> */
  
  /* <constraints>
     Ограничения для этого агента */
  "constraints": [
    "Markdown format only",
    "No third-party docs platforms",
    "Consistent style guide compliance"
  ],
  /* </constraints> */
  
  /* <priority>
     Приоритет выполнения задач */
  "priority": "medium",
  /* </priority> */
  
  /* <context_file>
     Ссылка на доп. документацию */
  "context_file": "Agents/docs-writer/SKILL.md"
  /* </context_file> */
}
/* </agent subagent_type="docs_writer"> */
```

---

#### 14. content_creator — Content & Marketing Writer

```json
{
  "subagent_type": "content_creator",
  "skill_name": "content_creator",
  "path": "Agents/content-creator/SKILL.md",
  "workspace": "Agents/content-creator/workspace/",
  "access": "full",
  
  /* <trigger_keywords>
     Ключевые слова для маршрутизации задач Content Creator */
  "trigger_keywords": [
    "marketing content", "app store description",
    "social media post", "blog article"
  ],
  /* </trigger_keywords> */
  
  /* <domains>
     Основные домены компетенции Content Creator */
  "domains": ["Content Marketing", "App Store Optimization", "Social Media", "Blog Writing"],
  /* </domains> */
  
  /* <capabilities>
     Что умеет делать этот агент */
  "capabilities": [
    "App Store description writing",
    "ASO (App Store Optimization) keywords",
    "Social media posts для продвижения",
    "Blog articles о новых фичах"
  ],
  /* </capabilities> */
  
  /* <constraints>
     Ограничения для этого агента */
  "constraints": [
    "English + Russian languages",
    "No technical jargon for marketing",
    "Brand voice consistency"
  ],
  /* </constraints> */
  
  /* <priority>
     Приоритет выполнения задач */
  "priority": "low",
  /* </priority> */
  
  /* <context_file>
     Ссылка на доп. документацию */
  "context_file": "Agents/content-creator/SKILL.md"
  /* </context_file> */
}
/* </agent subagent_type="content_creator"> */
```

---

## 📊 ИТОГИ ЧАСТИ 3

| Секция                | Агентов                                                                                               | Статус    |
|-----------------------|-------------------------------------------------------------------------------------------------------|-----------|
| **Server Domain**     | 4 (server_lead, server_developer, server_qa, server_devops)                                           | ✅ ОПИСАНО |
| **Client Additional** | 6 (client_analytics, client_i18n, client_accessibility, client_push, client_deep_link, client_backup) | ✅ ОПИСАНО |
| **QA/Testing**        | 2 (qa_mobile, qa_automation)                                                                          | ✅ ОПИСАНО |
| **Documentation**     | 2 (docs_writer, content_creator)                                                                      | ✅ ОПИСАНО |

---

## 📌 ЧТО ДАЛЬШЕ?

### Часть 4: JSON конфигурация + fallback логика

- `agents_mapping.json` с XML-подобными комментариями для всех 39 агентов
- Fallback логика для CTO (default_subagent)
- Приоритеты и контекстные файлы
- Итоговая статистика мигрирования

---

**Готово к продолжению в Части 4!** 🚀
</parameter>}}] | end_of_message

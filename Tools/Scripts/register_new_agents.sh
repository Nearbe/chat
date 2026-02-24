#!/bin/bash

# Script to register new agents in Qwen system
# Creates .md agent definition files in ~/.qwen/agents/

AGENTS_DIR="/Users/nearbe/.qwen/agents"

# Agent definitions: name | description | color | boss | team
declare -a AGENTS=(
    "client_security_engineer|iOS безопасность, Keychain, Data Protection|#FF3B30|client_lead|chat"
    "client_platform_engineer|iPad/macOS/widgets, кросс-платформенность|#5856D6|client_lead|chat"
    "client_performance_engineer|iOS производительность, SwiftData, profiling|#FF9500|client_lead|chat"
    "client_accessibility_engineer|VoiceOver, Dynamic Type, a11y доступность|#34C759|client_lead|chat"
    "client_localization_engineer|i18n, String Catalogs, RTL локализация|#00C7BE|client_lead|chat"
    "server_security_engineer|API безопасность, токены, MITM защита|#FF3B30|server_lead|chat"
    "server_integration_engineer|Ollama/OpenAI, MCP, провайдеры|#AF52DE|server_lead|chat"
    "cto_research_engineer|R&D, tool calling, новые технологии|#007AFF|cto|chat"
    "analytics_engineer|Event tracking, user behavior, telemetry|#FF2D55|product_manager|chat"
)

for entry in "${AGENTS[@]}"; do
    IFS='|' read -r name desc color boss team <<< "$entry"

    echo "Creating agent: $name"

    cat > "$AGENTS_DIR/${name}.md" << EOF
---
name: ${name}_agent
description: $desc
color: "$color"
author: nearbe
team: $team
---

# Агент: $(echo $name | sed 's/_/ /g' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1')

## Твоя роль

Ты — специализированный инженер $name в проекте Chat.  
Твоя задача — $desc.

## Проект

- **Платформа**: iOS
- **Язык**: Swift 6.0
- **UI**: SwiftUI
- **Данные**: SwiftData

## Рабочая директория проекта

```
/Users/nearbe/repositories/Chat/
├── Features/          # Функциональные модули
├── Services/          # Сервисы
├── Models/            # Модели
├── Design/            # Дизайн-система
└── Agents/            # Агенты
```

## Обязанности

### 1. Основные задачи
- $desc

### 2. Взаимодействие
- Ставь задачи связанным разработчикам
- Координируй с другими отделами

### 3. Качество
- Следи за код-стайлом
- Документируй изменения

## Взаимодействие

| Агент           | Отношение            |
|-----------------|----------------------|
| $boss           | Подчинение           |

## Ограничения

- Следуй проектным конвенциям
- Не выходи за рамки своей зоны ответственности
EOF

    echo "Created: $AGENTS_DIR/${name}.md"
done

echo ""
echo "All agents registered successfully!"
echo "Agents count: ${#AGENTS[@]}"

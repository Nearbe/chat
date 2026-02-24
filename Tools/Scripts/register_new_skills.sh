#!/bin/bash

# Script to register new skills in Qwen system
# Creates SKILL.md files in ~/.qwen/skills/

SKILLS_DIR="/Users/nearbe/.qwen/skills"

# Skill definitions: name | description | short_responsibilities
declare -a SKILLS=(
    "client_security_engineer|iOS безопасность, Keychain, Data Protection, уязвимости клиента|Client Lead"
    "client_platform_engineer|iPad, macOS, widgets, кросс-платформенность|Client Lead"
    "client_performance_engineer|iOS производительность, SwiftData, profiling, memory|Client Lead"
    "client_accessibility_engineer|VoiceOver, Dynamic Type, a11y доступность|Client Lead"
    "client_localization_engineer|i18n, String Catalogs, RTL локализация|Client Lead"
    "server_security_engineer|API безопасность, токены, MITM защита|Server Lead"
    "server_integration_engineer|Ollama, OpenAI, MCP, провайдеры|Server Lead"
    "cto_research_engineer|R&D, tool calling, новые технологии|CTO"
    "analytics_engineer|Event tracking, user behavior, telemetry|Product Manager"
)

for entry in "${SKILLS[@]}"; do
    IFS='|' read -r name desc boss <<< "$entry"

    echo "Creating skill: $name"

    mkdir -p "$SKILLS_DIR/$name"

    cat > "$SKILLS_DIR/$name/SKILL.md" << EOF
---
license: MIT
author: Chat Project
name: $name
description: Этот навык следует использовать, когда пользователь обсуждает $desc. Агент отвечает за $desc.
version: 0.1.0
---

# $(echo $name | tr '_' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1')

## Обзор

Специализированный инженер $(echo $name | sed 's/_/ /g').

## Активация

Используйте этот навык когда пользователь обсуждает $desc.

## Подчинение

- **Отчитывается перед**: $boss

## Обязанности

- $desc
EOF

    echo "Created: $SKILLS_DIR/$name/SKILL.md"
done

echo ""
echo "All skills registered successfully!"
echo "Skills count: ${#SKILLS[@]}"

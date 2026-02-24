#!/bin/bash

# Add missing skills to the system

SKILLS_DIR="/Users/nearbe/.qwen/skills"

# Missing skills that need to be added
declare -a MISSING=(
    "client_developer"
    "client_lead"
    "client_qa_lead"
    "designer"
    "designer_lead"
    "designer_qa_lead"
    "devops"
    "devops_lead"
    "devops_qa_lead"
    "documents_lead"
    "head_of_qa"
    "metrics"
    "owner_product_consultant"
    "product_manager"
    "server_developer"
    "server_lead"
    "server_qa_lead"
    "staff_engineer"
)

for name in "${MISSING[@]}"; do
    if [ ! -d "$SKILLS_DIR/$name" ]; then
        echo "Creating: $name"
        mkdir -p "$SKILLS_DIR/$name"
        
        # Map name to description
        case $name in
            client_developer) desc="Клиентский iOS разработчик, реализация UI компонентов" ;;
            client_lead) desc="Лид клиентской iOS разработки, координирует client_developer" ;;
            client_qa_lead) desc="QA лид клиентской части, тестирование UI" ;;
            designer) desc="Дизайнер UI компонентов" ;;
            designer_lead) desc="Лид дизайна, визуальная концепция" ;;
            designer_qa_lead) desc="QA лид визуального тестирования" ;;
            devops) desc="DevOps инженер, скрипты, автоматизация" ;;
            devops_lead) desc="Лид DevOps, CI/CD, инфраструктура" ;;
            devops_qa_lead) desc="QA лид DevOps, тестирование CI/CD" ;;
            documents_lead) desc="Лид документации, API docs" ;;
            head_of_qa) desc="Глава QA, стратегия тестирования" ;;
            metrics) desc="Метрики, analytics, мониторинг" ;;
            owner_product_consultant) desc="Консультант Owner Product, бизнес-требования" ;;
            product_manager) desc="Product Manager, roadmap, планирование" ;;
            server_developer) desc="Серверный разработчик, API интеграция" ;;
            server_lead) desc="Лид серверной разработки, LM Studio API" ;;
            server_qa_lead) desc="QA лид серверной части, API тестирование" ;;
            staff_engineer) desc="Staff Engineer, рефакторинг, стандарты" ;;
            *) desc="Специализированная роль" ;;
        esac

        cat > "$SKILLS_DIR/$name/SKILL.md" << EOF
---
license: MIT
author: Chat Project
name: $name
description: Этот навык следует использовать, когда пользователь обсуждает $desc.
version: 0.1.0
---

# $(echo $name | tr '_' ' ' | awk '{for(i=1;i<=NF;i++) $i=toupper(substr($i,1,1)) tolower(substr($i,2));}1')

## Обзор

$desc

## Активация

Используйте этот навык когда пользователь обсуждает $desc.

## Обязанности

- $desc
EOF
    else
        echo "Already exists: $name"
    fi
done

echo ""
echo "Done! Total Chat-specific skills:"
ls "$SKILLS_DIR" | grep -E "^(client_|server_|designer|devops|head_of|cto|product|owner|hr|documents|staff|metrics|analytics)" | wc -l

#!/bin/bash
# См. документацию: Docs/README.md
# Скрипт для внутренней технической проверки проекта (Lint + Generate + Build + Test)
# Предназначен для ИИ-помощника или разработчика.
# Обеспечивает полную информацию о состоянии тестов и качестве кода.
# В конце выполняется автоматический коммит и push.

set -e
set -o pipefail

# Убедимся, что мы в корне проекта
cd "$(dirname "$0")"

# Для технической проверки используем симулятор. 
DEVICE="platform=iOS Simulator,name=iPhone 16 Pro Max"

echo "🏗️ Генерация проекта (XcodeGen)..."
if which xcodegen >/dev/null; then
  xcodegen generate
else
  echo "❌ Ошибка: XcodeGen не установлен."
  exit 1
fi

echo "🔍 Запуск SwiftLint..."
if which swiftlint >/dev/null; then
  swiftlint --strict
else
  echo "⚠️ SwiftLint не установлен."
fi

echo "🎨 Генерация ресурсов (SwiftGen)..."
if which swiftgen >/dev/null; then
  swiftgen
  # Fix for Swift 6 concurrency in generated code
  if [ -f "Design/Generated/Assets.swift" ]; then
    sed -i '' 's/internal final class ColorAsset/internal final class ColorAsset: @unchecked Sendable/' Design/Generated/Assets.swift
  fi
else
  echo "⚠️ SwiftGen не установлен."
fi

echo "🔨 Сборка проекта (Build Debug)..."
xcodebuild -quiet -project Chat.xcodeproj -scheme Chat -configuration Debug -destination "$DEVICE" build CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO

echo "🧪 Запуск тестов (Test)..."
rm -rf TestResult.xcresult
xcodebuild -project Chat.xcodeproj -scheme Chat -destination "$DEVICE" -enableCodeCoverage YES -resultBundlePath TestResult.xcresult test CODE_SIGNING_ALLOWED=NO CODE_SIGNING_REQUIRED=NO | grep -E "Test Suite|passed|failed|skipped"

# echo "📊 Проверка покрытия кода (Code Coverage)..."
# # Получаем отчет о покрытии
# # Если xcrun xccov не находит данные, скрипт должен упасть (set -e это обеспечит)
# COVERAGE_JSON=$(xcrun xccov view --report --json TestResult.xcresult)
# 
# # Извлекаем процент покрытия для основного таргета (Chat.app)
# # Используем python3 для парсинга JSON
# COVERAGE=$(echo "$COVERAGE_JSON" | python3 -c "
# import sys, json
# data = json.load(sys.stdin)
# # Ищем основной таргет приложения
# target = next((t for t in data.get('targets', []) if t.get('name') == 'Chat.app'), None)
# if target:
#     print(int(target.get('lineCoverage', 0) * 100))
# else:
#     # Если таргет не найден, пробуем взять общее покрытие
#     print(int(data.get('lineCoverage', 0) * 100))
# ")
# 
# echo "Текущее покрытие: $COVERAGE%"
# 
# if [ "$COVERAGE" -lt 100 ]; then
#   echo "❌ Ошибка: Покрытие кода составляет $COVERAGE%, а требуется 100%!"
#   echo "Пожалуйста, добавьте тесты для всех непокрытых участков кода перед коммитом."
#   exit 1
# fi
# 
# echo "✅ Проверка покрытия пройдена (100%)!"

echo "📦 Сборка релизной версии (Release Build)..."
xcodebuild -quiet -project Chat.xcodeproj -scheme Chat -configuration Release \
    -destination "generic/platform=iOS" \
    SYMROOT="$(pwd)/build" \
    build

echo "✅ Техническая проверка завершена!"

# --- Новая логика коммита и отправки ---
MESSAGE=${1:-"Automatic commit after successful verification"}

if [ -n "$(git status --porcelain)" ]; then
  echo "📦 Добавление изменений в индекс..."
  git add .
  
  echo "💾 Коммит изменений: '$MESSAGE'..."
  git commit -m "$MESSAGE"
  
  echo "📤 Отправка в удаленный репозиторий (push)..."
  git push
  
  echo "🚀 Код закоммичен и отправлен в репозиторий!"
else
  echo "ℹ️ Изменений не обнаружено, коммит не требуется."
fi

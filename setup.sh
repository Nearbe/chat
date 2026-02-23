#!/bin/bash
# Скрипт подготовки проекта к работе (XcodeGen + SwiftGen)

set -e
cd "$(dirname "$0")"

echo "🏗️ Генерация Xcode проекта..."
if which xcodegen >/dev/null; then
  xcodegen generate
else
  echo "❌ Ошибка: XcodeGen не установлен. Установите его: 'brew install xcodegen'"
  exit 1
fi

echo "🎨 Генерация ресурсов (SwiftGen)..."
if which swiftgen >/dev/null; then
  swiftgen
  # Fix for Swift 6 concurrency in generated code
  if [ -f "Design/Generated/Assets.swift" ]; then
    sed -i '' 's/internal final class ColorAsset/internal final class ColorAsset: @unchecked Sendable/' Design/Generated/Assets.swift
  fi
else
  echo "⚠️ Предупреждение: SwiftGen не установлен."
fi

echo "✅ Проект готов к работе!"

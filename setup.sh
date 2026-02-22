#!/bin/bash

set -e

echo "Генерация Xcode проекта..."
xcodegen generate

echo "Проект успешно сгенерирован!"
echo "Открытие проекта в Xcode..."

open Chat.xcodeproj

echo "Готово!"

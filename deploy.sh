#!/bin/bash

# Скрипт для сборки и деплоя приложения на реальное устройство
# Остановка при любой ошибке
set -e

# Переход в директорию скрипта
cd "$(dirname "$0")"

# Переменные конфигурации
DEVICE="Saint Celestine" # Имя устройства
APP_PATH=~/Library/Developer/Xcode/DerivedData/Chat-*/Build/Products/Release-iphoneos/Chat.app # Путь к собранному приложению

# Сборка проекта через xcodebuild
echo "🔨 Сборка проекта (Build)..."
xcodebuild -project Chat.xcodeproj -scheme Chat -configuration Release \
    -destination "platform=iOS,name=$DEVICE" \
    build

# Установка приложения на устройство
echo "📱 Установка на устройство (Install)..."
xcrun devicectl device install app --device "$DEVICE" $APP_PATH

# Запуск приложения на устройстве
echo "🚀 Запуск (Launch)..."
xcrun devicectl device process launch --device "$DEVICE" ru.nearbe.chat

echo "✅ Готово!"

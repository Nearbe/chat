#!/bin/bash
set -e

cd "$(dirname "$0")"

DEVICE="Saint Celestine"
APP_PATH=~/Library/Developer/Xcode/DerivedData/Chat-*/Build/Products/Release-iphoneos/Chat.app

echo "🔨 Build..."
xcodebuild -project Chat.xcodeproj -scheme Chat -configuration Release \
    -destination "platform=iOS,name=$DEVICE" \
    build

echo "📱 Install..."
xcrun devicectl device install app --device "$DEVICE" $APP_PATH

echo "🚀 Launch..."
xcrun devicectl device process launch --device "$DEVICE" ru.nearbe.chat

echo "✅ Done!"

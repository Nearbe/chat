#!/bin/zsh
# Обёртка для запуска check с фильтрацией мусора от swift run

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
BINARY="$SCRIPT_DIR/Tools/Scripts/.build/debug/scripts"

# Фильтруем вывод: убираем служебные строки swift/JetBrains
exec "$BINARY" check "$@" 2>&1 | grep -v -E "^\[\d+/\d+\]" | grep -v "DYLD_LIBRARY_PATH" | grep -v "DYLD_FRAMEWORK_PATH" | grep -v "DerivedData" | grep -v "JetBrains" | grep -v "Build/Products" | grep -v "Building for debugging"

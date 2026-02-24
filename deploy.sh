#!/bin/bash
# Deploy Script - Автоматическое разворачивание окружения проекта
# Запускать из корневой директории проекта

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_DIR="$HOME/bin"

echo "🚀 Разворачивание окружения проекта..."

# Проверка и установка Homebrew
if ! command -v brew &> /dev/null; then
    echo "⚠️  Homebrew не найден. Установите: https://brew.sh"
    exit 1
fi

# Проверка и установка инструментов
echo "📦 Проверка инструментов..."

install_or_skip() {
    local tool=$1
    local brew_name=$2
    
    if command -v "$tool" &> /dev/null; then
        echo "  ✅ $tool уже установлен"
    else
        echo "  📥 Установка $tool..."
        brew install "$brew_name"
    fi
}

install_or_skip "xcodegen" "xcodegen"
install_or_skip "swiftgen" "swiftgen"
install_or_skip "swiftlint" "swiftlint"

# Создание bin директории если нет
if [ ! -d "$BIN_DIR" ]; then
    mkdir -p "$BIN_DIR"
    echo "📁 Создана директория $BIN_DIR"
fi

# Сборка бинарника скриптов
echo "🔨 Сборка бинарника скриптов..."
cd "$SCRIPT_DIR/Tools/Scripts"
swift build -c release

# Проверка что бинарник собрался
BINARY="$SCRIPT_DIR/Tools/Scripts/.build/arm64-apple-macosx/release/scripts"
if [ ! -f "$BINARY" ]; then
    echo "❌ Ошибка: бинарник не собран"
    exit 1
fi

echo "  ✅ Бинарник собран"

# Создание обёрток
echo "📝 Создание системных обёрток..."

# chat-scripts обёртка
cat > "$BIN_DIR/chat-scripts" << 'WRAPPER_EOF'
#!/bin/bash
# Chat Scripts - System-wide wrapper

# Ищем корень проекта от расположения скрипта
find_project_root() {
    local script_dir="$(cd "$(dirname "$0")" && pwd)"
    local current="$script_dir"
    
    while [ "$current" != "/" ]; do
        if [ -f "$current/ChatApp.swift" ] || [ -f "$current/project.yml" ]; then
            echo "$current"
            return 0
        fi
        current="$(dirname "$current")"
    done
    
    # Fallback: ищем от текущей директории
    current="$(pwd)"
    while [ "$current" != "/" ]; do
        if [ -f "$current/ChatApp.swift" ] || [ -f "$current/project.yml" ]; then
            echo "$current"
            return 0
        fi
        current="$(dirname "$current")"
    done
    
    # Git fallback
    git_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [ -n "$git_root" ] && [ -f "$git_root/project.yml" ]; then
        echo "$git_root"
        return 0
    fi
    
    # Special case: если скрипт в ~/bin, пробуем типичные пути
    if [[ "$script_dir" == "$HOME/bin" ]]; then
        for repo in "$HOME/repositories/Chat" "$HOME/Chat" "$HOME/projects/Chat"; do
            if [ -f "$repo/project.yml" ]; then
                echo "$repo"
                return 0
            fi
        done
    fi
    
    return 1
}

PROJECT_ROOT="$(find_project_root)"

if [ -z "$PROJECT_ROOT" ]; then
    echo "Error: Cannot find Chat project root"
    exit 1
fi

if [ ! -d "$PROJECT_ROOT/.git" ]; then
    echo "Error: $PROJECT_ROOT is not a git repository"
    exit 1
fi

BINARY="$PROJECT_ROOT/Tools/Scripts/.build/arm64-apple-macosx/release/scripts"

if [ ! -f "$BINARY" ]; then
    echo "Binary not found. Building..."
    cd "$PROJECT_ROOT/Tools/Scripts"
    swift build -c release

    if [ ! -f "$BINARY" ]; then
        echo "Error: Failed to build scripts binary"
        exit 1
    fi
fi

exec "$BINARY" "$@"
WRAPPER_EOF

chmod +x "$BIN_DIR/chat-scripts"

# Создание команд Setup, Check, Ship
for cmd in Setup Check Ship DownloadDocs UpdateDocsLinks ConfigureSudo; do
    # Преобразуем в kebab-case: UpdateDocsLinks -> update-docs-links
    lowercase_cmd=$(echo "$cmd" | sed 's/\([A-Z]\)/-\1/g' | tr '[:upper:]' '[:lower:]' | sed 's/^-//')
    wrapper="#!/bin/bash
SCRIPT_DIR=\"\$(cd \"\$(dirname \"\$0\")\" && pwd)\"
EXEC=\"\$SCRIPT_DIR/chat-scripts\"
exec \$EXEC $lowercase_cmd \"\$@\"
"
    echo "$wrapper" > "$BIN_DIR/$cmd"
    chmod +x "$BIN_DIR/$cmd"
done

echo ""
echo "✅ Готово!"
echo ""
echo "Доступные команды:"
echo "  Setup          - Подготовка проекта"
echo "  Check          - Линтинг + сборка + тесты + пуш"
echo "  Ship           - Релиз + деплой"
echo ""
echo "Добавьте $BIN_DIR в PATH если ещё не добавлен:"
echo "  echo 'export PATH=\$PATH:$BIN_DIR' >> ~/.zshrc"

#!/bin/bash
# Chat Scripts - System-wide wrapper
# Finds the project root and runs the scripts binary

# Ищем корневую директорию проекта несколькими способами
find_project_root() {
    local current="$1"
    
    # 1. Ищем вверх по дереву директорий
    while [ "$current" != "/" ]; do
        if [ -f "$current/ChatApp.swift" ] || [ -f "$current/project.yml" ]; then
            echo "$current"
            return 0
        fi
        current="$(dirname "$current")"
    done
    
    # 2. Пробуем найти по git remote
    local git_root
    git_root=$(git rev-parse --show-toplevel 2>/dev/null)
    if [ -n "$git_root" ] && [ -f "$git_root/project.yml" ]; then
        echo "$git_root"
        return 0
    fi
    
    return 1
}

PROJECT_ROOT="$(find_project_root "$(pwd)")"

if [ -z "$PROJECT_ROOT" ]; then
    echo "Error: Cannot find Chat project root"
    echo "Please run this command from within the Chat project directory"
    exit 1
fi

# Проверяем что это git репозиторий
if [ ! -d "$PROJECT_ROOT/.git" ]; then
    echo "Error: $PROJECT_ROOT is not a git repository"
    exit 1
fi

BINARY="$PROJECT_ROOT/Tools/Scripts/.build/arm64-apple-macosx/release/scripts"

if [ ! -f "$BINARY" ]; then
    echo "Binary not found. Building..."
    cd "$PROJECT_ROOT"
    swift build -c release
    
    if [ ! -f "$BINARY" ]; then
        echo "Error: Failed to build scripts binary"
        exit 1
    fi
fi

cd "$PROJECT_ROOT"
exec "$BINARY" "$@"

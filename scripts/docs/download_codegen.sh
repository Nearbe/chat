#!/bin/bash

# Скрипт для скачивания документации по инструментам кодогенерации
# XcodeGen: https://github.com/yonaskolb/XcodeGen
# SwiftGen: https://github.com/SwiftGen/SwiftGen

XCODEGEN_URL="https://raw.githubusercontent.com/yonaskolb/XcodeGen/master"
SWIFTGEN_URL="https://raw.githubusercontent.com/SwiftGen/SwiftGen/master"
DOCS_DIR="Docs/Codegen"

echo "Updating Codegen tools documentation..."

mkdir -p "$DOCS_DIR/XcodeGen"
mkdir -p "$DOCS_DIR/SwiftGen"

# XcodeGen
curl -s -f "$XCODEGEN_URL/Docs/ProjectSpec.md" -o "$DOCS_DIR/XcodeGen/ProjectSpec.md"
curl -s -f "$XCODEGEN_URL/README.md" -o "$DOCS_DIR/XcodeGen/README.md"

# SwiftGen
curl -s -f "$SWIFTGEN_URL/README.md" -o "$DOCS_DIR/SwiftGen/README.md"
curl -s -f "$SWIFTGEN_URL/Documentation/Usage.md" -o "$DOCS_DIR/SwiftGen/Usage.md"

echo "Codegen tools documentation update complete!"

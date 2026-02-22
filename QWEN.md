# Chat - iOS Chat Application

## Project Overview

- **Project Type:** iOS Native Application (SwiftUI)
- **Bundle ID:** `ru.nearbe.chat`
- **Display Name:** Sexy
- **Target iOS:** 26.2+
- **Swift Version:** 6.0+
- **Architecture:** MVVM with @MainActor

## Project Structure

```
Chat/
├── ChatApp.swift           # @Main entry point
├── project.yml             # XcodeGen configuration
├── setup.sh                # Generation script
├── Data/
│   └── PersistenceController.swift  # SwiftData container
├── Models/
│   ├── APIResponse.swift           # API response models
│   ├── ChatSession.swift           # Chat session model
│   ├── GenerationStats.swift       # Generation statistics
│   ├── Message.swift               # Message model
│   ├── ModelInfo.swift             # Model info model
│   ├── ToolCall.swift              # Tool call model
│   └── ToolDefinition.swift        # Tool definition model
├── Services/
│   ├── DeviceAuthManager.swift     # Keychain-based device auth
│   ├── NetworkService.swift        # Actor-based network layer
│   └── ThemeManager.swift          # Theme management
├── ViewModels/
│   ├── AppConfig.swift             # App configuration (@AppStorage)
│   └── ChatViewModel.swift         # Main chat logic
├── Views/
│   ├── ChatView.swift              # Main chat screen
│   ├── HistoryView.swift           # Chat history
│   ├── ModelPicker.swift           # Model selection
│   ├── SettingsView.swift          # Settings screen
│   └── Components/
│       ├── ContextBar.swift
│       ├── CopyButton.swift
│       ├── GenerationStatsView.swift
│       ├── MessageBubble.swift
│       ├── StatusIndicator.swift
│       ├── ThinkingBlock.swift
│       ├── ToolCallView.swift
│       └── ToolsStatusView.swift
├── Utils/
│   ├── AnyCodable.swift
│   └── Extensions/
│       ├── Color+Hex.swift
│       └── String+Markdown.swift
└── Resources/
    ├── Assets.xcassets
    ├── Chat.entitlements
    └── Info.plist
```

## Building and Running

### Prerequisites
- XcodeGen installed (`brew install xcodegen`)
- Xcode 15.0+
- Apple Developer account with team `QP3VV6YM6A`

### Commands

```bash
# Generate Xcode project
cd /Users/nearbe/repositories/Chat
xcodegen generate

# Build for device (generic)
xcodebuild -project Chat.xcodeproj -scheme Chat -configuration Debug -destination 'generic/platform=iOS' build

# Build for specific device
xcodebuild -project Chat.xcodeproj -scheme Chat -configuration Debug -destination 'platform=iOS,name=Saint Celestine' build
```

## Key Technologies

| Component | Technology |
|-----------|------------|
| UI Framework | SwiftUI |
| Data Storage | SwiftData |
| Network | Actor-based URLSession |
| Auth | Keychain (device-based) |
| API | OpenAI-compatible (LM Studio) |

## Configuration

- **LM Studio URL:** `http://192.168.1.91:64721/v1`
- **Timeout:** 30 seconds (default)
- **Supported Devices:** Saint Celestine, Leonie

### Device Authorization

| Device Name | Keychain Key | Accent Color |
|-------------|--------------|--------------|
| Saint Celestine | `auth_token_nearbe` | #FF9F0A |
| Leonie | `auth_token_kotya` | #007AFF |

## Development Conventions

1. **Concurrency:** Swift 6.0 strict concurrency with `@MainActor` for ViewModels
2. **Storage:** SwiftData for persistence, `@AppStorage` for UserDefaults
3. **Network:** Actor-based `NetworkService` for thread-safe API calls
4. **Comments:** Russian language comments throughout
5. **Code Signing:** Automatic with team `QP3VV6YM6A`
6. **Entitlements:** App sandbox disabled for development

## MCP Tools

- MCP Tools are managed by the LM Studio server
- User can enable/disable via `mcpToolsEnabled` toggle in Settings
- When enabled: `tools: nil` (server provides tools)
- When disabled: `tools: []` (no server tools)

## Important Files

- `project.yml` - XcodeGen configuration (DO NOT regenerate without backing up project settings)
- `ViewModels/AppConfig.swift` - User preferences
- `Services/NetworkService.swift` - API communication
- `Services/DeviceAuthManager.swift` - Device authentication

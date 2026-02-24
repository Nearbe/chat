// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.

import Foundation

/// Сервис для настройки sudo прав.
enum SudoConfigService {
    /// Настраивает беспарольный sudo для ship.
    static func configure() async throws {
        print("🔧  Настройка прав для скрипта доставки...")

        try await buildRelease()

        let binaryPath = getBinaryPath()
        let userName = NSUserName()
        let sudoersLine = "\(userName) ALL=(ALL) NOPASSWD: \(binaryPath) ship"

        printInstructions(binaryPath: binaryPath, sudoersLine: sudoersLine)
    }

    private static func buildRelease() async throws {
        print("🔨  Сборка скриптов в режиме Release...")
        let scriptsPath = "/Users/nearbe/repositories/Chat/Tools/Scripts"
        try await Shell.run("swift build -c release --package-path \"\(scriptsPath)\"")
    }

    private static func getBinaryPath() -> String {
        "/Users/nearbe/repositories/Chat/Tools/Scripts/.build/release/scripts"
    }

    private static func printInstructions(binaryPath: String, sudoersLine: String) {
        print("\nДля того чтобы команда 'ship' работала без пароля, выполните следующую команду:")
        print("\necho \"\(sudoersLine)\" | sudo tee /etc/sudoers.d/chat-scripts\n")

        print("⚠️  ВАЖНО: После этого используйте прямую команду для доставки:")
        print("   \(binaryPath) ship")
        print("\nИли создайте алиас в вашем .zshrc:")
        print("   alias ship-app='\(binaryPath) ship'")
    }
}

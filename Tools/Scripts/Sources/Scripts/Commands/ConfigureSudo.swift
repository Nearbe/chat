// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import ArgumentParser
import Foundation

struct ConfigureSudo: AsyncParsableCommand {
    static let configuration = CommandConfiguration(abstract: "Настройка беспарольного запуска ship через sudo")

    func run() async throws {
        let projectRoot = FileManager.default.currentDirectoryPath
        let scriptsPackagePath = "\(projectRoot)/Tools/Scripts"

        print("🔧  Настройка прав для скрипта доставки (Swift версия)...")

        // Мы предполагаем, что пользователь будет запускать через swift run
        // Но для sudoers лучше иметь абсолютный путь к бинарнику.
        // Поэтому мы сначала собираем его в release.

        print("🔨  Сборка скриптов в режиме Release для стабильного пути...")
        try await Metrics.measure(step: "Build Scripts (Release)") {
            try await Shell.run("swift build -c release --package-path \"\(scriptsPackagePath)\"")
        }

        let binaryPath = "\(scriptsPackagePath)/.build/release/scripts"
        let userName = NSUserName()

        // Добавляем возможность запускать и через sudo напрямую, и через аргументы
        let sudoersLine = "\(userName) ALL=(ALL) NOPASSWD: \(binaryPath) ship"

        print("\nДля того чтобы команда 'ship' работала без пароля, выполните следующую команду:")
        print("\necho \"\(sudoersLine)\" | sudo tee /etc/sudoers.d/chat-scripts\n")

        print("⚠️  ВАЖНО: После этого используйте прямую команду для доставки:")
        print("   \(binaryPath) ship")
        print("\nИли создайте алиас в вашем .zshrc:")
        print("   alias ship-app='\(binaryPath) ship'")
    }
}

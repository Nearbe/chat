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
        try await Shell.run("swift build -c release --package-path \"\(scriptsPackagePath)\"")
        
        let binaryPath = "\(scriptsPackagePath)/.build/release/scripts"
        let userName = NSUserName()
        
        let sudoersLine = "\(userName) ALL=(ALL) NOPASSWD: \(binaryPath) ship"
        
        print("\nДля того чтобы команда 'ship' работала без пароля, выполните следующую команду:")
        print("\necho \"\(sudoersLine)\" | sudo tee /etc/sudoers.d/chat-scripts\n")
        
        print("⚠️  Это позволит запускать 'swift run --package-path Tools/Scripts scripts ship' (или прямой вызов бинарника) без ввода пароля администратора.")
        print("После выполнения этой команды, скрипт сможет выполнять установку на устройство автоматически.")
    }
}

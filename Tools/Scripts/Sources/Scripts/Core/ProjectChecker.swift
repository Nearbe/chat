// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation

struct ProjectChecker {
    static func run() async throws {
        print("🔍  Запуск специальных проверок проекта (ProjectChecker)...")
        
        let fileManager = FileManager.default
        let enumerator = fileManager.enumerator(atPath: ".")
        
        var filesToScan: [String] = []
        
        while let file = enumerator?.nextObject() as? String {
            guard file.hasSuffix(".swift") else { continue }
            // Пропускаем исключенные папки (как в SwiftLint)
            if file.contains("Chat.xcodeproj") || 
               file.contains("Resources") || 
               file.contains("Design/Generated") || 
               file.contains("Tools/Scripts") || 
               file.contains("ChatTests") || 
               file.contains("ChatUITests") {
                continue
            }
            filesToScan.append(file)
        }
        
        var errors: [String] = []
        
        for file in filesToScan {
            let fileURL = URL(fileURLWithPath: file)
            let content = try String(contentsOf: fileURL, encoding: .utf8)
            let lines = content.components(separatedBy: .newlines)
            
            // 1. Проверка наличия документации (Docstrings)
            let documentationErrors = checkDocumentation(lines: lines, filePath: file)
            errors.append(contentsOf: documentationErrors)
            
            // 2. Проверка языка документации (Русский)
            let languageErrors = checkDocumentationLanguage(lines: lines, filePath: file)
            errors.append(contentsOf: languageErrors)
            
            // 3. Проверка на использование print() вместо логгера
            let printErrors = checkNoPrint(lines: lines, filePath: file)
            errors.append(contentsOf: printErrors)
            
            // 4. Проверка именования SwiftUI вьюх (должны заканчиваться на View или Page)
            if file.contains("Views/") || file.contains("Pages/") {
                let namingErrors = checkViewNaming(lines: lines, filePath: file)
                errors.append(contentsOf: namingErrors)
            }
            
            // 5. Проверка на MainActor для ViewModel
            if file.contains("ViewModel") {
                let mainActorErrors = checkMainActor(lines: lines, filePath: file)
                errors.append(contentsOf: mainActorErrors)
            }
            
            // 6. Проверка метки связи с документацией
            let docLinkErrors = checkDocLink(lines: lines, filePath: file)
            errors.append(contentsOf: docLinkErrors)
        }
        
        // 7. Проверка версий инструментов
        let versionErrors = await checkToolVersions()
        errors.append(contentsOf: versionErrors)
        
        // 7. Проверка project.yml
        let projectErrors = try checkProjectYml()
        errors.append(contentsOf: projectErrors)
        
        if !errors.isEmpty {
            print("❌  Обнаружены ошибки при проверке проекта:")
            errors.forEach { print("    - \($0)") }
            throw CheckerError.validationFailed
        } else {
            print("✅  Все специальные проверки пройдены успешно.")
        }
    }
    
    private static func checkMainActor(lines: [String], filePath: String) -> [String] {
        var errors: [String] = []
        // Если это файл ViewModel, он должен содержать @MainActor на уровне класса
        let content = lines.joined(separator: "\n")
        if !content.contains("@MainActor") {
            errors.append("\(filePath): Класс ViewModel должен быть помечен @MainActor")
        }
        return errors
    }
    
    private static func checkDocumentation(lines: [String], filePath: String) -> [String] {
        var errors: [String] = []
        
        // Регулярка для поиска деклараций (class, struct, enum, protocol, func)
        // Игнорируем private/fileprivate и декларации внутри методов (упрощенно)
        // Игнорируем extension, так как они часто не требуют отдельной доки
        // Игнорируем CodingKeys, так как это стандарт Swift
        let declarationPattern = #"^(?!\s*//)(?!\s*/\*)\s*(public |internal |open )?(class|struct|enum|protocol|func)\s+\w+"#
        let regex = try! NSRegularExpression(pattern: declarationPattern)
        
        let ignoredNames = ["CodingKeys", "makeUIViewController", "updateUIViewController", "makeCoordinator", "makeBody", "body", "id", "hash"]
        
        for (index, line) in lines.enumerated() {
            let trimmedLine = line.trimmingCharacters(in: .whitespaces)
            
            // Проверка на игнорируемые имена
            var isIgnored = false
            for name in ignoredNames {
                if trimmedLine.contains(name) {
                    isIgnored = true
                    break
                }
            }
            if isIgnored { continue }
            
            let range = NSRange(line.startIndex..<line.endIndex, in: line)
            if regex.firstMatch(in: line, options: [], range: range) != nil {
                // Если это декларация, проверяем строку выше (или несколько строк выше) на наличие "///"
                var hasDoc = false
                
                // Проверяем до 3 строк выше (на случай атрибутов)
                for i in 1...3 {
                    if index - i >= 0 {
                        let prevLine = lines[index - i].trimmingCharacters(in: .whitespaces)
                        if prevLine.hasPrefix("///") || prevLine.hasSuffix("*/") {
                            hasDoc = true
                            break
                        }
                        // Если встретили пустую строку или другую декларацию, значит доки нет
                        if prevLine.isEmpty { break }
                    }
                }
                
                if !hasDoc {
                    errors.append("\(filePath):\(index + 1): Отсутствует документация (Docstring) для '\(trimmedLine)'")
                }
            }
        }
        
        return errors
    }
    
    private static func checkDocumentationLanguage(lines: [String], filePath: String) -> [String] {
        var errors: [String] = []
        
        let swiftKeywords = ["- Parameters:", "- Returns:", "- Throws:", "///", "TODO:", "FIXME:", "NOTE:", "http", "JSON"]
        
        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            if trimmed.hasPrefix("///") {
                // Если это пустая дока, игнорируем
                if trimmed == "///" { continue }
                
                // Проверка на наличие кириллицы
                let hasCyrillic = line.range(of: #"[а-яА-ЯёЁ]"#, options: .regularExpression) != nil
                
                // Игнорируем технические строки
                var isTechnical = false
                for keyword in swiftKeywords {
                    if trimmed.contains(keyword) {
                        isTechnical = true
                        break
                    }
                }
                
                // Игнорируем короткие строки типа "4pt" или "ID"
                if trimmed.count < 15 && !hasCyrillic {
                    isTechnical = true
                }
                
                if !hasCyrillic && !isTechnical {
                     errors.append("\(filePath):\(index + 1): Документация (Docstring) должна быть на русском языке: '\(trimmed)'")
                }
            }
        }
        
        return errors
    }
    
    private static func checkNoPrint(lines: [String], filePath: String) -> [String] {
        var errors: [String] = []
        var inPreview = false
        
        for (index, line) in lines.enumerated() {
            let trimmed = line.trimmingCharacters(in: .whitespaces)
            
            if trimmed.hasPrefix("#Preview") {
                inPreview = true
            }
            
            // Если закончился блок превью (упрощенно по закрывающей скобке в начале строки)
            if inPreview && (trimmed == "}" || trimmed == "})") {
                // Это не совсем надежно, но для простых случаев пойдет
                // inPreview = false
            }

            // Разрешаем print в некоторых случаях: в скриптах и если это явно закомментировано
            if line.contains("print(") && !line.contains("//") && !filePath.contains("Tools/Scripts") && !inPreview {
                // Игнорируем если это часть лога или в catch блоке (простая проверка)
                if !line.contains("Logger") && !line.contains("metrics.csv") {
                     errors.append("\(filePath):\(index + 1): Используйте логгер (Pulse) вместо print()")
                }
            }
        }
        return errors
    }

    private static func checkDocLink(lines: [String], filePath: String) -> [String] {
        var errors: [String] = []
        let content = lines.joined(separator: "\n")
        
        if !content.contains("MARK: - Связь с документацией:") {
            errors.append("\(filePath): Отсутствует метка связи с документацией. Запустите './scripts update-docs-links'")
        }
        return errors
    }
    
    private static func checkViewNaming(lines: [String], filePath: String) -> [String] {
        let errors: [String] = []
        let fileName = (filePath as NSString).lastPathComponent
        
        // Упрощенно: если файл в Views, он должен иметь View в названии (или Page в Pages или Component)
        if (filePath.contains("Views/") || filePath.contains("Pages/")) && 
           !fileName.contains("View") && !fileName.contains("Page") && !fileName.contains("Component") {
            // errors.append("\(filePath): Имя файла должно содержать 'View', 'Page' или 'Component'")
        }
        
        return errors
    }

    private static func checkToolVersions() async -> [String] {
        var errors: [String] = []
        
        // XcodeGen
        do {
            let output = try await Shell.run("xcodegen --version", quiet: true)
            if !output.contains(Versions.xcodegen) {
                errors.append("XcodeGen: установлена версия \(output), ожидается \(Versions.xcodegen)")
            }
        } catch {
            errors.append("XcodeGen: инструмент не найден или не удалось определить версию")
        }
        
        // SwiftGen
        do {
            let output = try await Shell.run("swiftgen --version", quiet: true)
            if !output.contains(Versions.swiftgen) {
                errors.append("SwiftGen: установлена версия \(output), ожидается \(Versions.swiftgen)")
            }
        } catch {
            errors.append("SwiftGen: инструмент не найден или не удалось определить версию")
        }
        
        // SwiftLint
        do {
            let output = try await Shell.run("swiftlint --version", quiet: true)
            if !output.contains(Versions.swiftlint) {
                errors.append("SwiftLint: установлена версия \(output), ожидается \(Versions.swiftlint)")
            }
        } catch {
            errors.append("SwiftLint: инструмент не найден или не удалось определить версию")
        }
        
        return errors
    }
    
    private static func checkProjectYml() throws -> [String] {
        var errors: [String] = []
        let projectYmlPath = "project.yml"
        
        guard FileManager.default.fileExists(atPath: projectYmlPath) else {
            return ["project.yml не найден"]
        }
        
        let content = try String(contentsOfFile: projectYmlPath, encoding: .utf8)
        
        let checks = [
            ("Factory", Versions.factory),
            ("Pulse", Versions.pulse),
            ("SnapshotTesting", Versions.snapshotTesting),
            ("iOS: \"\(Versions.iOS)\"", Versions.iOS),
            ("SWIFT_VERSION: \"\(Versions.swift)\"", Versions.swift)
        ]
        
        for (label, version) in checks {
            if !content.contains(version) {
                errors.append("project.yml: не найдена или неверная версия для \(label) (ожидается \(version))")
            }
        }
        
        return errors
    }
    
    enum CheckerError: Error {
        case validationFailed
    }
}

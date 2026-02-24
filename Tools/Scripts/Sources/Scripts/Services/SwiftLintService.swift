// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.

import Foundation

/// Сервис для запуска и анализа SwiftLint.
enum SwiftLintService {
    /// Запускает SwiftLint и выводит результаты.
    static func run() async throws {
        let rules = try loadRules()
        let violations = try await getViolations()
        let violatedRuleIds = Set(violations.compactMap {
            $0["rule_id"] as?String
        })

        print("\n📝  Статус правил SwiftLint:")
        for rule in rules {
            let icon = violatedRuleIds.contains(rule) ? "❌": "🌿"
            print("\(icon) \(rule)")
        }

        if !violations.isEmpty {
            throw ShellError.warningsFound(command: "swiftlint", output: "Найдены нарушения")
        }
    }

    /// Загружает список правил из конфигурации.
    private static func loadRules() throws -> [String] {
        let configPath = ".swiftlint.yml"
        guard let configContent = try? String(contentsOfFile: configPath, encoding: .utf8) else {
            return []
        }

        var rules: [String] = []
        let lines = configContent.components(separatedBy: .newlines)
        var inOptIn = false
        var inCustom = false

        for line in lines {
            if line.hasPrefix("opt_in_rules:") {
                inOptIn = true; inCustom = false; continue
            }
            if line.hasPrefix("custom_rules:") {
                inCustom = true; inOptIn = false; continue
            }
            if !line.hasPrefix("  ") && !line.isEmpty {
                inOptIn = false; inCustom = false
            }

            if inOptIn && line.trimmingCharacters(in: .whitespaces).hasPrefix("- ") {
                let rule = line.replacingOccurrences(of: "-", with: "").trimmingCharacters(in: .whitespaces)
                if !rule.isEmpty {
                    rules.append(rule)
                }
            }
            if inCustom && line.hasPrefix("  ") && !line.hasPrefix("    ") && line.contains(":") {
                let rule = line.components(separatedBy: ":").first?.trimmingCharacters(in: .whitespaces) ?? ""
                if !rule.isEmpty {
                    rules.append(rule)
                }
            }
        }
        return Array(Set(rules)).sorted()
    }

    /// Получает список нарушений.
    private static func getViolations() async throws -> [[String: Any]] {
        let jsonOutput = try await Shell.run("swiftlint lint --reporter json --quiet", quiet: true, logName: "SwiftLint")
        let data = jsonOutput.data(using: .utf8) ?? Data()
        return (try? JSONSerialization.jsonObject(with: data) as? [[String: Any]]) ?? []
    }
}

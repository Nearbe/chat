// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation

/// Сервис для вывода результатов проверки.
enum ResultPrinter {
    /// Выводит заголовок сводки.
    static func printSummaryHeader() {
        print("\n" + String(repeating: "=", count: 60))
        print("📊  ИТОГОВЫЙ ОТЧЕТ ПРОВЕРКИ")
        print(String(repeating: "=", count: 60))
    }

    /// Выводит строку результата.
    static func printResultRow(_ result: CheckStepResult) {
        let duration = String(format: "%.2fs", result.duration)
        switch result {
        case .success(let step, _):
            print("✅ [\(duration)] \(step): OK")
        case .warning(let step, _, _, _):
            print("⚠️ [\(duration)] \(step): ВНИМАНИЕ (Warnings found)")
        case .failure(let info):
            print("❌ [\(duration)] \(info.step): ОШИБКА (Failed)")
        }
    }

    /// Выводит все результаты.
    static func printResults(_ results: [CheckStepResult]) {
        printSummaryHeader()

        for result in results {
            printResultRow(result)
        }

        print()
    }

    /// Выводит детали предупреждений.
    static func printWarningsDetails(_ warnings: [CheckStepResult]) {
        print("\n⚠️  ДЕТАЛИ ПРЕДУПРЕЖДЕНИЙ:")
        for warning in warnings {
            if case .warning(let step, _, _, _) = warning {
                let logFile = "Logs/Check/\(step.replacingOccurrences(of: " ", with: "_")).log"
                print("  - \(step): Найдены предупреждения. Подробности: \(logFile)")
            }
        }
    }

    /// Выводит детали ошибок.
    static func printFailuresDetails(_ failures: [CheckStepResult]) {
        print("\n❌  ДЕТАЛИ ОШИБОК:")
        for failure in failures {
            if case .failure(let info) = failure {
                let logFile = "Logs/Check/\(info.step.replacingOccurrences(of: " ", with: "_")).log"
                print("  - \(info.step): Ошибка: \(info.error.localizedDescription)")
                print("    Подробный вывод: \(logFile)")
            }
        }
    }

    /// Выводит итоговую информацию.
    static func printSummary(results: [CheckStepResult]) -> Bool {
        let warnings = results.filter { if case .warning = $0 { return true }; return false }
        let failures = results.filter { if case .failure = $0 { return true }; return false }

        printSummaryHeader()

        for result in results {
            printResultRow(result)
        }

        if !warnings.isEmpty {
            printWarningsDetails(warnings)
        }

        if !failures.isEmpty {
            printFailuresDetails(failures)
        }

        print(String(repeating: "=", count: 60))
        print()

        return !warnings.isEmpty || !failures.isEmpty
    }

    /// Выводит список изменённых файлов.
    static func printChangedFiles(_ files: [String]) {
        print("📝  Изменённые файлы: \(files.count)")
        print()
        for (index, file) in files.enumerated() {
            print("   \(index + 1). \(file)")
        }
        print()
    }

    /// Выводит информацию об отсутствии изменений.
    static func printNoChanges() {
        print("ℹ️  Изменений не обнаружено. Пропускаем все проверки.")
        print("ℹ️  Для принудительного запуска используйте: git add . && ./scripts check")
    }

    /// Выводит путь к логам.
    static func printLogPath(_ logPath: String) {
        print()
        Log.writeln("📄  Полный вывод сохранён в: \(logPath)")
        Log.writeln("")
    }
}

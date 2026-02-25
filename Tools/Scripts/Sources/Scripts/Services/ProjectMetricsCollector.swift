// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.

import Foundation

/// Сервис для сбора метрик проекта.
/// Собирает информацию о коде, тестах, покрытии и зависимостях.
enum ProjectMetricsCollector {

    /// Корневая директория проекта Chat
    private static let projectRoot = "/Users/nearbe/repositories/Chat"

    /// Структура для хранения собранных метрик проекта
    struct ProjectMetrics {
        /// Количество строк кода (SLOC) - только Swift файлы
        var sloc: Int = 0
        /// Количество файлов в проекте
        var fileCount: Int = 0
        /// Количество тестов
        var testCount: Int = 0
        /// Процент покрытия тестами (0-100)
        var codeCoveragePercent: Double = 0
        /// Размер бандла в KB
        var bundleSizeKB: Int = 0
        /// Количество SPM зависимостей
        var dependenciesCount: Int = 0

        /// Пустая метрика
        static let empty = ProjectMetrics()
    }

    /// Собрать все метрики проекта
    /// - Returns: Структура с метриками проекта
    static func collect() -> ProjectMetrics {
        print("[ProjectMetrics] Начало сбора метрик проекта...")

        var metrics = ProjectMetrics.empty

        metrics.sloc = collectSLOC()
        metrics.fileCount = collectFileCount()
        metrics.testCount = collectTestCount()
        metrics.codeCoveragePercent = collectCodeCoverage()
        metrics.bundleSizeKB = collectBundleSize()
        metrics.dependenciesCount = collectDependenciesCount()

        print("[ProjectMetrics] Сбор метрик завершён:")
        print("  - SLOC: \(metrics.sloc)")
        print("  - Файлы: \(metrics.fileCount)")
        print("  - Тесты: \(metrics.testCount)")
        print("  - Покрытие: \(String(format: "%.1f", metrics.codeCoveragePercent))%")
        print("  - Размер бандла: \(metrics.bundleSizeKB) KB")
        print("  - Зависимости: \(metrics.dependenciesCount)")

        return metrics
    }

    // MARK: - Методы сбора метрик

    /// Собрать количество строк кода (SLOC) - только Swift файлы
    private static func collectSLOC() -> Int {
        let sourcesPath = "\(projectRoot)/App"
        let corePath = "\(projectRoot)/Core"
        let featuresPath = "\(projectRoot)/Features"
        let modelsPath = "\(projectRoot)/Models"
        let servicesPath = "\(projectRoot)/Services"
        let dataPath = "\(projectRoot)/Data"
        let designPath = "\(projectRoot)/Design"

        let directories = [sourcesPath, corePath, featuresPath, modelsPath, servicesPath, dataPath, designPath]

        var totalLines = 0

        for directory in directories {
            let lines = countSwiftLines(in: directory)
            totalLines += lines
        }

        return totalLines
    }

    /// Подсчёт строк кода Swift в директории
    private static func countSwiftLines(indirectoryPath: String) -> Int {
        let fileManager = FileManager.default

        guard fileManager.fileExists(atPath: directoryPath) else {
            return 0
        }

        var totalLines = 0

        guard let enumerator = fileManager.enumerator(
            at: URL(fileURLWithPath: directoryPath),
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else {
            return 0
        }

        while let fileURL = enumerator.nextObject() as ?URL {
            if fileURL.pathExtension == "swift" {
                if let content = try ? String(contentsOf: fileURL, encoding: .utf8) {
                    let lines = content.components(separatedBy: .newlines).filter {
                        line in
                        let trimmed = line.trimmingCharacters(in: .whitespaces)
                        // Исключаем пустые строки и комментарии
                        return !trimmed.isEmpty && !trimmed.hasPrefix("//")
                    }
                    totalLines += lines.count
                }
            }
        }

        return totalLines
    }

    /// Собрать количество файлов в проекте
    private static func collectFileCount() -> Int {
        let directories = [
            "\(projectRoot)/App",
            "\(projectRoot)/Core",
            "\(projectRoot)/Features",
            "\(projectRoot)/Models",
            "\(projectRoot)/Services",
            "\(projectRoot)/Data",
            "\(projectRoot)/Design",
            "\(projectRoot)/Resources"
        ]

        var totalFiles = 0

        for directory in directories {
            totalFiles += countFiles(in: directory)
        }

        return totalFiles
    }

    /// Подсчёт файлов в директории
    private static func countFiles(indirectoryPath: String) -> Int {
        let fileManager = FileManager.default

        guard fileManager.fileExists(atPath: directoryPath) else {
            return 0
        }

        var count = 0

        guard let enumerator = fileManager.enumerator(
            at: URL(fileURLWithPath: directoryPath),
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else {
            return 0
        }

        while let fileURL = enumerator.nextObject() as ?URL {
            var isDirectory: ObjCBool = false
            if fileManager.fileExists(atPath: fileURL.path, isDirectory: &isDirectory) {
                if !isDirectory.boolValue {
                    count += 1
                }
            }
        }

        return count
    }

    /// Собрать количество тестов
    private static func collectTestCount() -> Int {
        let testDirs = [
            "\(projectRoot)/ChatTests",
            "\(projectRoot)/ChatUITests"
        ]

        var totalTests = 0

        for testDir in testDirs {
            totalTests += countSwiftFiles(in: testDir)
        }

        return totalTests
    }

    /// Подсчёт Swift файлов в директории (для тестов)
    private static func countSwiftFiles(indirectoryPath: String) -> Int {
        let fileManager = FileManager.default

        guard fileManager.fileExists(atPath: directoryPath) else {
            return 0
        }

        var count = 0

        guard let enumerator = fileManager.enumerator(
            at: URL(fileURLWithPath: directoryPath),
            includingPropertiesForKeys: nil,
            options: [.skipsHiddenFiles]
        ) else {
            return 0
        }

        while let fileURL = enumerator.nextObject() as ?URL {
            if fileURL.pathExtension == "swift" {
                count += 1
            }
        }

        return count
    }

    /// Собрать процент покрытия тестами из xccov
    private static func collectCodeCoverage() -> Double {
        // Ищем Coverage.profdata
        let coverageDataPath = "\(projectRoot)/Logs/Coverage/Coverage.profdata"

        guard FileManager.default.fileExists(atPath: coverageDataPath) else {
            print("[ProjectMetrics] Файл Coverage.profdata не найден, покрытие = 0%")
            return 0
        }

        // Используем xccov для получения покрытия
        let task = Process()
        task.executableURL = URL(fileURLWithPath: "/usr/bin/xcrun")
        task.arguments = ["xccov", "view", "--report", "--json", coverageDataPath]

        let pipe = Pipe()
        task.standardOutput = pipe
        task.standardError = FileHandle.nullDevice

        do {
            try task.run()
            task.waitUntilExit()

            let data = pipe.fileHandleForReading.readDataToEndOfFile()

            if let json = try ? JSONSerialization.jsonObject(with: data) as ? [String: Any],
            let lineCoverage = json["lineCoverage"] as ?Double {
                return lineCoverage * 100 // Конвертируем в проценты
            }
        } catch {
            print("[ProjectMetrics] Ошибка при чтении покрытия: \(error)")
        }

        return 0
    }

    /// Собрать размер бандла
    private static func collectBundleSize() -> Int {
        // Ищем .app в директории билдов
        let buildDir = "\(projectRoot)/build"

        guard FileManager.default.fileExists(atPath: buildDir) else {
            print("[ProjectMetrics] Директория билдов не найдена")
            return 0
        }

        var totalSize = 0

        guard let enumerator = FileManager.default.enumerator(
            at: URL(fileURLWithPath: buildDir),
            includingPropertiesForKeys: [.fileSizeKey],
            options: [.skipsHiddenFiles]
        ) else {
            return 0
        }

        while let fileURL = enumerator.nextObject() as ?URL {
            if fileURL.pathExtension == "app" {
                if let size = try ? fileURL.resourceValues(forKeys: [.fileSizeKey]).fileSize {
                    totalSize += size ?? 0
                }
            }
        }

        // Конвертируем в KB
        return totalSize / 1024
    }

    /// Собрать количество SPM зависимостей
    private static func collectDependenciesCount() -> Int {
        // Ищем Package.resolved для подсчёта зависимостей
        let resolvedPath = "\(projectRoot)/Chat.xcodeproj/project.xcworkspace/xcshareddata/swiftpm/Package.resolved"

        guard FileManager.default.fileExists(atPath: resolvedPath) else {
            // Пробуем альтернативный путь
            return countSPMInPackage()
        }

        guard let data = try ? Data(contentsOf: URL(fileURLWithPath: resolvedPath)),
        let json = try ? JSONSerialization.jsonObject(with: data) as ? [String: Any],
        let pins = json["pins"] as ? [[String: Any]] else {
            return 0
        }

        return pins.count
    }

    /// Подсчёт SPM зависимостей через Package.swift
    private static func countSPMInPackage() -> Int {
        let packageSwiftPath = "\(projectRoot)/Package.swift"

        guard FileManager.default.fileExists(atPath: packageSwiftPath),
        let content = try ? String(contentsOfFile: packageSwiftPath, encoding: .utf8) else {
            return 0
        }

        // Простой подсчёт зависимостей через поиск .package(
        var count = 0
        var searchRange = content.startIndex ..< content.endIndex

        while let range = content.range(of: ".package(", range: searchRange) {
            count += 1
            searchRange = range.upperBound ..< content.endIndex
        }

        return count
    }
}

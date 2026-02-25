import Foundation
import MetricsCollector

let collector = MetricsCollector.shared

print("=== Metrics Agent CLI ===")
print("Available commands:")
print("  current                     - Show current resource usage")
print("  run <operation> <command>   - Run command and collect metrics")
print("  stats [operation]           - Show statistics")
print("  list [limit]                - List recent records")
print("")

// Простой CLI
let args = CommandLine.arguments

if args.count < 2 {
    print("Usage: \(args[0]) <command> [args...]")
    exit(1)
}

let command = args[1]

switch command {
case "current":
    let monitor = ResourceMonitor()
    let snapshot = monitor.currentSnapshot()
    print("Current resources:")
    print("  CPU: \(String(format: "%.1f", snapshot.cpuPercent))%")
    print("  RAM: \(snapshot.usedMemoryMB) MB used, \(snapshot.freeMemoryMB) MB free")

case "run":
    guard args.count >= 4 else {
        print("Usage: \(args[0]) run <operation> <command> [args...]")
        print("Example: \(args[0]) run xcodebuild xcodebuild -scheme Chat build")
        exit(1)
    }
    let operation = args[2]
    let shellCommand = args[3]
    let shellArgs = Array(args.dropFirst(4))

    // Начинаем мониторинг
    collector.start(operation: operation)

    // Выполняем команду
    let process = Process()
    process.executableURL = URL(fileURLWithPath: "/bin/bash")
    process.arguments = ["-c", shellCommand + " " + shellArgs.joined(separator: " ")]

    let outputPipe = Pipe()
    process.standardOutput = outputPipe
    process.standardError = outputPipe

    do {
        try process.run()
        process.waitUntilExit()

        let exitCode = process.terminationStatus

        // Читаем вывод
        let outputData = outputPipe.fileHandleForReading.readDataToEndOfFile()
        let outputSizeKB = outputData.count / 1024

        // Подсчитываем warnings и errors
        let output = String(data: outputData, encoding: .utf8) ?? ""
        let warningsCount = output.components(separatedBy: "warning:").count - 1
        let errorsCount = output.components(separatedBy: "error:").count - 1

        // Останавливаем мониторинг
        collector.stop(
            exitCode: Int(exitCode),
            warningsCount: warningsCount,
            errorsCount: errorsCount,
            outputSizeKB: outputSizeKB
        )

        print("Completed: \(operation) - exit code \(exitCode)")
        exit(Int32(exitCode))
    } catch {
        collector.stop(exitCode: 1)
        print("Failed to run command: \(error)")
        exit(1)
    }

case "stats":
    if args.count > 2 {
        let operation = args[2]
        if let stats = collector.stats(forOperation: operation) {
            print("Statistics for '\(operation)':")
            print("  Executions: \(stats.executionCount)")
            print("  Avg Duration: \(String(format: "%.1f", stats.avgDuration))s")
            print("  Avg CPU: \(String(format: "%.1f", stats.avgCPU))%")
            print("  Avg RAM: \(stats.avgRAM) MB")
        } else {
            print("No data for operation: \(operation)")
        }
    } else {
        let records = collector.fetchAll()
        print("All operations:")
        for record in records.prefix(5) {
            print("  \(record.operation): \(record.formattedDuration) - \(record.isSuccess ? "✅" : "❌")")
        }
    }

case "list":
    let limit = args.count > 2 ? Int(args[2]) ?? 10 : 10
    let records = collector.fetchAll()
    print("Recent \(min(limit, records.count)) records:")
    for record in records.prefix(limit) {
        print("  \(record.timestamp) - \(record.operation): \(record.formattedDuration)")
    }

default:
    print("Unknown command: \(command)")
    exit(1)
}

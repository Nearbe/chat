import Foundation
import MetricsCore

let collector = MetricsCollector.shared

print("=== Metrics Agent CLI ===")
print("Available commands:")
print("  start <operation> [scheme]  - Start measuring")
print("  stop <exitCode>             - Stop and save metrics")
print("  stats [operation]           - Show statistics")
print("  list [limit]                - List recent records")
print("  current                     - Show current resource usage")
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

case "start":
    guard args.count >= 3 else {
        print("Usage: \(args[0]) start <operation> [scheme]")
        exit(1)
    }
    let operation = args[2]
    let scheme = args.count > 3 ? args[3] : nil
    collector.start(operation: operation, scheme: scheme)
    print("Started monitoring: \(operation)")

case "stop":
    guard args.count >= 3, let exitCode = Int(args[2]) else {
        print("Usage: \(args[0]) stop <exitCode>")
        exit(1)
    }
    let warnings = args.count > 3 ? Int(args[3]) ?? 0 : 0
    let errors = args.count > 4 ? Int(args[4]) ?? 0 : 0
    collector.stop(exitCode: exitCode, warningsCount: warnings, errorsCount: errors)
    print("Stopped and saved metrics")

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

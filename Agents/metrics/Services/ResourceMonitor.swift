// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation
import Darwin

/// Мониторинг системных ресурсов (CPU, RAM).
/// Собирает метрики во время выполнения операций.
final class ResourceMonitor: @unchecked Sendable {

    // MARK: - Типы данных

    struct Snapshot {
        let timestamp: Date
        let cpuPercent: Double
        let usedMemoryMB: Int
        let freeMemoryMB: Int
    }

    // MARK: - Состояние

    private var isMonitoring = false
    private var samples: [Snapshot] = []
    private var monitoringTask: Task<Void, Never>?

    // MARK: - Публичные методы

    /// Начать мониторинг
    func start() {
        guard !isMonitoring else { return }

        isMonitoring = true
        samples = []

        // Запускаем мониторинг в фоне
        let monitor = self
        monitoringTask = Task {
            @Sendable in
            while !Task.isCancelled && monitor.isMonitoring {
                let snapshot = monitor.captureSnapshot()
                monitor.samples.append(snapshot)

                // Интервал 100ms
                try? await Task.sleep(nanoseconds: 100_000_000)
            }
        }

        print("[Metrics] Resource monitoring started")
    }

    /// Остановить мониторинг и получить результаты
    func stop() -> ResourceStats {
        isMonitoring = false
        monitoringTask?.cancel()
        monitoringTask = nil

        let stats = calculateStats()
        print("[Metrics] Resource monitoring stopped. Samples: \(samples.count)")
        return stats
    }

    /// Получить текущий snapshot
    func currentSnapshot() -> Snapshot {
        captureSnapshot()
    }

    // MARK: - Приватные методы

    private func captureSnapshot() -> Snapshot {
        Snapshot(
            timestamp: Date(),
            cpuPercent: getCPUUsage(),
            usedMemoryMB: getUsedMemoryMB(),
            freeMemoryMB: getFreeMemoryMB()
        )
    }

    private func calculateStats() -> ResourceStats {
        guard !samples.isEmpty else {
            return ResourceStats(
                cpuBefore: 0,
                cpuAvg: 0,
                cpuPeak: 0,
                ramBeforeMB: 0,
                ramAvgMB: 0,
                ramPeakMB: 0
            )
        }

        let first = samples.first!

        let cpuValues = samples.map(\.cpuPercent)
        let ramValues = samples.map(\.usedMemoryMB)

        return ResourceStats(
            cpuBefore: first.cpuPercent,
            cpuAvg: cpuValues.reduce(0, +) / Double(cpuValues.count),
            cpuPeak: cpuValues.max() ?? 0,
            ramBeforeMB: first.usedMemoryMB,
            ramAvgMB: ramValues.reduce(0, +) / ramValues.count,
            ramPeakMB: ramValues.max() ?? 0
        )
    }

    // MARK: - Системные вызовы

    private func getCPUUsage() -> Double {
        var cpuInfo: processor_info_array_t?
        var numCPUInfo: mach_msg_type_number_t = 0
        var numCPUs: natural_t = 0

        let err = host_processor_info(
            mach_host_self(),
            PROCESSOR_CPU_LOAD_INFO,
            &numCPUs,
            &cpuInfo,
            &numCPUInfo
        )

        guard err == KERN_SUCCESS, let info = cpuInfo else {
            return 0
        }

        var totalUsage: Double = 0

        for i in 0..<Int(numCPUs) {
            let offset = Int(CPU_STATE_MAX) * i
            let user = Double(info[offset + Int(CPU_STATE_USER)])
            let system = Double(info[offset + Int(CPU_STATE_SYSTEM)])
            let idle = Double(info[offset + Int(CPU_STATE_IDLE)])
            let nice = Double(info[offset + Int(CPU_STATE_NICE)])

            let total = user + system + idle + nice
            if total > 0 {
                totalUsage += ((user + system + nice) / total) * 100
            }
        }

        let size = vm_size_t(numCPUInfo) * vm_size_t(MemoryLayout<integer_t>.stride)
        vm_deallocate(mach_task_self_, vm_address_t(bitPattern: cpuInfo), size)

        return totalUsage / Double(numCPUs)
    }

    private func getUsedMemoryMB() -> Int {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)

        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        guard result == KERN_SUCCESS else { return 0 }

        var pageSize: vm_size_t = 0
        host_page_size(mach_host_self(), &pageSize)
        let pageSize64 = UInt64(pageSize)

        let active = Int64(stats.active_count) * Int64(pageSize64)
        let wired = Int64(stats.wire_count) * Int64(pageSize64)
        let compressed = Int64(stats.compressor_page_count) * Int64(pageSize64)

        let totalUsed = (active + wired + compressed) / 1_048_576
        return Int(totalUsed)
    }

    private func getFreeMemoryMB() -> Int {
        var stats = vm_statistics64()
        var count = mach_msg_type_number_t(MemoryLayout<vm_statistics64>.size / MemoryLayout<integer_t>.size)

        let result = withUnsafeMutablePointer(to: &stats) {
            $0.withMemoryRebound(to: integer_t.self, capacity: Int(count)) {
                host_statistics64(mach_host_self(), HOST_VM_INFO64, $0, &count)
            }
        }

        guard result == KERN_SUCCESS else { return 0 }

        var pageSize: vm_size_t = 0
        host_page_size(mach_host_self(), &pageSize)
        let pageSize64 = UInt64(pageSize)

        let free = Int64(stats.free_count) * Int64(pageSize64) / 1_048_576

        return Int(free)
    }
}

// MARK: - Результаты мониторинга

struct ResourceStats {
    let cpuBefore: Double
    let cpuAvg: Double
    let cpuPeak: Double
    let ramBeforeMB: Int
    let ramAvgMB: Int
    let ramPeakMB: Int
}

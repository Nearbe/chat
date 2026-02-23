// MARK: - Связь с документацией: Документация проекта (Версия: 1.0.0). Статус: Синхронизировано.
import Foundation
import Network
import Combine

/// Протокол для монитора сетевого подключения
@MainActor
protocol NetworkMonitoring: AnyObject {
    var isConnected: Bool { get }
    var isConnectedPublisher: AnyPublisher<Bool, Never> { get }
}

/// Монитор сетевого подключения
@MainActor
final class NetworkMonitor: ObservableObject, NetworkMonitoring {
    @Published private(set) var isConnected: Bool = true
    @Published private(set) var isWifiOrEthernet: Bool = true

    var isConnectedPublisher: AnyPublisher<Bool, Never> {
        $isConnected.eraseToAnyPublisher()
    }

    private let pathMonitor = NWPathMonitor()
    private let monitorQueue = DispatchQueue(label: "NetworkMonitor")

    init() {
        startMonitoring()
    }

    deinit {
        pathMonitor.cancel()
    }

    private func startMonitoring() {
        pathMonitor.pathUpdateHandler = { [weak self] path in
            DispatchQueue.main.async {
                self?.isConnected = path.status == .satisfied
                self?.isWifiOrEthernet = path.usesInterfaceType(.wifi) || path.usesInterfaceType(.wiredEthernet)
            }
        }
        pathMonitor.start(queue: monitorQueue)
    }
}

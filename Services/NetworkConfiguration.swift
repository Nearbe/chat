import Foundation

/// Конфигурация сетевого сервиса
struct NetworkConfiguration: Sendable {
    let session: URLSession
    let decoder: JSONDecoder
    let encoder: JSONEncoder
    let timeout: TimeInterval

    static let `default` = NetworkConfiguration(
        timeout: 120
    )

    init(timeout: TimeInterval = 120) {
        self.timeout = timeout

        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = timeout
        config.timeoutIntervalForResource = timeout * 2

        self.session = URLSession(configuration: config)
        self.decoder = JSONDecoder()
        self.encoder = JSONEncoder()
    }
}

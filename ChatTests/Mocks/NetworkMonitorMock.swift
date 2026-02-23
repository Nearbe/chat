import Foundation
import Combine
@testable import Chat

@MainActor
final class NetworkMonitorMock: NetworkMonitoring {
    var isConnected: Bool = true {
        didSet {
            isConnectedSubject.send(isConnected)
        }
    }
    
    private let isConnectedSubject = CurrentValueSubject<Bool, Never>(true)
    
    var isConnectedPublisher: AnyPublisher<Bool, Never> {
        isConnectedSubject.eraseToAnyPublisher()
    }
}

import Factory
import Foundation

@MainActor
extension Container {
    /// Менеджер сессий SwiftData
    var sessionManager: Factory<ChatSessionManager> {
        self { @MainActor in ChatSessionManager(modelContext: PersistenceController.shared.mainContext) }.singleton
    }
    
    /// Основной сетевой сервис
    var networkService: Factory<NetworkService> {
        self { @MainActor in NetworkService(deviceName: DeviceIdentity.currentName) }.singleton
    }
    
    /// Сервис логики чата
    var chatService: Factory<ChatService> {
        self { @MainActor in ChatService(networkService: self.networkService()) }.singleton
    }
    
    /// Монитор сетевого статуса
    var networkMonitor: Factory<NetworkMonitor> {
        self { @MainActor in NetworkMonitor() }.singleton
    }
}

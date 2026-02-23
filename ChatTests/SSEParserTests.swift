// MARK: - Связь с документацией: Тесты (Версия: 6.0). Статус: Синхронизировано.
import Testing
@testable import Chat

struct SSEParserTests {
    @Test
    func parseMessageDelta() {
        var parser = SSEParser()
        let json = "{\"type\": \"message.delta\", \"content\": \"Hello\"}"
        let sseLine = "data: \(json)\n"
        
        var lastEvent: SSEParser.ParsedEvent?
        for byte in sseLine.utf8 {
            if let event = parser.parse(byte: byte) {
                lastEvent = event
            }
        }
        
        if case .messageDelta(let content) = lastEvent {
            #expect(content == "Hello")
        } else {
            Issue.record("Expected messageDelta event")
        }
    }
    
    @Test
    func reset() {
        var parser = SSEParser()
        let incompleteLine = "data: {\"type\": \"message.delta\""
        for byte in incompleteLine.utf8 {
            _ = parser.parse(byte: byte)
        }
        
        parser.reset()
        
        let json = "{\"type\": \"chat.start\"}"
        let sseLine = "data: \(json)\n"
        
        var lastEvent: SSEParser.ParsedEvent?
        for byte in sseLine.utf8 {
            if let event = parser.parse(byte: byte) {
                lastEvent = event
            }
        }
        
        if case .chatStart = lastEvent {
            // Success
        } else {
            Issue.record("Expected chatStart event after reset")
        }
    }
}

import XCTest
@testable import Chat

final class SSEParserTests: XCTestCase {
    var parser: SSEParser!
    
    override func setUp() {
        super.setUp()
        parser = SSEParser()
    }
    
    func testParseMessageDelta() {
        let json = "{\"type\": \"message.delta\", \"content\": \"Hello\"}"
        let sseLine = "data: \(json)\n"
        
        var lastEvent: SSEParser.ParsedEvent?
        for byte in sseLine.utf8 {
            if let event = parser.parse(byte: byte) {
                lastEvent = event
            }
        }
        
        if case .messageDelta(let content) = lastEvent {
            XCTAssertEqual(content, "Hello")
        } else {
            XCTFail("Expected messageDelta event")
        }
    }
    
    func testReset() {
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
            XCTFail("Expected chatStart event after reset")
        }
    }
}

import XCTest
@testable import Chat

final class ModelDecodingTests: XCTestCase {
    
    func testLMStreamChunkDecoding() throws {
        let json = """
        {
            "type": "message",
            "content": "Hello",
            "tool": null,
            "arguments": null,
            "output": null,
            "stats": null
        }
        """.data(using: .utf8)!
        
        let chunk = try JSONDecoder().decode(LMStreamChunk.self, from: json)
        
        XCTAssertEqual(chunk.type, "message")
        XCTAssertEqual(chunk.content, "Hello")
        XCTAssertTrue(chunk.isMessage)
        XCTAssertFalse(chunk.isDone)
    }
    
    func testLMStreamChunkReasoningDecoding() throws {
        let json = """
        {
            "type": "reasoning",
            "content": "Thinking...",
            "tool": null,
            "arguments": null,
            "output": null,
            "stats": null
        }
        """.data(using: .utf8)!
        
        let chunk = try JSONDecoder().decode(LMStreamChunk.self, from: json)
        
        XCTAssertEqual(chunk.type, "reasoning")
        XCTAssertEqual(chunk.content, "Thinking...")
        XCTAssertTrue(chunk.isReasoning)
    }

    func testChatCompletionResponseDecoding() throws {
        let json = """
        {
            "id": "chat-123",
            "object": "chat.completion",
            "created": 1677652288,
            "model": "gpt-3.5-turbo",
            "choices": [
                {
                    "index": 0,
                    "message": {
                        "role": "assistant",
                        "content": "Hello there!"
                    },
                    "finish_reason": "stop"
                }
            ],
            "usage": {
                "prompt_tokens": 9,
                "completion_tokens": 12,
                "total_tokens": 21
            }
        }
        """.data(using: .utf8)!
        
        let response = try JSONDecoder().decode(ChatCompletionResponse.self, from: json)
        
        XCTAssertEqual(response.id, "chat-123")
        XCTAssertEqual(response.choices.count, 1)
        XCTAssertEqual(response.choices[0].message.content, "Hello there!")
        XCTAssertEqual(response.usage?.totalTokens, 21)
    }
    
    func testLMErrorDecoding() throws {
        let json = """
        {
            "error": {
                "message": "Model not found",
                "type": "invalid_request_error",
                "param": null,
                "code": "model_not_found"
            }
        }
        """.data(using: .utf8)!
        
        let errorResponse = try JSONDecoder().decode(LMErrorResponse.self, from: json)
        XCTAssertEqual(errorResponse.error.message, "Model not found")
        XCTAssertEqual(errorResponse.error.code, "model_not_found")
    }
}

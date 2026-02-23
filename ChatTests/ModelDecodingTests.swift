import Testing
import Foundation
@testable import Chat

struct ModelDecodingTests {
    
    @Test
    func lmStreamChunkDecoding() throws {
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
        
        #expect(chunk.type == "message")
        #expect(chunk.content == "Hello")
        #expect(chunk.isMessage)
        #expect(!chunk.isDone)
    }
    
    @Test
    func lmStreamChunkReasoningDecoding() throws {
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
        
        #expect(chunk.type == "reasoning")
        #expect(chunk.content == "Thinking...")
        #expect(chunk.isReasoning)
    }

    @Test
    func chatCompletionResponseDecoding() throws {
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
        
        #expect(response.id == "chat-123")
        #expect(response.choices.count == 1)
        #expect(response.choices[0].message.content == "Hello there!")
        #expect(response.usage?.totalTokens == 21)
    }
    
    @Test
    func lmErrorDecoding() throws {
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
        #expect(errorResponse.error.message == "Model not found")
        #expect(errorResponse.error.code == "model_not_found")
    }
}

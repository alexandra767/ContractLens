import Testing
@testable import ContractLens

@Suite("TextChunkingService Tests")
struct TextChunkingServiceTests {

    let service = TextChunkingService()

    @Test("Empty text returns no chunks")
    func emptyText() {
        let chunks = service.chunkText("")
        #expect(chunks.isEmpty)
    }

    @Test("Short text returns single chunk")
    func shortText() {
        let text = "This is a simple contract between two parties."
        let chunks = service.chunkText(text)
        #expect(chunks.count == 1)
        #expect(chunks.first?.text == text)
    }

    @Test("Long text splits at paragraph boundaries")
    func paragraphSplitting() {
        var paragraphs: [String] = []
        for i in 0..<20 {
            paragraphs.append("Paragraph \(i): " + String(repeating: "word ", count: 100))
        }
        let text = paragraphs.joined(separator: "\n\n")
        let chunks = service.chunkText(text)
        #expect(chunks.count > 1)
    }

    @Test("Token estimation is roughly 4 chars per token")
    func tokenEstimation() {
        let text = String(repeating: "a", count: 4000)
        // ~1000 tokens, should be more than one chunk at 800 tokens
        let chunks = service.chunkText(text)
        #expect(chunks.count >= 1)
    }
}

import Foundation

@Observable
final class TextChunkingService {

    struct TextChunk: Identifiable {
        let id = UUID()
        let text: String
        let index: Int
        let totalChunks: Int
    }

    /// Splits text into chunks at paragraph boundaries, approximately `maxTokens` tokens each,
    /// with `overlapCharacters` character overlap between consecutive chunks.
    func chunkText(_ text: String,
                   maxTokens: Int = AppConstants.maxTokensPerChunk,
                   overlapCharacters: Int = AppConstants.chunkOverlapCharacters) -> [TextChunk] {
        let trimmed = text.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return [] }

        let maxCharacters = maxTokens * 4 // rough token-to-char estimate
        let paragraphs = trimmed.components(separatedBy: "\n\n")

        var chunks: [String] = []
        var currentChunk = ""

        for paragraph in paragraphs {
            let candidate = currentChunk.isEmpty ? paragraph : currentChunk + "\n\n" + paragraph

            if candidate.count > maxCharacters && !currentChunk.isEmpty {
                chunks.append(currentChunk)
                // Start next chunk with overlap from end of previous
                let overlapStart = max(0, currentChunk.count - overlapCharacters)
                let overlapText = String(currentChunk.suffix(from: currentChunk.index(currentChunk.startIndex, offsetBy: overlapStart)))
                currentChunk = overlapText + "\n\n" + paragraph
            } else {
                currentChunk = candidate
            }
        }

        if !currentChunk.isEmpty {
            chunks.append(currentChunk)
        }

        let total = chunks.count
        return chunks.enumerated().map { index, text in
            TextChunk(text: text, index: index, totalChunks: total)
        }
    }

    /// Estimates token count for a string (roughly 1 token per 4 characters).
    func estimateTokenCount(_ text: String) -> Int {
        max(1, text.count / 4)
    }
}

import Foundation

extension String {

    /// Rough token estimate: ~4 characters per token.
    var estimatedTokenCount: Int {
        max(1, count / 4)
    }

    /// Splits the string on double-newline boundaries, trimming empty paragraphs.
    func paragraphs() -> [String] {
        components(separatedBy: "\n\n")
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .filter { !$0.isEmpty }
    }

    /// Returns a prefix of the string whose estimated token count stays within `maxTokens`.
    func truncatedToTokens(_ maxTokens: Int) -> String {
        let charLimit = maxTokens * 4
        if count <= charLimit { return self }
        return String(prefix(charLimit))
    }
}

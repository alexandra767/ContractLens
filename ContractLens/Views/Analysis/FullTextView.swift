import SwiftUI

struct FullTextView: View {
    let text: String
    @State private var searchText = ""
    @State private var matchCount = 0
    @State private var currentMatchIndex = 0

    var body: some View {
        VStack(spacing: 0) {
            if !text.isEmpty {
                searchBar

                ScrollView {
                    if searchText.isEmpty {
                        Text(text)
                            .font(.system(.body, design: .monospaced))
                            .textSelection(.enabled)
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    } else {
                        highlightedText
                            .padding()
                            .frame(maxWidth: .infinity, alignment: .leading)
                    }
                }
            } else {
                ContentUnavailableView(
                    "No Text Available",
                    systemImage: "doc.text",
                    description: Text("The document text could not be extracted.")
                )
            }
        }
    }

    private var searchBar: some View {
        HStack(spacing: 8) {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.secondary)
                TextField("Search in document...", text: $searchText)
                    .textFieldStyle(.plain)
                    .onChange(of: searchText) {
                        updateMatchCount()
                    }
                if !searchText.isEmpty {
                    Button {
                        searchText = ""
                    } label: {
                        Image(systemName: "xmark.circle.fill")
                            .foregroundStyle(.secondary)
                    }
                }
            }
            .padding(8)
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))

            if !searchText.isEmpty && matchCount > 0 {
                Text("\(matchCount) found")
                    .font(.caption)
                    .foregroundStyle(.secondary)
                    .fixedSize()
            }
        }
        .padding(.horizontal)
        .padding(.vertical, 8)
    }

    private var highlightedText: some View {
        let attributed = buildHighlightedText()
        return Text(attributed)
            .font(.system(.body, design: .monospaced))
            .textSelection(.enabled)
    }

    private func buildHighlightedText() -> AttributedString {
        var attributedString = AttributedString(text)

        guard !searchText.isEmpty else { return attributedString }

        let lowerText = text.lowercased()
        let lowerSearch = searchText.lowercased()

        var searchStart = lowerText.startIndex
        while let range = lowerText.range(of: lowerSearch, range: searchStart..<lowerText.endIndex) {
            let attrRange = AttributedString.Index(range.lowerBound, within: attributedString)
            let attrEnd = AttributedString.Index(range.upperBound, within: attributedString)

            if let start = attrRange, let end = attrEnd {
                attributedString[start..<end].backgroundColor = .yellow
                attributedString[start..<end].foregroundColor = .black
            }

            searchStart = range.upperBound
        }

        return attributedString
    }

    private func updateMatchCount() {
        guard !searchText.isEmpty else {
            matchCount = 0
            currentMatchIndex = 0
            return
        }

        let lowerText = text.lowercased()
        let lowerSearch = searchText.lowercased()
        var count = 0
        var searchStart = lowerText.startIndex

        while let range = lowerText.range(of: lowerSearch, range: searchStart..<lowerText.endIndex) {
            count += 1
            searchStart = range.upperBound
        }

        matchCount = count
        currentMatchIndex = count > 0 ? 1 : 0
    }
}

import SwiftUI

struct FullTextView: View {
    let text: String
    @State private var searchText = ""

    var body: some View {
        VStack(spacing: 0) {
            if !text.isEmpty {
                TextField("Search in document...", text: $searchText)
                    .textFieldStyle(.roundedBorder)
                    .padding()

                ScrollView {
                    Text(text)
                        .font(.system(.body, design: .monospaced))
                        .textSelection(.enabled)
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
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
}

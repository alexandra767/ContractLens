import SwiftUI
import SwiftData

struct ClauseDetailView: View {
    let clause: ContractClause
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                // Header
                HStack {
                    Image(systemName: clause.category.icon)
                        .font(.title2)
                        .foregroundStyle(clause.riskLevel.color)

                    VStack(alignment: .leading) {
                        Text(clause.category.displayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                        Text(clause.title)
                            .font(.title3.bold())
                    }

                    Spacer()

                    RiskBadge(level: clause.riskLevel)
                }

                Divider()

                // Plain English Explanation
                VStack(alignment: .leading, spacing: 8) {
                    Label("What This Means", systemImage: "lightbulb.fill")
                        .font(.headline)
                        .foregroundStyle(.clSky)

                    Text(clause.plainEnglishExplanation)
                        .font(.body)
                }

                // Risk Reason
                if !clause.riskReason.isEmpty {
                    VStack(alignment: .leading, spacing: 8) {
                        Label("Why This Risk Level", systemImage: "exclamationmark.triangle.fill")
                            .font(.headline)
                            .foregroundStyle(clause.riskLevel.color)

                        Text(clause.riskReason)
                            .font(.body)
                            .foregroundStyle(.secondary)
                    }
                }

                Divider()

                // Original Text
                VStack(alignment: .leading, spacing: 8) {
                    Label("Original Contract Text", systemImage: "doc.text")
                        .font(.headline)

                    Text(clause.originalText)
                        .font(.callout)
                        .foregroundStyle(.secondary)
                        .padding()
                        .background(Color(.systemGray6), in: RoundedRectangle(cornerRadius: 12))
                }

                // Flag Button
                Button {
                    clause.isFlagged.toggle()
                    try? modelContext.save()
                } label: {
                    Label(
                        clause.isFlagged ? "Unflag This Clause" : "Flag for Review",
                        systemImage: clause.isFlagged ? "flag.fill" : "flag"
                    )
                    .font(.headline)
                    .foregroundStyle(clause.isFlagged ? .red : .clSky)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(
                        (clause.isFlagged ? Color.red : Color.clSky).opacity(0.1),
                        in: RoundedRectangle(cornerRadius: 12)
                    )
                }
            }
            .padding()
        }
        .navigationTitle("Clause Detail")
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .confirmationAction) {
                Button("Done") { dismiss() }
            }
        }
    }
}

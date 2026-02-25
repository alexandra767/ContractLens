import SwiftUI

struct SummaryTabView: View {
    let analysis: DocumentAnalysis

    var body: some View {
        ScrollView {
            VStack(spacing: 20) {
                // Risk Overview
                RiskOverviewCard(analysis: analysis)

                // Detailed Risk with Concerns & Positive Aspects
                RiskOverviewView(analysis: analysis)

                // Summary
                SummaryCard(title: "Plain English Summary", text: analysis.plainEnglishSummary)

                // Key Parties
                if !analysis.parties.isEmpty {
                    SummaryCard(
                        title: "Key Parties",
                        text: analysis.parties.map { "\($0.name) — \($0.role)" }.joined(separator: "\n")
                    )
                }

                LegalDisclaimerBanner()
            }
            .padding()
        }
    }
}

struct RiskOverviewCard: View {
    let analysis: DocumentAnalysis

    var body: some View {
        VStack(spacing: 16) {
            RiskMeter(riskScore: analysis.riskScore, riskLevel: analysis.overallRiskLevel)

            Text("Overall Risk Assessment")
                .font(.headline)

            Text(riskExplanation)
                .font(.subheadline)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(maxWidth: .infinity)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }

    private var riskExplanation: String {
        if !analysis.riskExplanation.isEmpty {
            return analysis.riskExplanation
        }
        switch analysis.overallRiskLevel {
        case .low:
            return "This contract appears to have standard, fair terms with no major red flags."
        case .medium:
            return "This contract has some clauses that deserve closer attention before signing."
        case .high:
            return "This contract contains concerning clauses. Consider consulting a legal professional."
        }
    }
}

struct SummaryCard: View {
    let title: String
    let text: String

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text(title)
                .font(.headline)

            Text(text)
                .font(.body)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

import SwiftUI

struct RiskOverviewView: View {
    let analysis: DocumentAnalysis

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                Image(systemName: "shield.lefthalf.filled")
                    .foregroundStyle(analysis.overallRiskLevel.color)
                Text("Risk Assessment")
                    .font(.headline)
                    .foregroundStyle(Color.clNavy)
                Spacer()
            }

            HStack(spacing: 24) {
                // Circular gauge
                ZStack {
                    Circle()
                        .stroke(Color.clSlate.opacity(0.15), lineWidth: 10)
                    Circle()
                        .trim(from: 0, to: CGFloat(analysis.riskScore) / 100.0)
                        .stroke(analysis.overallRiskLevel.color, style: StrokeStyle(lineWidth: 10, lineCap: .round))
                        .rotationEffect(.degrees(-90))
                        .animation(.easeInOut(duration: 0.8), value: analysis.riskScore)

                    VStack(spacing: 2) {
                        Text("\(analysis.riskScore)")
                            .font(.title.bold())
                            .foregroundStyle(analysis.overallRiskLevel.color)
                        Text("/ 100")
                            .font(.caption2)
                            .foregroundStyle(Color.clSlate)
                    }
                }
                .frame(width: 100, height: 100)
                .accessibilityElement(children: .ignore)
                .accessibilityLabel("Risk score \(analysis.riskScore) out of 100")
                .accessibilityValue("\(analysis.overallRiskLevel.rawValue) risk level")

                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text("Risk Level:")
                            .font(.subheadline)
                            .foregroundStyle(Color.clSlate)
                        Text(analysis.overallRiskLevel.rawValue.capitalized)
                            .font(.subheadline.bold())
                            .foregroundStyle(analysis.overallRiskLevel.color)
                    }

                    // Risk bar
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 4)
                                .fill(Color.clSlate.opacity(0.1))
                                .frame(height: 8)
                            RoundedRectangle(cornerRadius: 4)
                                .fill(analysis.overallRiskLevel.color)
                                .frame(width: geo.size.width * CGFloat(analysis.riskScore) / 100, height: 8)
                                .animation(.easeInOut, value: analysis.riskScore)
                        }
                    }
                    .frame(height: 8)

                    // Clause risk breakdown
                    HStack(spacing: 12) {
                        riskCount(.high)
                        riskCount(.medium)
                        riskCount(.low)
                    }
                }
            }

            // Risk explanation
            if !analysis.riskExplanation.isEmpty {
                Text(analysis.riskExplanation)
                    .font(.subheadline)
                    .foregroundStyle(Color.clSlate)
            }

            // Top Concerns
            if !analysis.topConcerns.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Top Concerns", systemImage: "exclamationmark.triangle.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(.red)

                    ForEach(analysis.topConcerns, id: \.self) { concern in
                        HStack(alignment: .top, spacing: 8) {
                            Circle()
                                .fill(.red)
                                .frame(width: 6, height: 6)
                                .padding(.top, 6)
                            Text(concern)
                                .font(.subheadline)
                                .foregroundStyle(Color.clSlate)
                        }
                    }
                }
            }

            // Positive Aspects
            if !analysis.positiveAspects.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Label("Positive Aspects", systemImage: "checkmark.shield.fill")
                        .font(.subheadline.bold())
                        .foregroundStyle(.green)

                    ForEach(analysis.positiveAspects, id: \.self) { aspect in
                        HStack(alignment: .top, spacing: 8) {
                            Circle()
                                .fill(.green)
                                .frame(width: 6, height: 6)
                                .padding(.top, 6)
                            Text(aspect)
                                .font(.subheadline)
                                .foregroundStyle(Color.clSlate)
                        }
                    }
                }
            }
        }
        .padding()
        .background(Color.clCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 14))
        .shadow(color: .black.opacity(0.06), radius: 6, y: 3)
    }

    private func riskCount(_ level: RiskLevel) -> some View {
        let count = analysis.document?.clauses?.filter { $0.riskLevel == level }.count ?? 0
        return HStack(spacing: 4) {
            Circle()
                .fill(level.color)
                .frame(width: 8, height: 8)
            Text("\(count)")
                .font(.caption2.bold())
                .foregroundStyle(Color.clSlate)
        }
    }
}

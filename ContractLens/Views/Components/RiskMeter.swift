import SwiftUI

struct RiskMeter: View {
    let riskScore: Int
    let riskLevel: RiskLevel

    private var normalizedScore: Double {
        Double(min(max(riskScore, 0), 100)) / 100.0
    }

    private var arcColor: Color {
        switch riskLevel {
        case .low: return .clRiskLow
        case .medium: return .clRiskMedium
        case .high: return .clRiskHigh
        }
    }

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                // Background arc
                Circle()
                    .trim(from: 0.0, to: 0.75)
                    .stroke(Color.clSlate.opacity(0.15), style: StrokeStyle(lineWidth: 10, lineCap: .round))
                    .rotationEffect(.degrees(135))

                // Filled arc
                Circle()
                    .trim(from: 0.0, to: 0.75 * normalizedScore)
                    .stroke(
                        AngularGradient(
                            colors: [.clRiskLow, .clRiskMedium, .clRiskHigh],
                            center: .center,
                            startAngle: .degrees(135),
                            endAngle: .degrees(405)
                        ),
                        style: StrokeStyle(lineWidth: 10, lineCap: .round)
                    )
                    .rotationEffect(.degrees(135))

                // Score text
                VStack(spacing: 2) {
                    Text("\(riskScore)")
                        .font(.system(size: 28, weight: .bold, design: .rounded))
                        .foregroundStyle(arcColor)
                    Text("/ 100")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }
            }
            .frame(width: 100, height: 100)

            Text(riskLevel.rawValue.capitalized + " Risk")
                .font(.caption.weight(.semibold))
                .foregroundStyle(arcColor)
        }
    }
}

#Preview {
    HStack(spacing: 30) {
        RiskMeter(riskScore: 25, riskLevel: .low)
        RiskMeter(riskScore: 55, riskLevel: .medium)
        RiskMeter(riskScore: 85, riskLevel: .high)
    }
    .padding()
}

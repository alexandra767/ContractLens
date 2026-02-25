import SwiftUI

struct RiskBadge: View {
    let riskLevel: RiskLevel

    var body: some View {
        Text(riskLevel.rawValue.capitalized)
            .font(.caption2.bold())
            .foregroundStyle(.white)
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(badgeColor)
            .clipShape(Capsule())
    }

    private var badgeColor: Color {
        switch riskLevel {
        case .low: return .clRiskLow
        case .medium: return .clRiskMedium
        case .high: return .clRiskHigh
        }
    }
}

#Preview {
    HStack(spacing: 12) {
        RiskBadge(riskLevel: .low)
        RiskBadge(riskLevel: .medium)
        RiskBadge(riskLevel: .high)
    }
    .padding()
}

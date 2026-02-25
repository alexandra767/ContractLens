import SwiftUI

struct LegalDisclaimerBanner: View {
    @State private var isExpanded = false

    var body: some View {
        Button {
            withAnimation(.easeInOut(duration: AppConstants.animationDuration)) {
                isExpanded.toggle()
            }
        } label: {
            HStack(alignment: .top, spacing: 10) {
                Image(systemName: "exclamationmark.triangle.fill")
                    .foregroundStyle(.orange)
                    .font(.subheadline)

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Text("Legal Disclaimer")
                            .font(.caption.bold())
                            .foregroundStyle(.primary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.caption2.bold())
                            .foregroundStyle(.secondary)
                            .rotationEffect(.degrees(isExpanded ? 90 : 0))
                    }

                    if isExpanded {
                        Text(AppConstants.legalDisclaimer)
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .lineSpacing(3)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }
            .padding(12)
            .background(Color.orange.opacity(0.08))
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.orange.opacity(0.2), lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
}

#Preview {
    VStack {
        LegalDisclaimerBanner()
    }
    .padding()
}

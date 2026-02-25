import SwiftUI

struct UpgradePromptView: View {
    @State private var showPaywall = false
    @State private var isDismissed = false

    var body: some View {
        if !isDismissed {
            HStack(spacing: 12) {
                Image(systemName: "sparkles")
                    .font(.title3)
                    .foregroundStyle(.white)

                VStack(alignment: .leading, spacing: 2) {
                    Text("Upgrade to Pro")
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                    Text("Unlimited analyses and full clause details")
                        .font(.caption)
                        .foregroundStyle(.white.opacity(0.85))
                }

                Spacer()

                Button("Learn More") {
                    showPaywall = true
                }
                .font(.caption.bold())
                .foregroundStyle(.clNavy)
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(Color.white)
                .clipShape(Capsule())

                Button {
                    withAnimation { isDismissed = true }
                } label: {
                    Image(systemName: "xmark")
                        .font(.caption2.bold())
                        .foregroundStyle(.white.opacity(0.7))
                }
            }
            .padding(14)
            .background(
                LinearGradient(
                    colors: [.clNavy, .clSky],
                    startPoint: .leading,
                    endPoint: .trailing
                )
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .shadow(color: .clSky.opacity(0.3), radius: 8, y: 4)
            .padding(.horizontal)
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .transition(.asymmetric(
                insertion: .move(edge: .top).combined(with: .opacity),
                removal: .move(edge: .top).combined(with: .opacity)
            ))
        }
    }
}

#Preview {
    UpgradePromptView()
        .padding(.top, 40)
}

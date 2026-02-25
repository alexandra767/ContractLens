import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        SubscriptionStoreView(groupID: AppConstants.subscriptionGroupID) {
            VStack(spacing: 20) {
                // App Icon
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 56))
                    .foregroundStyle(.white)
                    .frame(width: 100, height: 100)
                    .background(
                        LinearGradient(
                            colors: [.clNavy, .clSky],
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .clipShape(RoundedRectangle(cornerRadius: 22))
                    .shadow(color: .clSky.opacity(0.4), radius: 12, y: 6)

                Text("Unlock ContractLens Pro")
                    .font(.title.bold())
                    .foregroundStyle(.clNavy)

                // Feature comparison table
                VStack(spacing: 0) {
                    featureComparisonHeader
                    Divider()
                    featureRow("Analyses per month", free: "3", pro: "Unlimited")
                    featureRow("Clauses revealed", free: "3", pro: "All")
                    featureRow("Export as PDF", free: false, pro: true)
                    featureRow("Re-analyze documents", free: false, pro: true)
                    featureRow("Document history", free: "30 days", pro: "Unlimited")
                }
                .background(Color.clCardBackground)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .shadow(color: .black.opacity(0.06), radius: 8, y: 4)
                .padding(.horizontal)

                // Trial badge
                HStack(spacing: 6) {
                    Image(systemName: "gift.fill")
                        .foregroundStyle(.clSky)
                    Text("7-day free trial")
                        .font(.subheadline.weight(.semibold))
                        .foregroundStyle(.clNavy)
                    Spacer()
                    Text("Save 58%")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 10)
                        .padding(.vertical, 4)
                        .background(Color.clRiskLow)
                        .clipShape(Capsule())
                }
                .padding()
                .background(Color.clSky.opacity(0.1))
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding(.horizontal)
            }
            .padding(.vertical)
        }
        .storeButton(.visible, for: .restorePurchases)
        .subscriptionStoreControlStyle(.prominentPicker)
    }

    // MARK: - Feature Comparison Components

    private var featureComparisonHeader: some View {
        HStack {
            Text("Feature")
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Free")
                .frame(width: 70)
            Text("Pro")
                .frame(width: 70)
                .foregroundStyle(.clSky)
        }
        .font(.caption.weight(.semibold))
        .foregroundStyle(.clSlate)
        .padding(.horizontal, 16)
        .padding(.vertical, 10)
        .background(Color.clBackground)
    }

    private func featureRow(_ name: String, free: String, pro: String) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(name)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Text(free)
                    .font(.subheadline)
                    .foregroundStyle(.clSlate)
                    .frame(width: 70)
                Text(pro)
                    .font(.subheadline.weight(.medium))
                    .foregroundStyle(.clNavy)
                    .frame(width: 70)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            Divider()
        }
    }

    private func featureRow(_ name: String, free: Bool, pro: Bool) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(name)
                    .font(.subheadline)
                    .frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: free ? "checkmark.circle.fill" : "xmark.circle")
                    .foregroundStyle(free ? .clRiskLow : .clSlate.opacity(0.4))
                    .frame(width: 70)
                Image(systemName: pro ? "checkmark.circle.fill" : "xmark.circle")
                    .foregroundStyle(pro ? .clRiskLow : .clSlate.opacity(0.4))
                    .frame(width: 70)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 10)
            Divider()
        }
    }
}

#Preview {
    PaywallView()
}

import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(SubscriptionService.self) private var subscriptionService
    @Environment(\.dismiss) private var dismiss

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {

                // MARK: - Scrollable marketing content
                ScrollView {
                    VStack(spacing: 20) {
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
                            .padding(.top, 8)

                        Text("Unlock ContractLens Pro")
                            .font(.title.bold())
                            .foregroundStyle(.clNavy)

                        Text("Pay once. Yours forever.")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

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
                    }
                    .padding(.horizontal, 24)
                    .padding(.bottom, 16)
                }

                // MARK: - Purchase button (outside ScrollView)
                VStack(spacing: 12) {
                    if let product = subscriptionService.product {
                        Button {
                            Task { await subscriptionService.purchase() }
                        } label: {
                            Text("Unlock Pro — \(product.displayPrice)")
                                .font(.headline)
                                .foregroundStyle(.white)
                                .frame(maxWidth: .infinity)
                                .padding(.vertical, 16)
                                .background(Color.clSky, in: RoundedRectangle(cornerRadius: 14))
                        }

                        Text("One-time purchase. Pay once, yours forever.")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                            .multilineTextAlignment(.center)
                    } else if subscriptionService.isLoading {
                        ProgressView("Loading...")
                            .padding()
                    } else {
                        ProgressView()
                            .padding()
                    }

                    if let error = subscriptionService.purchaseError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.red)
                            .multilineTextAlignment(.center)
                    }

                    Button("Restore Purchase") {
                        Task { await subscriptionService.restore() }
                    }
                    .font(.subheadline)
                    .foregroundStyle(.clSlate)

                    HStack(spacing: 4) {
                        NavigationLink("Privacy Policy") { PrivacyPolicyView() }
                        Text("·")
                        Link("Terms of Use", destination: URL(string: "https://www.apple.com/legal/internet-services/itunes/dev/stdeula/")!)
                    }
                    .font(.caption2)
                    .foregroundStyle(.secondary)
                }
                .padding(.horizontal, 24)
                .padding(.top, 12)
                .padding(.bottom, 32)
            }
            .background(Color.clBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .task {
                await subscriptionService.loadProduct()
                if subscriptionService.isProSubscriber { dismiss() }
            }
            .onChange(of: subscriptionService.isProSubscriber) { _, isPro in
                if isPro { dismiss() }
            }
        }
    }

    // MARK: - Feature comparison

    private var featureComparisonHeader: some View {
        HStack {
            Text("Feature").frame(maxWidth: .infinity, alignment: .leading)
            Text("Free").frame(width: 70)
            Text("Pro").frame(width: 70).foregroundStyle(.clSky)
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
                Text(name).font(.subheadline).foregroundStyle(.clNavy).frame(maxWidth: .infinity, alignment: .leading)
                Text(free).font(.subheadline).foregroundStyle(.clSlate).frame(width: 70)
                Text(pro).font(.subheadline.weight(.medium)).foregroundStyle(.clNavy).frame(width: 70)
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
            Divider()
        }
    }

    private func featureRow(_ name: String, free: Bool, pro: Bool) -> some View {
        VStack(spacing: 0) {
            HStack {
                Text(name).font(.subheadline).foregroundStyle(.clNavy).frame(maxWidth: .infinity, alignment: .leading)
                Image(systemName: free ? "checkmark.circle.fill" : "xmark.circle")
                    .foregroundStyle(free ? .clRiskLow : .clSlate.opacity(0.4)).frame(width: 70)
                Image(systemName: pro ? "checkmark.circle.fill" : "xmark.circle")
                    .foregroundStyle(pro ? .clRiskLow : .clSlate.opacity(0.4)).frame(width: 70)
            }
            .padding(.horizontal, 16).padding(.vertical, 10)
            Divider()
        }
    }
}

#Preview {
    PaywallView()
        .environment(SubscriptionService())
}

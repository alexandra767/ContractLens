import SwiftUI
import StoreKit

struct PaywallView: View {
    @Environment(SubscriptionService.self) private var subscriptionService
    @Environment(\.dismiss) private var dismiss
    @State private var viewModel: PaywallViewModel?
    @State private var isPurchasing = false

    var body: some View {
        NavigationStack {
            ScrollView {
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

                    // Product buttons
                    if let vm = viewModel {
                        VStack(spacing: 12) {
                            if vm.isLoading {
                                ProgressView("Loading plans...")
                                    .padding()
                            } else {
                                if let yearly = vm.yearlyProduct {
                                    ProductButton(
                                        product: yearly,
                                        label: "Yearly",
                                        badge: "Best Value",
                                        isPurchasing: isPurchasing
                                    ) {
                                        Task { await purchase(yearly) }
                                    }
                                }

                                if let monthly = vm.monthlyProduct {
                                    ProductButton(
                                        product: monthly,
                                        label: "Monthly",
                                        badge: nil,
                                        isPurchasing: isPurchasing
                                    ) {
                                        Task { await purchase(monthly) }
                                    }
                                }

                                if vm.monthlyProduct == nil && vm.yearlyProduct == nil {
                                    Text("Subscription plans are not available right now. Please try again later.")
                                        .font(.subheadline)
                                        .foregroundStyle(.secondary)
                                        .multilineTextAlignment(.center)
                                        .padding()
                                }
                            }

                            Button {
                                Task {
                                    await vm.restorePurchases()
                                    if vm.isProSubscriber { dismiss() }
                                }
                            } label: {
                                Text("Restore Purchases")
                                    .font(.subheadline)
                                    .foregroundStyle(.clSlate)
                            }
                            .padding(.top, 4)
                        }
                        .padding(.horizontal)

                        if case .error(let msg) = vm.purchaseState {
                            Text(msg)
                                .font(.caption)
                                .foregroundStyle(.red)
                                .padding(.horizontal)
                        }
                    }

                    Spacer(minLength: 20)
                }
                .padding(.vertical)
            }
            .background(Color.clBackground)
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Close") { dismiss() }
                }
            }
            .onAppear {
                if viewModel == nil {
                    viewModel = PaywallViewModel(subscriptionService: subscriptionService)
                }
                Task { await viewModel?.loadProducts() }
            }
        }
    }

    private func purchase(_ product: Product) async {
        guard let vm = viewModel else { return }
        isPurchasing = true
        await vm.purchase(product)
        isPurchasing = false
        if vm.isProSubscriber { dismiss() }
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

// MARK: - Product Button

private struct ProductButton: View {
    let product: Product
    let label: String
    let badge: String?
    let isPurchasing: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    HStack(spacing: 6) {
                        Text(label)
                            .font(.headline)
                        if let badge {
                            Text(badge)
                                .font(.caption2.bold())
                                .foregroundStyle(.white)
                                .padding(.horizontal, 6)
                                .padding(.vertical, 2)
                                .background(Color.clRiskLow, in: Capsule())
                        }
                    }
                    Text(product.description)
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isPurchasing {
                    ProgressView()
                } else {
                    Text(product.displayPrice)
                        .font(.headline)
                }
            }
            .padding()
            .background(Color.clCardBackground, in: RoundedRectangle(cornerRadius: 14))
            .overlay(
                RoundedRectangle(cornerRadius: 14)
                    .stroke(badge != nil ? Color.clSky : Color.clSlate.opacity(0.2), lineWidth: badge != nil ? 2 : 1)
            )
        }
        .buttonStyle(.plain)
        .disabled(isPurchasing)
    }
}

#Preview {
    PaywallView()
        .environment(SubscriptionService())
}

import SwiftUI
import SwiftData
import StoreKit

struct SettingsView: View {
    @Environment(SubscriptionService.self) private var subscriptionService
    @Environment(\.modelContext) private var modelContext
    @State private var showDeleteConfirmation = false
    @State private var showPaywall = false
    @AppStorage("iCloudSyncEnabled") private var iCloudSyncEnabled = false

    var body: some View {
        NavigationStack {
            List {
                subscriptionSection
                cloudSyncSection
                aboutSection
                legalSection
                dataSection
            }
            .navigationTitle("Settings")
            .sheet(isPresented: $showPaywall) {
                PaywallView()
            }
            .alert("Delete All Documents?", isPresented: $showDeleteConfirmation) {
                Button("Cancel", role: .cancel) {}
                Button("Delete All", role: .destructive) {
                    deleteAllDocuments()
                }
            } message: {
                Text("This will permanently delete all documents and their analyses. This action cannot be undone.")
            }
        }
    }

    // MARK: - Sections

    private var subscriptionSection: some View {
        Section("Subscription") {
            HStack {
                Label("Current Plan", systemImage: "crown.fill")
                Spacer()
                Text(subscriptionService.isProSubscriber ? "Pro" : "Free")
                    .foregroundStyle(subscriptionService.isProSubscriber ? .clSky : .secondary)
                    .fontWeight(.medium)
            }

            if !subscriptionService.isProSubscriber {
                Button {
                    showPaywall = true
                } label: {
                    Label("Upgrade to Pro", systemImage: "sparkles")
                }
            }

            if let status = subscriptionService.subscriptionStatus {
                SubscriptionStatusView(status: status)
            }

            Button {
                Task {
                    try? await AppStore.sync()
                }
            } label: {
                Label("Restore Purchases", systemImage: "arrow.clockwise")
            }
        }
    }

    private var aboutSection: some View {
        Section("About") {
            HStack {
                Label("Version", systemImage: "info.circle")
                Spacer()
                Text(appVersion)
                    .foregroundStyle(.secondary)
            }

            NavigationLink {
                AboutView()
            } label: {
                Label("About ContractLens", systemImage: "doc.text.magnifyingglass")
            }

            NavigationLink {
                PrivacyPolicyView()
            } label: {
                Label("Privacy Policy", systemImage: "hand.raised.fill")
            }
        }
    }

    private var legalSection: some View {
        Section("Legal") {
            Text(AppConstants.legalDisclaimer)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

    private var dataSection: some View {
        Section("Data") {
            Button(role: .destructive) {
                showDeleteConfirmation = true
            } label: {
                Label("Delete All Documents", systemImage: "trash")
                    .foregroundStyle(.red)
            }
        }
    }

    private var cloudSyncSection: some View {
        Section("Cloud Sync") {
            if subscriptionService.isProSubscriber {
                Toggle(isOn: $iCloudSyncEnabled) {
                    Label("iCloud Sync", systemImage: "icloud.fill")
                }
                .onChange(of: iCloudSyncEnabled) {
                    // Note: Requires app restart to take effect
                }

                if iCloudSyncEnabled {
                    Text("Documents sync across your devices via iCloud. Changes take effect after restarting the app.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            } else {
                HStack {
                    Label("iCloud Sync", systemImage: "icloud.fill")
                    Spacer()
                    Text("Pro")
                        .font(.caption.bold())
                        .foregroundStyle(.white)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(.clSky, in: Capsule())
                }

                Text("Upgrade to Pro to sync your documents across all your devices with iCloud.")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Button {
                    showPaywall = true
                } label: {
                    Label("Upgrade to Enable Sync", systemImage: "sparkles")
                }
            }
        }
    }

    // MARK: - Helpers

    private var appVersion: String {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }

    private func deleteAllDocuments() {
        do {
            try modelContext.delete(model: LegalDocument.self)
            try modelContext.save()
        } catch {
            print("Failed to delete all documents: \(error)")
        }
    }
}

// MARK: - Subscription Status Row

private struct SubscriptionStatusView: View {
    let status: Product.SubscriptionInfo.Status

    var body: some View {
        HStack {
            Label("Status", systemImage: "creditcard.fill")
            Spacer()
            Text(statusText)
                .foregroundStyle(.secondary)
        }
    }

    private var statusText: String {
        switch status.state {
        case .subscribed: return "Active"
        case .expired: return "Expired"
        case .inBillingRetryPeriod: return "Billing Issue"
        case .inGracePeriod: return "Grace Period"
        case .revoked: return "Revoked"
        default: return "Unknown"
        }
    }
}

#Preview {
    SettingsView()
        .environment(SubscriptionService())
}

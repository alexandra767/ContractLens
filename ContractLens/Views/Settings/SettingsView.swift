import SwiftUI
import SwiftData
import CloudKit

struct SettingsView: View {
    @Environment(SubscriptionService.self) private var subscriptionService
    @Environment(\.modelContext) private var modelContext
    @State private var showDeleteConfirmation = false
    @State private var showPaywall = false
    @AppStorage("iCloudSyncEnabled") private var iCloudSyncEnabled = false
    @AppStorage("appLockEnabled") private var appLockEnabled = false
    @AppStorage("cloudKitInitialized") private var cloudKitInitialized = false
    @AppStorage("cloudKitError") private var cloudKitError = ""
    @State private var ckAccountStatus = "checking…"

    var body: some View {
        NavigationStack {
            List {
                securitySection
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

    private var securitySection: some View {
        Section("Security") {
            Toggle(isOn: $appLockEnabled) {
                Label("App Lock", systemImage: "faceid")
            }
            Text("Require Face ID, Touch ID, or passcode to open ContractLens.")
                .font(.caption)
                .foregroundStyle(.secondary)
        }
    }

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

            Button {
                Task { await subscriptionService.restore() }
            } label: {
                Label("Restore Purchase", systemImage: "arrow.clockwise")
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
                HelpView()
            } label: {
                Label("Help & Support", systemImage: "questionmark.circle.fill")
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
            // Temporary diagnostic — remove after debugging
            let _ = Task {
                do {
                    let status = try await CKContainer(identifier: "iCloud.com.contractlens.app").accountStatus()
                    await MainActor.run {
                        switch status {
                        case .available: ckAccountStatus = "available ✓"
                        case .noAccount: ckAccountStatus = "no iCloud account"
                        case .restricted: ckAccountStatus = "restricted"
                        case .temporarilyUnavailable: ckAccountStatus = "temporarily unavailable"
                        default: ckAccountStatus = "unknown (\(status.rawValue))"
                        }
                    }
                } catch {
                    await MainActor.run { ckAccountStatus = "error: \(error.localizedDescription)" }
                }
            }
            if subscriptionService.isProSubscriber {
                Toggle(isOn: $iCloudSyncEnabled) {
                    Label("iCloud Sync", systemImage: "icloud.fill")
                }
                .onChange(of: iCloudSyncEnabled) {
                    // Note: Requires app restart to take effect
                }

                if iCloudSyncEnabled {
                    HStack(spacing: 6) {
                        Image(systemName: cloudKitInitialized ? "checkmark.circle.fill" : "xmark.circle.fill")
                            .foregroundStyle(cloudKitInitialized ? .green : .red)
                        Text(cloudKitInitialized ? "iCloud active" : "iCloud error — restart app")
                            .font(.caption)
                            .foregroundStyle(cloudKitInitialized ? .green : .red)
                    }
                    if !cloudKitError.isEmpty {
                        Text(cloudKitError)
                            .font(.caption)
                            .foregroundStyle(.red)
                    }
                    Text("CK account: \(ckAccountStatus)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                    Text("New documents sync across your devices. Documents created before enabling sync stay local only.")
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


#Preview {
    SettingsView()
        .environment(SubscriptionService())
}

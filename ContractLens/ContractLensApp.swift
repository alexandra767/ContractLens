import SwiftUI
import SwiftData

@main
struct ContractLensApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("iCloudSyncEnabled") private var iCloudSyncEnabled = false
    @State private var subscriptionService = SubscriptionService()
    @State private var usageMeterService = UsageMeterService()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            LegalDocument.self,
            DocumentAnalysis.self,
            ContractClause.self
        ])

        let iCloudEnabled = UserDefaults.standard.bool(forKey: "iCloudSyncEnabled")

        // Try with preferred CloudKit setting, fall back to local-only if it fails
        let configurations: [ModelConfiguration] = [
            ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: iCloudEnabled ? .automatic : .none
            ),
            ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .none)
        ]

        for config in configurations {
            if let container = try? ModelContainer(for: schema, configurations: [config]) {
                return container
            }
        }

        fatalError("Could not create ModelContainer with any configuration.")
    }()

    var body: some Scene {
        WindowGroup {
            if hasSeenOnboarding {
                ContentView()
            } else {
                OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
            }
        }
        .modelContainer(sharedModelContainer)
        .environment(subscriptionService)
        .environment(usageMeterService)
    }
}

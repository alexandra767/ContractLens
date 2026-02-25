import SwiftUI
import SwiftData

@main
struct ContractLensApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @AppStorage("iCloudSyncEnabled") private var iCloudSyncEnabled = false
    @AppStorage("appLockEnabled") private var appLockEnabled = false
    @State private var isUnlocked = false
    @Environment(\.scenePhase) private var scenePhase
    @State private var subscriptionService = SubscriptionService()
    @State private var usageMeterService = UsageMeterService()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            LegalDocument.self,
            DocumentAnalysis.self,
            ContractClause.self
        ])

        let iCloudEnabled = UserDefaults.standard.bool(forKey: "iCloudSyncEnabled")

        // CloudKit requires persistent history tracking, which is only enabled when the
        // store is first created with CloudKit. Using a distinct store name ("CloudStore")
        // ensures a fresh compatible file is created, avoiding SwiftDataError error 1.
        let config = iCloudEnabled
            ? ModelConfiguration(
                "CloudStore",
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .private("iCloud.com.contractlens.app")
              )
            : ModelConfiguration(
                schema: schema,
                isStoredInMemoryOnly: false,
                cloudKitDatabase: .none
              )

        do {
            let container = try ModelContainer(for: schema, configurations: [config])
            UserDefaults.standard.set(iCloudEnabled, forKey: "cloudKitInitialized")
            UserDefaults.standard.set("", forKey: "cloudKitError")
            return container
        } catch {
            UserDefaults.standard.set(false, forKey: "cloudKitInitialized")
            UserDefaults.standard.set(error.localizedDescription, forKey: "cloudKitError")
            do {
                return try ModelContainer(
                    for: schema,
                    configurations: [ModelConfiguration(schema: schema, isStoredInMemoryOnly: false, cloudKitDatabase: .none)]
                )
            } catch {
                fatalError("Could not create ModelContainer: \(error)")
            }
        }
    }()

    var body: some Scene {
        WindowGroup {
            Group {
                if appLockEnabled && !isUnlocked {
                    AppLockView(isUnlocked: $isUnlocked)
                } else if hasSeenOnboarding {
                    ContentView()
                } else {
                    OnboardingView(hasSeenOnboarding: $hasSeenOnboarding)
                }
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase == .background && appLockEnabled {
                    isUnlocked = false
                }
            }
        }
        .modelContainer(sharedModelContainer)
        .environment(subscriptionService)
        .environment(usageMeterService)
    }
}

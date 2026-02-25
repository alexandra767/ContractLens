import SwiftUI
import SwiftData

@main
struct ContractLensApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding = false
    @State private var subscriptionService = SubscriptionService()
    @State private var usageMeterService = UsageMeterService()

    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            LegalDocument.self,
            DocumentAnalysis.self,
            ContractClause.self
        ])
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            cloudKitDatabase: .automatic
        )

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
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

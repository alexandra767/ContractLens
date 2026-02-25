import Foundation
import SwiftData

@Observable
final class SettingsViewModel {

    var showDeleteAllConfirmation = false
    var showResetUsageConfirmation = false
    var errorMessage: String?
    var successMessage: String?

    let appVersion: String = {
        let version = Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
        let build = Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1"
        return "\(version) (\(build))"
    }()

    // MARK: - Subscription Info

    func subscriptionStatusText(isPro: Bool) -> String {
        isPro ? "Pro" : "Free"
    }

    // MARK: - Usage Info

    func remainingAnalysesText(usageMeter: UsageMeterService, isPro: Bool) -> String {
        if isPro { return "Unlimited" }
        return "\(usageMeter.remainingFreeAnalyses) of \(AppConstants.freeAnalysesPerMonth) remaining"
    }

    // MARK: - Data Management

    /// Deletes all documents, analyses, and clauses from SwiftData.
    func deleteAllDocuments(context: ModelContext) {
        do {
            try context.delete(model: ContractClause.self)
            try context.delete(model: DocumentAnalysis.self)
            try context.delete(model: LegalDocument.self)
            try context.save()
            successMessage = "All documents deleted."
        } catch {
            errorMessage = "Failed to delete documents: \(error.localizedDescription)"
        }
    }

    /// Returns the count of all stored documents.
    func documentCount(context: ModelContext) -> Int {
        let descriptor = FetchDescriptor<LegalDocument>()
        return (try? context.fetchCount(descriptor)) ?? 0
    }

    /// Resets the monthly free-tier usage counter.
    func resetUsage(usageMeterService: UsageMeterService) {
        usageMeterService.resetUsage()
        successMessage = "Usage counter reset."
    }

    // MARK: - Export

    func exportAsPDF(_ document: LegalDocument) -> Data {
        ExportService().generatePDFReport(for: document)
    }

    func exportAsText(_ document: LegalDocument) -> String {
        ExportService().generateTextReport(for: document)
    }

    // MARK: - Restore Purchases

    func restorePurchases(subscriptionService: SubscriptionService) async {
        await subscriptionService.restorePurchases()
        if subscriptionService.isProSubscriber {
            successMessage = "Purchases restored successfully."
        } else {
            errorMessage = "No active subscriptions found."
        }
    }

    func dismissMessages() {
        errorMessage = nil
        successMessage = nil
    }
}

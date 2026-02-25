import Foundation
import StoreKit

@Observable @MainActor
final class PaywallViewModel {

    enum PurchaseState: Equatable {
        case idle
        case purchasing
        case purchased
        case error(String)
    }

    private(set) var purchaseState: PurchaseState = .idle
    var selectedProduct: Product?

    private let subscriptionService: SubscriptionService

    init(subscriptionService: SubscriptionService) {
        self.subscriptionService = subscriptionService
    }

    var isProSubscriber: Bool {
        subscriptionService.isProSubscriber
    }

    var isLoading: Bool {
        subscriptionService.isLoading
    }

    var monthlyProduct: Product? {
        subscriptionService.monthlyProduct
    }

    var yearlyProduct: Product? {
        subscriptionService.yearlyProduct
    }

    var isPurchasing: Bool {
        purchaseState == .purchasing
    }

    // MARK: - Purchase

    func purchase(_ product: Product) async {
        purchaseState = .purchasing

        do {
            let success = try await subscriptionService.purchase(product)
            if success {
                purchaseState = .purchased
            } else {
                purchaseState = .idle
            }
        } catch {
            purchaseState = .error(error.localizedDescription)
        }
    }

    // MARK: - Restore

    func restorePurchases() async {
        purchaseState = .purchasing
        await subscriptionService.restorePurchases()

        if subscriptionService.isProSubscriber {
            purchaseState = .purchased
        } else {
            purchaseState = .idle
        }
    }

    // MARK: - Reload

    func loadProducts() async {
        await subscriptionService.loadProducts()
    }

    func dismissError() {
        purchaseState = .idle
    }
}

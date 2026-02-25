import Foundation
import StoreKit

@Observable @MainActor
final class SubscriptionService {

    private(set) var isProSubscriber = false
    private(set) var product: Product?
    private(set) var isLoading = false
    var purchaseError: String?
    private var transactionListenerTask: Task<Void, Never>?

    init() {
        listenForTransactions()
        Task { @MainActor in
            await loadProduct()
            await refreshStatus()
        }
    }

    // MARK: - Load Product

    func loadProduct() async {
        isLoading = true
        defer { isLoading = false }

        do {
            let products = try await Product.products(for: [AppConstants.proProductID])
            product = products.first
        } catch {
            purchaseError = "Could not load product."
        }
    }

    // MARK: - Purchase

    func purchase() async {
        guard let product else {
            purchaseError = "Product not available."
            return
        }
        purchaseError = nil

        do {
            let result = try await product.purchase()
            switch result {
            case .success(let verification):
                if let transaction = try? verification.payloadValue {
                    await transaction.finish()
                    await refreshStatus()
                }
            case .userCancelled:
                break
            case .pending:
                purchaseError = "Purchase is pending approval."
            @unknown default:
                break
            }
        } catch {
            purchaseError = error.localizedDescription
        }
    }

    // MARK: - Restore

    func restore() async {
        do {
            try await AppStore.sync()
            await refreshStatus()
        } catch {
            purchaseError = "Could not restore purchases."
        }
    }

    // MARK: - Status

    func refreshStatus() async {
        var entitled = false
        for await result in Transaction.currentEntitlements {
            if let transaction = try? result.payloadValue,
               transaction.productID == AppConstants.proProductID,
               transaction.revocationDate == nil {
                entitled = true
                break
            }
        }
        isProSubscriber = entitled
    }

    // MARK: - Private

    private func listenForTransactions() {
        transactionListenerTask = Task.detached { [weak self] in
            for await result in Transaction.updates {
                if let transaction = try? result.payloadValue {
                    await transaction.finish()
                    await self?.refreshStatus()
                }
            }
        }
    }
}

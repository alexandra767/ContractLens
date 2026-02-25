import Foundation

enum AppConstants {
    static let appName = "ContractLens"
    static let appTagline = "Understand Before You Sign"

    // MARK: - Free Tier Limits
    static let freeAnalysesPerMonth = 3
    static let freeClauseLimit = 3
    static let freeHistoryDays = 30

    // MARK: - StoreKit Product IDs
    static let monthlySubscriptionID = "com.contractlens.pro.monthly"
    static let yearlySubscriptionID = "com.contractlens.pro.yearly"
    static let subscriptionGroupID = "ContractLensPro"

    // MARK: - AI Analysis
    static let maxTokensPerChunk = 800
    static let chunkOverlapCharacters = 200
    static let maxClausesPerChunk = 5
    static let maxTopConcerns = 3
    static let maxPositiveAspects = 3

    // MARK: - UI
    static let documentGridColumns = 2
    static let thumbnailSize: CGFloat = 200
    static let animationDuration: Double = 0.3

    // MARK: - Legal
    static let legalDisclaimer = """
        ContractLens provides AI-generated analysis for informational purposes only. \
        It is not a substitute for legal advice from a licensed attorney. \
        Always consult a qualified legal professional before making decisions \
        based on contract analysis.
        """
}

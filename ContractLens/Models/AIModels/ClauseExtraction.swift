import Foundation
import FoundationModels

@Generable
struct ClauseExtractionOutput {
    @Guide(description: "Array of important clauses found in this section, maximum 5")
    var clauses: [ExtractedClause]
}

@Generable
struct ExtractedClause {
    @Guide(description: "Short title for this clause")
    var title: String

    @Guide(description: "The original text of the clause from the contract")
    var originalText: String

    @Guide(description: "Plain English explanation of what this clause means")
    var explanation: String

    @Guide(description: "Risk level: low, medium, or high")
    var riskLevel: String

    @Guide(description: "Why this risk level was assigned")
    var riskReason: String

    @Guide(description: "Category: autoRenewal, termination, penalty, nonCompete, liability, indemnification, confidentiality, intellectualProperty, disputeResolution, payment, or other")
    var category: String
}

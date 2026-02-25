import Foundation
import FoundationModels

@Generable
struct ContractSummaryOutput {
    @Guide(description: "A plain English summary of the contract in 3-5 sentences, written for someone without legal training")
    var summary: String

    @Guide(description: "The type of contract: lease, employment, nda, freelance, service, or other")
    var documentType: String

    @Guide(description: "Brief overview of who the parties are and their roles")
    var partiesOverview: String
}

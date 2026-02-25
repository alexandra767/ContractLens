import Foundation
import FoundationModels

@Generable
struct PartyExtractionOutput {
    @Guide(description: "Array of parties/people/organizations mentioned in the contract")
    var parties: [ExtractedParty]
}

@Generable
struct ExtractedParty {
    @Guide(description: "Name of the party")
    var name: String

    @Guide(description: "Role in the contract (e.g., Landlord, Tenant, Employer, Employee, Client, Contractor)")
    var role: String

    @Guide(description: "Key obligations this party has under the contract")
    var obligations: String
}

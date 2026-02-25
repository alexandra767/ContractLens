import Foundation
import FoundationModels

@Generable
struct KeyDateExtractionOutput {
    @Guide(description: "Array of important dates, deadlines, and time periods found in the contract")
    var dates: [ExtractedDate]
}

@Generable
struct ExtractedDate {
    @Guide(description: "What this date represents (e.g., Lease Start Date, Payment Due, Notice Period)")
    var label: String

    @Guide(description: "The date or time period as stated in the contract")
    var dateString: String

    @Guide(description: "Whether this is a deadline that requires action")
    var isDeadline: Bool
}

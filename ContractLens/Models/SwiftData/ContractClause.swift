import Foundation
import SwiftData

// MARK: - Enums

enum ClauseCategory: String, Codable, CaseIterable {
    case autoRenewal
    case termination
    case penalty
    case nonCompete
    case liability
    case indemnification
    case confidentiality
    case intellectualProperty
    case disputeResolution
    case payment
    case other

    var displayName: String {
        switch self {
        case .autoRenewal: return "Auto-Renewal"
        case .termination: return "Termination"
        case .penalty: return "Penalty"
        case .nonCompete: return "Non-Compete"
        case .liability: return "Liability"
        case .indemnification: return "Indemnification"
        case .confidentiality: return "Confidentiality"
        case .intellectualProperty: return "Intellectual Property"
        case .disputeResolution: return "Dispute Resolution"
        case .payment: return "Payment"
        case .other: return "Other"
        }
    }

    var icon: String {
        switch self {
        case .autoRenewal: return "arrow.triangle.2.circlepath"
        case .termination: return "xmark.circle"
        case .penalty: return "exclamationmark.triangle"
        case .nonCompete: return "hand.raised"
        case .liability: return "shield.lefthalf.filled"
        case .indemnification: return "checkmark.shield"
        case .confidentiality: return "lock.fill"
        case .intellectualProperty: return "lightbulb"
        case .disputeResolution: return "scale.3d"
        case .payment: return "dollarsign.circle"
        case .other: return "doc.text"
        }
    }
}

// MARK: - ContractClause Model

@Model
final class ContractClause {
    var id: UUID = UUID()
    var title: String = ""
    var originalText: String = ""
    var plainEnglishExplanation: String = ""
    var riskLevel: RiskLevel = RiskLevel.low
    var riskReason: String = ""
    var category: ClauseCategory = ClauseCategory.other
    var isFlagged: Bool = false
    var sortOrder: Int = 0

    var document: LegalDocument?

    init(
        id: UUID = UUID(),
        title: String,
        originalText: String,
        plainEnglishExplanation: String,
        riskLevel: RiskLevel,
        riskReason: String = "",
        category: ClauseCategory,
        isFlagged: Bool = false,
        sortOrder: Int = 0,
        document: LegalDocument? = nil
    ) {
        self.id = id
        self.title = title
        self.originalText = originalText
        self.plainEnglishExplanation = plainEnglishExplanation
        self.riskLevel = riskLevel
        self.riskReason = riskReason
        self.category = category
        self.isFlagged = isFlagged
        self.sortOrder = sortOrder
        self.document = document
    }
}

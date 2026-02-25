import Foundation
import SwiftData
import SwiftUI

// MARK: - Enums

enum RiskLevel: String, Codable, CaseIterable {
    case low
    case medium
    case high

    var color: Color {
        switch self {
        case .low: return .green
        case .medium: return .orange
        case .high: return .red
        }
    }
}

// MARK: - Helper Structs

struct PartyInfo: Codable, Identifiable {
    var id: String { name }
    var name: String
    var role: String
    var obligations: [String]
}

struct KeyDateInfo: Codable, Identifiable {
    var id: String { label }
    var label: String
    var dateString: String
    var isDeadline: Bool
}

struct ObligationInfo: Codable, Identifiable {
    var id: String { "\(party)-\(description)" }
    var party: String
    var description: String
    var isRecurring: Bool
}

// MARK: - DocumentAnalysis Model

@Model
final class DocumentAnalysis {
    var id: UUID = UUID()
    var plainEnglishSummary: String = ""
    var overallRiskLevel: RiskLevel = RiskLevel.low
    var riskScore: Int = 0
    var partiesJSON: String = "[]"
    var keyDatesJSON: String = "[]"
    var obligationsJSON: String = "[]"
    var riskExplanation: String = ""
    var topConcernsJSON: String = "[]"
    var positiveAspectsJSON: String = "[]"
    var dateAnalyzed: Date = Date()

    var document: LegalDocument?

    // MARK: - Computed Properties

    var parties: [PartyInfo] {
        guard let data = partiesJSON.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([PartyInfo].self, from: data)) ?? []
    }

    var keyDates: [KeyDateInfo] {
        guard let data = keyDatesJSON.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([KeyDateInfo].self, from: data)) ?? []
    }

    var obligations: [ObligationInfo] {
        guard let data = obligationsJSON.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([ObligationInfo].self, from: data)) ?? []
    }

    var topConcerns: [String] {
        guard let data = topConcernsJSON.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([String].self, from: data)) ?? []
    }

    var positiveAspects: [String] {
        guard let data = positiveAspectsJSON.data(using: .utf8) else { return [] }
        return (try? JSONDecoder().decode([String].self, from: data)) ?? []
    }

    init(
        id: UUID = UUID(),
        plainEnglishSummary: String,
        overallRiskLevel: RiskLevel,
        riskScore: Int,
        partiesJSON: String = "[]",
        keyDatesJSON: String = "[]",
        obligationsJSON: String = "[]",
        riskExplanation: String = "",
        topConcernsJSON: String = "[]",
        positiveAspectsJSON: String = "[]",
        dateAnalyzed: Date = Date(),
        document: LegalDocument? = nil
    ) {
        self.id = id
        self.plainEnglishSummary = plainEnglishSummary
        self.overallRiskLevel = overallRiskLevel
        self.riskScore = min(max(riskScore, 0), 100)
        self.partiesJSON = partiesJSON
        self.keyDatesJSON = keyDatesJSON
        self.obligationsJSON = obligationsJSON
        self.riskExplanation = riskExplanation
        self.topConcernsJSON = topConcernsJSON
        self.positiveAspectsJSON = positiveAspectsJSON
        self.dateAnalyzed = dateAnalyzed
        self.document = document
    }
}

import Foundation
import FoundationModels
import SwiftData

@Observable
final class AIAnalysisService {

    enum AnalysisError: LocalizedError {
        case emptyText
        case sessionCreationFailed
        case analysisInterrupted

        var errorDescription: String? {
            switch self {
            case .emptyText:
                return "No text to analyze. Please ensure the document has readable content."
            case .sessionCreationFailed:
                return "Failed to start AI analysis. Please try again."
            case .analysisInterrupted:
                return "Analysis was interrupted. Please try again."
            }
        }
    }

    enum AnalysisStep: String, CaseIterable {
        case summarizing = "Summarizing contract..."
        case extractingClauses = "Extracting clauses..."
        case identifyingParties = "Identifying parties..."
        case findingDates = "Finding key dates..."
        case assessingRisk = "Assessing risk..."
        case saving = "Saving results..."
    }

    private(set) var currentStep: AnalysisStep?
    private(set) var progress: Double = 0

    private let chunkingService = TextChunkingService()

    /// Runs the full multi-pass analysis pipeline on a document's raw text.
    /// Returns a populated DocumentAnalysis and array of ContractClause objects.
    @MainActor
    func analyzeDocument(_ document: LegalDocument, modelContext: ModelContext) async throws {
        let text = document.rawText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !text.isEmpty else { throw AnalysisError.emptyText }

        let totalSteps = Double(AnalysisStep.allCases.count)
        var stepIndex = 0.0

        func advanceStep(_ step: AnalysisStep) {
            currentStep = step
            stepIndex += 1
            progress = stepIndex / totalSteps
        }

        // Pass 1: Summary
        advanceStep(.summarizing)
        let summary = try await generateSummary(for: text)

        // Pass 2: Clause Extraction (chunked)
        advanceStep(.extractingClauses)
        let chunks = chunkingService.chunkText(text)
        var allClauses: [ExtractedClause] = []
        for chunk in chunks {
            let extraction = try await extractClauses(from: chunk.text)
            allClauses.append(contentsOf: extraction.clauses)
        }

        // Pass 3: Party Extraction
        advanceStep(.identifyingParties)
        let parties = try await extractParties(from: text)

        // Pass 4: Key Date Extraction
        advanceStep(.findingDates)
        let dates = try await extractDates(from: text)

        // Pass 5: Risk Assessment
        advanceStep(.assessingRisk)
        let risk = try await assessRisk(for: text)

        // Pass 6: Save to SwiftData
        advanceStep(.saving)

        // Map DocumentType from AI output
        if let docType = DocumentType(rawValue: summary.documentType) {
            document.documentType = docType
        }

        // Create party JSON
        let partyInfos = parties.parties.map { party in
            PartyInfo(name: party.name, role: party.role, obligations: [party.obligations])
        }
        let partiesJSON = (try? String(data: JSONEncoder().encode(partyInfos), encoding: .utf8)) ?? "[]"

        // Create date JSON
        let dateInfos = dates.dates.map { date in
            KeyDateInfo(label: date.label, dateString: date.dateString, isDeadline: date.isDeadline)
        }
        let datesJSON = (try? String(data: JSONEncoder().encode(dateInfos), encoding: .utf8)) ?? "[]"

        // Map risk level
        let riskLevel = RiskLevel(rawValue: risk.overallRisk) ?? .medium

        // Create analysis
        let analysis = DocumentAnalysis(
            plainEnglishSummary: summary.summary,
            overallRiskLevel: riskLevel,
            riskScore: min(max(risk.riskScore, 0), 100),
            partiesJSON: partiesJSON,
            keyDatesJSON: datesJSON,
            document: document
        )
        modelContext.insert(analysis)

        // Create clauses
        for (index, clause) in allClauses.enumerated() {
            let clauseCategory = ClauseCategory(rawValue: clause.category) ?? .other
            let clauseRisk = RiskLevel(rawValue: clause.riskLevel) ?? .medium

            let contractClause = ContractClause(
                title: clause.title,
                originalText: clause.originalText,
                plainEnglishExplanation: clause.explanation,
                riskLevel: clauseRisk,
                riskReason: clause.riskReason,
                category: clauseCategory,
                sortOrder: index,
                document: document
            )
            modelContext.insert(contractClause)
        }

        document.dateModified = Date()
        try modelContext.save()

        currentStep = nil
        progress = 1.0
    }

    /// Resets progress state.
    func reset() {
        currentStep = nil
        progress = 0
    }

    // MARK: - Private AI Calls

    private func generateSummary(for text: String) async throws -> ContractSummaryOutput {
        let session = LanguageModelSession()
        let prompt = """
        Analyze this contract and provide a summary. Focus on what matters most to a non-lawyer:

        \(text.prefix(12000))
        """
        return try await session.respond(to: prompt, generating: ContractSummaryOutput.self)
    }

    private func extractClauses(from text: String) async throws -> ClauseExtractionOutput {
        let session = LanguageModelSession()
        let prompt = """
        Extract the most important clauses from this contract section. \
        Focus on clauses that could affect the signer's rights, obligations, or finances:

        \(text)
        """
        return try await session.respond(to: prompt, generating: ClauseExtractionOutput.self)
    }

    private func extractParties(from text: String) async throws -> PartyExtractionOutput {
        let session = LanguageModelSession()
        let prompt = """
        Identify all parties mentioned in this contract, their roles, and key obligations:

        \(text.prefix(12000))
        """
        return try await session.respond(to: prompt, generating: PartyExtractionOutput.self)
    }

    private func extractDates(from text: String) async throws -> KeyDateExtractionOutput {
        let session = LanguageModelSession()
        let prompt = """
        Find all important dates, deadlines, and time periods in this contract:

        \(text.prefix(12000))
        """
        return try await session.respond(to: prompt, generating: KeyDateExtractionOutput.self)
    }

    private func assessRisk(for text: String) async throws -> RiskAssessmentOutput {
        let session = LanguageModelSession()
        let prompt = """
        Assess the overall risk of this contract for the person signing it. \
        Consider unfavorable terms, missing protections, and potential pitfalls:

        \(text.prefix(12000))
        """
        return try await session.respond(to: prompt, generating: RiskAssessmentOutput.self)
    }
}

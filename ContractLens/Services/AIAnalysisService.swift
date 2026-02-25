import Foundation
import FoundationModels
import SwiftData

@Observable @MainActor
final class AIAnalysisService {

    enum AnalysisError: LocalizedError {
        case emptyText
        case sessionCreationFailed
        case analysisInterrupted
        case deviceNotSupported
        case analysisTimedOut
        case cancelled

        var errorDescription: String? {
            switch self {
            case .emptyText:
                return "No text to analyze. Please ensure the document has readable content."
            case .sessionCreationFailed:
                return "Failed to start AI analysis. Please try again."
            case .analysisInterrupted:
                return "Analysis was interrupted. Please try again."
            case .deviceNotSupported:
                return "This device doesn't support on-device AI analysis. iPhone 15 Pro or newer is required."
            case .analysisTimedOut:
                return "Analysis took too long. Please try again with a shorter document."
            case .cancelled:
                return "Analysis was cancelled."
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
    private(set) var isCancelled = false

    private let chunkingService = TextChunkingService()

    /// Runs the full multi-pass analysis pipeline on a document's raw text.
    /// Returns a populated DocumentAnalysis and array of ContractClause objects.
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
        guard !isCancelled else { throw AnalysisError.cancelled }

        // Pass 2: Clause Extraction (chunked)
        advanceStep(.extractingClauses)
        let chunks = chunkingService.chunkText(text)
        var allClauses: [ExtractedClause] = []
        for chunk in chunks {
            let extraction = try await extractClauses(from: chunk.text)
            allClauses.append(contentsOf: extraction.clauses)
        }
        guard !isCancelled else { throw AnalysisError.cancelled }

        // Pass 3: Party Extraction
        advanceStep(.identifyingParties)
        let parties = try await extractParties(from: text)
        guard !isCancelled else { throw AnalysisError.cancelled }

        // Pass 4: Key Date Extraction
        advanceStep(.findingDates)
        let dates = try await extractDates(from: text)
        guard !isCancelled else { throw AnalysisError.cancelled }

        // Pass 5: Risk Assessment
        advanceStep(.assessingRisk)
        let risk = try await assessRisk(for: text)
        guard !isCancelled else { throw AnalysisError.cancelled }

        // Pass 6: Save to SwiftData
        advanceStep(.saving)

        // Map DocumentType from AI output
        if let docType = DocumentType(rawValue: summary.documentType) {
            document.documentType = docType
        }

        // Create party JSON — split obligations string into individual items
        let partyInfos = parties.parties.map { party in
            let items = party.obligations
                .components(separatedBy: ". ")
                .map { $0.trimmingCharacters(in: .whitespacesAndNewlines).trimmingCharacters(in: CharacterSet(charactersIn: ".")) }
                .filter { !$0.isEmpty }
            return PartyInfo(name: party.name, role: party.role, obligations: items.isEmpty ? [party.obligations] : items)
        }
        let partiesJSON = (try? String(data: JSONEncoder().encode(partyInfos), encoding: .utf8)) ?? "[]"

        // Create obligation JSON from party data
        let obligationInfos = parties.parties.map { party in
            ObligationInfo(party: party.name, description: party.obligations, isRecurring: false)
        }
        let obligationsJSON = (try? String(data: JSONEncoder().encode(obligationInfos), encoding: .utf8)) ?? "[]"

        // Create date JSON
        let dateInfos = dates.dates.map { date in
            KeyDateInfo(label: date.label, dateString: date.dateString, isDeadline: date.isDeadline)
        }
        let datesJSON = (try? String(data: JSONEncoder().encode(dateInfos), encoding: .utf8)) ?? "[]"

        // Map risk level
        let riskLevel = RiskLevel(rawValue: risk.overallRisk) ?? .medium

        // Create risk detail JSON
        let topConcernsJSON = (try? String(data: JSONEncoder().encode(risk.topConcerns), encoding: .utf8)) ?? "[]"
        let positiveAspectsJSON = (try? String(data: JSONEncoder().encode(risk.positiveAspects), encoding: .utf8)) ?? "[]"

        // Create analysis
        let analysis = DocumentAnalysis(
            plainEnglishSummary: summary.summary,
            overallRiskLevel: riskLevel,
            riskScore: min(max(risk.riskScore, 0), 100),
            partiesJSON: partiesJSON,
            keyDatesJSON: datesJSON,
            obligationsJSON: obligationsJSON,
            riskExplanation: risk.explanation,
            topConcernsJSON: topConcernsJSON,
            positiveAspectsJSON: positiveAspectsJSON,
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

    /// Cancels the in-progress analysis.
    func cancel() {
        isCancelled = true
    }

    /// Resets progress state.
    func reset() {
        currentStep = nil
        progress = 0
        isCancelled = false
    }

    // MARK: - Private AI Calls

    private func generateSummary(for text: String) async throws -> ContractSummaryOutput {
        let session = LanguageModelSession()
        let prompt = """
        Analyze this contract and provide a summary. Focus on what matters most to a non-lawyer:

        \(text.prefix(12000))
        """
        return try await session.respond(to: prompt, generating: ContractSummaryOutput.self).content
    }

    private func extractClauses(from text: String) async throws -> ClauseExtractionOutput {
        let session = LanguageModelSession()
        let prompt = """
        Extract the most important clauses from this contract section. \
        Focus on clauses that could affect the signer's rights, obligations, or finances:

        \(text)
        """
        return try await session.respond(to: prompt, generating: ClauseExtractionOutput.self).content
    }

    private func extractParties(from text: String) async throws -> PartyExtractionOutput {
        let session = LanguageModelSession()
        let prompt = """
        Identify all parties mentioned in this contract, their roles, and key obligations:

        \(text.prefix(12000))
        """
        return try await session.respond(to: prompt, generating: PartyExtractionOutput.self).content
    }

    private func extractDates(from text: String) async throws -> KeyDateExtractionOutput {
        let session = LanguageModelSession()
        let prompt = """
        Find all important dates, deadlines, and time periods in this contract:

        \(text.prefix(12000))
        """
        return try await session.respond(to: prompt, generating: KeyDateExtractionOutput.self).content
    }

    private func assessRisk(for text: String) async throws -> RiskAssessmentOutput {
        let session = LanguageModelSession()
        let prompt = """
        Assess the overall risk of this contract for the person signing it. \
        Consider unfavorable terms, missing protections, and potential pitfalls:

        \(text.prefix(12000))
        """
        return try await session.respond(to: prompt, generating: RiskAssessmentOutput.self).content
    }
}

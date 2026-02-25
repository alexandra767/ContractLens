import Foundation
import SwiftData

@Observable
final class AnalysisViewModel {

    enum AnalysisState: Equatable {
        case idle
        case analyzing
        case completed
        case error(String)
    }

    private(set) var state: AnalysisState = .idle

    var currentStep: AIAnalysisService.AnalysisStep? {
        analysisService.currentStep
    }

    var progress: Double {
        analysisService.progress
    }

    private let analysisService = AIAnalysisService()

    var isAnalyzing: Bool {
        state == .analyzing
    }

    // MARK: - Analysis

    /// Starts the AI analysis pipeline on the given document.
    @MainActor
    func analyze(document: LegalDocument, context: ModelContext) async {
        guard state != .analyzing else { return }

        state = .analyzing
        analysisService.reset()

        do {
            try await analysisService.analyzeDocument(document, modelContext: context)
            state = .completed
        } catch {
            state = .error(error.localizedDescription)
        }
    }

    /// Retries analysis after a failure.
    @MainActor
    func retry(document: LegalDocument, context: ModelContext) async {
        state = .idle
        await analyze(document: document, context: context)
    }

    /// Resets the view model to idle state.
    func reset() {
        state = .idle
        analysisService.reset()
    }
}

import Foundation
import SwiftData

@Observable @MainActor
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
    private var analysisTask: Task<Void, Never>?

    var isAnalyzing: Bool {
        state == .analyzing
    }

    // MARK: - Analysis

    /// Starts the AI analysis pipeline on the given document.
    func analyze(document: LegalDocument, context: ModelContext) {
        guard state != .analyzing else { return }

        state = .analyzing
        analysisService.reset()

        analysisTask = Task {
            do {
                try await analysisService.analyzeDocument(document, modelContext: context)
                if state == .analyzing {
                    state = .completed
                }
            } catch is CancellationError {
                state = .idle
            } catch let error as AIAnalysisService.AnalysisError where error == .cancelled {
                state = .idle
            } catch {
                if state == .analyzing {
                    state = .error(error.localizedDescription)
                }
            }
        }
    }

    /// Waits for the current analysis to complete.
    func waitForAnalysis() async {
        await analysisTask?.value
    }

    /// Cancels the in-progress analysis.
    func cancelAnalysis() {
        analysisTask?.cancel()
        analysisService.cancel()
        analysisTask = nil
        state = .idle
    }

    /// Retries analysis after a failure.
    func retry(document: LegalDocument, context: ModelContext) {
        state = .idle
        analyze(document: document, context: context)
    }

    /// Resets the view model to idle state.
    func reset() {
        state = .idle
        analysisService.reset()
    }
}

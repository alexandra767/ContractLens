import Foundation
import SwiftUI

@Observable
final class UsageMeterService {

    private let userDefaults = UserDefaults.standard
    private let analysisCountKey = "contractlens_analysis_count"
    private let monthKey = "contractlens_analysis_month"

    var analysisCount: Int {
        let currentMonth = currentMonthString()
        if userDefaults.string(forKey: monthKey) != currentMonth {
            userDefaults.set(0, forKey: analysisCountKey)
            userDefaults.set(currentMonth, forKey: monthKey)
            return 0
        }
        return userDefaults.integer(forKey: analysisCountKey)
    }

    var remainingFreeAnalyses: Int {
        max(0, AppConstants.freeAnalysesPerMonth - analysisCount)
    }

    /// Returns true if the user can perform another analysis (free tier check).
    /// Pro subscribers always return true.
    func canAnalyze(isPro: Bool) -> Bool {
        if isPro { return true }
        return analysisCount < AppConstants.freeAnalysesPerMonth
    }

    /// Increments the analysis counter for the current month.
    func recordAnalysis() {
        let currentMonth = currentMonthString()
        if userDefaults.string(forKey: monthKey) != currentMonth {
            userDefaults.set(currentMonth, forKey: monthKey)
            userDefaults.set(1, forKey: analysisCountKey)
        } else {
            let current = userDefaults.integer(forKey: analysisCountKey)
            userDefaults.set(current + 1, forKey: analysisCountKey)
        }
    }

    /// Resets usage for testing.
    func resetUsage() {
        userDefaults.removeObject(forKey: analysisCountKey)
        userDefaults.removeObject(forKey: monthKey)
    }

    // MARK: - Private

    private func currentMonthString() -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM"
        return formatter.string(from: Date())
    }
}

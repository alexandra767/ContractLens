import Foundation
import FoundationModels

@Generable
struct RiskAssessmentOutput {
    @Guide(description: "Overall risk level: low, medium, or high")
    var overallRisk: String

    @Guide(description: "Risk score from 0 (no risk) to 100 (extreme risk)")
    var riskScore: Int

    @Guide(description: "Explanation of the overall risk assessment in 2-3 sentences")
    var explanation: String

    @Guide(description: "The top 3 concerns or red flags found in the contract")
    var topConcerns: [String]

    @Guide(description: "Up to 3 positive aspects or protections found in the contract")
    var positiveAspects: [String]
}

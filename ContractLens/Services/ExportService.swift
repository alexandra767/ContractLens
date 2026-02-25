import Foundation
import UIKit

struct ExportService {

    // MARK: - PDF Export

    /// Generates a PDF report for a document analysis.
    func generatePDFReport(for document: LegalDocument) -> Data {
        let pageRect = CGRect(x: 0, y: 0, width: 612, height: 792) // US Letter
        let margin: CGFloat = 50
        let contentWidth = pageRect.width - margin * 2

        let renderer = UIGraphicsPDFRenderer(bounds: pageRect)

        return renderer.pdfData { context in
            context.beginPage()
            var yPosition = margin

            // Title
            yPosition = drawText(
                document.title,
                in: context,
                at: CGPoint(x: margin, y: yPosition),
                width: contentWidth,
                font: .boldSystemFont(ofSize: 24)
            )
            yPosition += 8

            // Document type and date
            let subtitle = "\(document.documentType.rawValue.capitalized) | Analyzed \(formattedDate(document.dateModified))"
            yPosition = drawText(
                subtitle,
                in: context,
                at: CGPoint(x: margin, y: yPosition),
                width: contentWidth,
                font: .systemFont(ofSize: 12),
                color: .gray
            )
            yPosition += 20

            // Summary
            if let analysis = document.analysis {
                yPosition = drawSectionHeader("Summary", in: context, at: CGPoint(x: margin, y: yPosition), width: contentWidth)
                yPosition = drawText(
                    analysis.plainEnglishSummary,
                    in: context,
                    at: CGPoint(x: margin, y: yPosition),
                    width: contentWidth,
                    font: .systemFont(ofSize: 12)
                )
                yPosition += 16

                // Risk Assessment
                let riskText = "Overall Risk: \(analysis.overallRiskLevel.rawValue.capitalized) (\(analysis.riskScore)/100)"
                yPosition = drawText(
                    riskText,
                    in: context,
                    at: CGPoint(x: margin, y: yPosition),
                    width: contentWidth,
                    font: .boldSystemFont(ofSize: 14)
                )
                yPosition += 20

                // Parties
                let parties = analysis.parties
                if !parties.isEmpty {
                    yPosition = drawSectionHeader("Parties", in: context, at: CGPoint(x: margin, y: yPosition), width: contentWidth)
                    for party in parties {
                        let partyText = "\(party.name) — \(party.role)"
                        yPosition = drawText(
                            partyText,
                            in: context,
                            at: CGPoint(x: margin + 10, y: yPosition),
                            width: contentWidth - 10,
                            font: .systemFont(ofSize: 11)
                        )
                    }
                    yPosition += 12
                }

                // Key Dates
                let dates = analysis.keyDates
                if !dates.isEmpty {
                    yPosition = drawSectionHeader("Key Dates", in: context, at: CGPoint(x: margin, y: yPosition), width: contentWidth)
                    for date in dates {
                        let prefix = date.isDeadline ? "[DEADLINE] " : ""
                        let dateText = "\(prefix)\(date.label): \(date.dateString)"
                        yPosition = drawText(
                            dateText,
                            in: context,
                            at: CGPoint(x: margin + 10, y: yPosition),
                            width: contentWidth - 10,
                            font: .systemFont(ofSize: 11)
                        )
                    }
                    yPosition += 12
                }
            }

            // Clauses
            let sortedClauses = document.clauses.sorted { $0.sortOrder < $1.sortOrder }
            if !sortedClauses.isEmpty {
                // Start clauses on new page if near bottom
                if yPosition > pageRect.height - 200 {
                    context.beginPage()
                    yPosition = margin
                }

                yPosition = drawSectionHeader("Clauses", in: context, at: CGPoint(x: margin, y: yPosition), width: contentWidth)

                for clause in sortedClauses {
                    // New page if needed
                    if yPosition > pageRect.height - 120 {
                        context.beginPage()
                        yPosition = margin
                    }

                    let riskIndicator = "[\(clause.riskLevel.rawValue.uppercased())]"
                    yPosition = drawText(
                        "\(riskIndicator) \(clause.title)",
                        in: context,
                        at: CGPoint(x: margin, y: yPosition),
                        width: contentWidth,
                        font: .boldSystemFont(ofSize: 12)
                    )
                    yPosition = drawText(
                        clause.plainEnglishExplanation,
                        in: context,
                        at: CGPoint(x: margin + 10, y: yPosition),
                        width: contentWidth - 10,
                        font: .systemFont(ofSize: 11)
                    )

                    if !clause.riskReason.isEmpty {
                        yPosition = drawText(
                            "Risk: \(clause.riskReason)",
                            in: context,
                            at: CGPoint(x: margin + 10, y: yPosition),
                            width: contentWidth - 10,
                            font: .italicSystemFont(ofSize: 10),
                            color: .darkGray
                        )
                    }
                    yPosition += 12
                }
            }

            // Disclaimer
            if yPosition > pageRect.height - 100 {
                context.beginPage()
                yPosition = margin
            }
            yPosition = pageRect.height - margin - 40
            _ = drawText(
                AppConstants.legalDisclaimer,
                in: context,
                at: CGPoint(x: margin, y: yPosition),
                width: contentWidth,
                font: .italicSystemFont(ofSize: 8),
                color: .gray
            )
        }
    }

    // MARK: - Text Export

    /// Generates a plain text report for a document analysis.
    func generateTextReport(for document: LegalDocument) -> String {
        var report = """
        \(document.title)
        \(String(repeating: "=", count: document.title.count))
        Type: \(document.documentType.rawValue.capitalized)
        Date: \(formattedDate(document.dateModified))

        """

        if let analysis = document.analysis {
            report += """
            SUMMARY
            -------
            \(analysis.plainEnglishSummary)

            RISK ASSESSMENT
            ---------------
            Overall Risk: \(analysis.overallRiskLevel.rawValue.capitalized) (\(analysis.riskScore)/100)

            """

            let parties = analysis.parties
            if !parties.isEmpty {
                report += "PARTIES\n-------\n"
                for party in parties {
                    report += "- \(party.name) (\(party.role))\n"
                }
                report += "\n"
            }

            let dates = analysis.keyDates
            if !dates.isEmpty {
                report += "KEY DATES\n---------\n"
                for date in dates {
                    let prefix = date.isDeadline ? "[DEADLINE] " : ""
                    report += "- \(prefix)\(date.label): \(date.dateString)\n"
                }
                report += "\n"
            }
        }

        let sortedClauses = document.clauses.sorted { $0.sortOrder < $1.sortOrder }
        if !sortedClauses.isEmpty {
            report += "CLAUSES\n-------\n"
            for clause in sortedClauses {
                report += """
                [\(clause.riskLevel.rawValue.uppercased())] \(clause.title)
                  \(clause.plainEnglishExplanation)
                  Category: \(clause.category.displayName)

                """
            }
        }

        report += "\n---\n\(AppConstants.legalDisclaimer)\n"

        return report
    }

    // MARK: - Private Drawing Helpers

    @discardableResult
    private func drawText(
        _ text: String,
        in context: UIGraphicsPDFRendererContext,
        at point: CGPoint,
        width: CGFloat,
        font: UIFont,
        color: UIColor = .black
    ) -> CGFloat {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineBreakMode = .byWordWrapping

        let attributes: [NSAttributedString.Key: Any] = [
            .font: font,
            .foregroundColor: color,
            .paragraphStyle: paragraphStyle
        ]

        let attributedString = NSAttributedString(string: text, attributes: attributes)
        let boundingRect = attributedString.boundingRect(
            with: CGSize(width: width, height: .greatestFiniteMagnitude),
            options: [.usesLineFragmentOrigin, .usesFontLeading],
            context: nil
        )

        attributedString.draw(in: CGRect(x: point.x, y: point.y, width: width, height: boundingRect.height))

        return point.y + boundingRect.height + 4
    }

    @discardableResult
    private func drawSectionHeader(
        _ title: String,
        in context: UIGraphicsPDFRendererContext,
        at point: CGPoint,
        width: CGFloat
    ) -> CGFloat {
        let yAfterTitle = drawText(
            title,
            in: context,
            at: point,
            width: width,
            font: .boldSystemFont(ofSize: 16)
        )

        // Draw underline
        let lineY = yAfterTitle - 2
        context.cgContext.setStrokeColor(UIColor.darkGray.cgColor)
        context.cgContext.setLineWidth(0.5)
        context.cgContext.move(to: CGPoint(x: point.x, y: lineY))
        context.cgContext.addLine(to: CGPoint(x: point.x + width, y: lineY))
        context.cgContext.strokePath()

        return yAfterTitle + 4
    }

    private func formattedDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
}

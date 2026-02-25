import Foundation
import PDFKit
import UIKit

@Observable @MainActor
final class PDFService {

    enum PDFError: LocalizedError {
        case failedToLoadDocument
        case noTextExtracted
        case noPages

        var errorDescription: String? {
            switch self {
            case .failedToLoadDocument:
                return "Failed to load the PDF document."
            case .noTextExtracted:
                return "No text could be extracted from the PDF."
            case .noPages:
                return "The PDF contains no pages."
            }
        }
    }

    private let ocrService = OCRService()

    /// Extracts text from a PDF at the given URL.
    /// Tries direct text extraction first; falls back to OCR for scanned pages.
    func extractText(from url: URL) async throws -> (text: String, pageCount: Int) {
        guard let document = PDFDocument(url: url) else {
            throw PDFError.failedToLoadDocument
        }

        let pageCount = document.pageCount
        guard pageCount > 0 else {
            throw PDFError.noPages
        }

        // Try direct text extraction
        var directText = ""
        for i in 0..<pageCount {
            if let page = document.page(at: i), let pageText = page.string {
                directText += pageText + "\n\n"
            }
        }

        let trimmedDirect = directText.trimmingCharacters(in: .whitespacesAndNewlines)
        if !trimmedDirect.isEmpty && trimmedDirect.count > 50 {
            return (trimmedDirect, pageCount)
        }

        // Fallback: OCR each page as an image
        let ocrText = try await ocrPages(document: document, pageCount: pageCount)
        let trimmedOCR = ocrText.trimmingCharacters(in: .whitespacesAndNewlines)

        guard !trimmedOCR.isEmpty else {
            throw PDFError.noTextExtracted
        }

        return (trimmedOCR, pageCount)
    }

    /// Generates a thumbnail image for the first page of a PDF.
    func generateThumbnail(from url: URL, size: CGSize = CGSize(width: 200, height: 260)) -> UIImage? {
        guard let document = PDFDocument(url: url),
              let page = document.page(at: 0) else { return nil }
        return page.thumbnail(of: size, for: .mediaBox)
    }

    // MARK: - Private

    private func ocrPages(document: PDFDocument, pageCount: Int) async throws -> String {
        var pages: [String] = []
        for i in 0..<pageCount {
            guard let page = document.page(at: i) else { continue }
            let bounds = page.bounds(for: .mediaBox)
            let renderer = UIGraphicsImageRenderer(size: bounds.size)
            let image = renderer.image { context in
                UIColor.white.setFill()
                context.fill(bounds)
                context.cgContext.translateBy(x: 0, y: bounds.height)
                context.cgContext.scaleBy(x: 1, y: -1)
                page.draw(with: .mediaBox, to: context.cgContext)
            }
            if let pageText = try? await ocrService.recognizeText(in: image) {
                pages.append(pageText)
            }
        }
        return pages.joined(separator: "\n\n")
    }
}

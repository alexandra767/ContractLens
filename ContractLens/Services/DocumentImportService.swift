import Foundation
import SwiftData
import UIKit
import PhotosUI

@Observable @MainActor
final class DocumentImportService {

    enum ImportError: LocalizedError {
        case noTextExtracted
        case unsupportedFileType
        case photoConversionFailed

        var errorDescription: String? {
            switch self {
            case .noTextExtracted:
                return "No text could be extracted from the document."
            case .unsupportedFileType:
                return "This file type is not supported."
            case .photoConversionFailed:
                return "Failed to load the selected photo."
            }
        }
    }

    private let pdfService = PDFService()
    private let ocrService = OCRService()

    // MARK: - Import from PDF

    /// Imports a PDF from a URL, extracts text, and saves a LegalDocument to SwiftData.
    func importPDF(from url: URL, title: String, context: ModelContext) async throws -> LegalDocument {
        let result = try await pdfService.extractText(from: url)
        let thumbnail = pdfService.generateThumbnail(from: url)

        let document = LegalDocument(
            title: title,
            documentType: .other,
            rawText: result.text,
            sourceType: .pdf,
            pageCount: result.pageCount,
            thumbnailData: thumbnail?.jpegData(compressionQuality: 0.7)
        )

        context.insert(document)
        try context.save()

        return document
    }

    // MARK: - Import from Camera

    /// Imports a document from a camera-captured image, performs OCR, and saves to SwiftData.
    func importFromCamera(image: UIImage, title: String, context: ModelContext) async throws -> LegalDocument {
        let text = try await ocrService.recognizeText(in: image)

        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ImportError.noTextExtracted
        }

        let document = LegalDocument(
            title: title,
            documentType: .other,
            rawText: text,
            sourceType: .camera,
            pageCount: 1,
            thumbnailData: image.jpegData(compressionQuality: 0.7)
        )

        context.insert(document)
        try context.save()

        return document
    }

    // MARK: - Import from Photo Library

    /// Imports a document from a photo library selection, performs OCR, and saves to SwiftData.
    func importFromPhoto(image: UIImage, title: String, context: ModelContext) async throws -> LegalDocument {
        let text = try await ocrService.recognizeText(in: image)

        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ImportError.noTextExtracted
        }

        let document = LegalDocument(
            title: title,
            documentType: .other,
            rawText: text,
            sourceType: .photo,
            pageCount: 1,
            thumbnailData: image.jpegData(compressionQuality: 0.7)
        )

        context.insert(document)
        try context.save()

        return document
    }

    // MARK: - Import from Multiple Camera Images

    /// Imports a multi-page document from multiple camera images.
    func importFromCamera(images: [UIImage], title: String, context: ModelContext) async throws -> LegalDocument {
        let text = try await ocrService.recognizeText(in: images)

        guard !text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ImportError.noTextExtracted
        }

        let document = LegalDocument(
            title: title,
            documentType: .other,
            rawText: text,
            sourceType: .camera,
            pageCount: images.count,
            thumbnailData: images.first?.jpegData(compressionQuality: 0.7)
        )

        context.insert(document)
        try context.save()

        return document
    }
}

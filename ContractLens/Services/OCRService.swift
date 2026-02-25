import Foundation
import Vision
import UIKit

@Observable @MainActor
final class OCRService {

    enum OCRError: LocalizedError {
        case imageConversionFailed
        case recognitionFailed(Error)
        case noTextFound

        var errorDescription: String? {
            switch self {
            case .imageConversionFailed:
                return "Failed to prepare image for text recognition."
            case .recognitionFailed(let error):
                return "Text recognition failed: \(error.localizedDescription)"
            case .noTextFound:
                return "No text was found in the image."
            }
        }
    }

    /// Performs OCR on a UIImage using Vision framework with accurate recognition.
    func recognizeText(in image: UIImage) async throws -> String {
        guard let cgImage = image.cgImage else {
            throw OCRError.imageConversionFailed
        }

        return try await withCheckedThrowingContinuation { continuation in
            let request = VNRecognizeTextRequest { request, error in
                if let error {
                    continuation.resume(throwing: OCRError.recognitionFailed(error))
                    return
                }

                guard let observations = request.results as? [VNRecognizedTextObservation],
                      !observations.isEmpty else {
                    continuation.resume(throwing: OCRError.noTextFound)
                    return
                }

                let text = observations
                    .compactMap { $0.topCandidates(1).first?.string }
                    .joined(separator: "\n")

                if text.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    continuation.resume(throwing: OCRError.noTextFound)
                } else {
                    continuation.resume(returning: text)
                }
            }

            request.recognitionLevel = .accurate
            request.usesLanguageCorrection = true

            let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
            do {
                try handler.perform([request])
            } catch {
                continuation.resume(throwing: OCRError.recognitionFailed(error))
            }
        }
    }

    /// Performs OCR on multiple images and concatenates results.
    func recognizeText(in images: [UIImage]) async throws -> String {
        var allText: [String] = []
        for image in images {
            let text = try await recognizeText(in: image)
            allText.append(text)
        }
        return allText.joined(separator: "\n\n")
    }
}

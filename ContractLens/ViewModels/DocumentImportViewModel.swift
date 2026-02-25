import Foundation
import SwiftData
import SwiftUI
import UIKit

@Observable
final class DocumentImportViewModel {

    enum ImportState: Equatable {
        case idle
        case selectingSource
        case processing
        case success(documentTitle: String)
        case error(String)
    }

    var importState: ImportState = .idle
    var documentTitle = ""
    var showingCamera = false
    var showingPhotoPicker = false
    var showingFileImporter = false

    private let importService = DocumentImportService()

    var isProcessing: Bool {
        importState == .processing
    }

    // MARK: - Source Selection

    func showSourcePicker() {
        importState = .selectingSource
    }

    func selectCamera() {
        importState = .idle
        showingCamera = true
    }

    func selectPhotoPicker() {
        importState = .idle
        showingPhotoPicker = true
    }

    func selectFileImporter() {
        importState = .idle
        showingFileImporter = true
    }

    // MARK: - Import from Camera

    func importCameraImage(_ image: UIImage, context: ModelContext) async {
        let title = documentTitle.isEmpty ? "Scanned Document" : documentTitle
        importState = .processing

        do {
            let document = try await importService.importFromCamera(image: image, title: title, context: context)
            importState = .success(documentTitle: document.title)
            resetForm()
        } catch {
            importState = .error(error.localizedDescription)
        }
    }

    /// Import multiple camera images as a single document.
    func importCameraImages(_ images: [UIImage], context: ModelContext) async {
        let title = documentTitle.isEmpty ? "Scanned Document" : documentTitle
        importState = .processing

        do {
            let document = try await importService.importFromCamera(images: images, title: title, context: context)
            importState = .success(documentTitle: document.title)
            resetForm()
        } catch {
            importState = .error(error.localizedDescription)
        }
    }

    // MARK: - Import from Photo

    func importPhoto(_ image: UIImage, context: ModelContext) async {
        let title = documentTitle.isEmpty ? "Photo Document" : documentTitle
        importState = .processing

        do {
            let document = try await importService.importFromPhoto(image: image, title: title, context: context)
            importState = .success(documentTitle: document.title)
            resetForm()
        } catch {
            importState = .error(error.localizedDescription)
        }
    }

    // MARK: - Import from PDF

    func importPDF(from url: URL, context: ModelContext) async {
        let title = documentTitle.isEmpty ? url.deletingPathExtension().lastPathComponent : documentTitle
        importState = .processing

        guard url.startAccessingSecurityScopedResource() else {
            importState = .error("Unable to access the selected file.")
            return
        }
        defer { url.stopAccessingSecurityScopedResource() }

        do {
            let document = try await importService.importPDF(from: url, title: title, context: context)
            importState = .success(documentTitle: document.title)
            resetForm()
        } catch {
            importState = .error(error.localizedDescription)
        }
    }

    // MARK: - Reset

    func dismiss() {
        importState = .idle
    }

    private func resetForm() {
        documentTitle = ""
    }
}

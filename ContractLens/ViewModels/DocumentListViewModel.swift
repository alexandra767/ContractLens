import Foundation
import SwiftData
import SwiftUI

@Observable
final class DocumentListViewModel {

    var searchText = ""
    var selectedDocumentType: DocumentType?
    var sortOrder: SortOrder = .dateDescending
    var showingDeleteConfirmation = false
    var documentToDelete: LegalDocument?
    var errorMessage: String?

    enum SortOrder: String, CaseIterable {
        case dateDescending = "Newest First"
        case dateAscending = "Oldest First"
        case titleAscending = "Title A-Z"
        case titleDescending = "Title Z-A"
    }

    /// Filters and sorts documents based on current search/filter state.
    func filteredDocuments(_ documents: [LegalDocument], isPro: Bool = true) -> [LegalDocument] {
        var result = documents

        // Enforce 30-day history limit for free users
        if !isPro {
            let cutoffDate = Calendar.current.date(byAdding: .day, value: -AppConstants.freeHistoryDays, to: Date()) ?? Date()
            result = result.filter { $0.dateCreated >= cutoffDate }
        }

        // Filter by search text
        if !searchText.isEmpty {
            let query = searchText.lowercased()
            result = result.filter { document in
                document.title.lowercased().contains(query) ||
                document.rawText.lowercased().contains(query) ||
                document.documentType.rawValue.lowercased().contains(query)
            }
        }

        // Filter by document type
        if let selectedType = selectedDocumentType {
            result = result.filter { $0.documentType == selectedType }
        }

        // Sort
        switch sortOrder {
        case .dateDescending:
            result.sort { $0.dateModified > $1.dateModified }
        case .dateAscending:
            result.sort { $0.dateModified < $1.dateModified }
        case .titleAscending:
            result.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedAscending }
        case .titleDescending:
            result.sort { $0.title.localizedCaseInsensitiveCompare($1.title) == .orderedDescending }
        }

        return result
    }

    /// Toggles the favorite status of a document.
    func toggleFavorite(_ document: LegalDocument, context: ModelContext) {
        document.isFavorite.toggle()
        document.dateModified = Date()
        try? context.save()
    }

    /// Prepares to delete a document (shows confirmation).
    func confirmDelete(_ document: LegalDocument) {
        documentToDelete = document
        showingDeleteConfirmation = true
    }

    /// Deletes the document after confirmation.
    func deleteDocument(context: ModelContext) {
        guard let document = documentToDelete else { return }
        context.delete(document)
        try? context.save()
        documentToDelete = nil
    }

    /// Renames a document.
    func renameDocument(_ document: LegalDocument, to newTitle: String, context: ModelContext) {
        let trimmed = newTitle.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { return }
        document.title = trimmed
        document.dateModified = Date()
        try? context.save()
    }
}

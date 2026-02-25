import Foundation
import SwiftData

// MARK: - Enums

enum DocumentType: String, Codable, CaseIterable, Identifiable {
    case lease
    case employment
    case nda
    case freelance
    case service
    case other

    var id: String { rawValue }
}

enum SourceType: String, Codable, CaseIterable, Identifiable {
    case camera
    case pdf
    case photo

    var id: String { rawValue }
}

// MARK: - LegalDocument Model

@Model
final class LegalDocument {
    var id: UUID = UUID()
    var title: String = ""
    var documentType: DocumentType = DocumentType.other
    var rawText: String = ""
    var sourceType: SourceType = SourceType.camera
    var pageCount: Int = 1
    var thumbnailData: Data?
    var dateCreated: Date = Date()
    var dateModified: Date = Date()
    var isFavorite: Bool = false

    @Relationship(deleteRule: .cascade, inverse: \DocumentAnalysis.document)
    var analysis: DocumentAnalysis?

    @Relationship(deleteRule: .cascade, inverse: \ContractClause.document)
    var clauses: [ContractClause]?

    init(
        id: UUID = UUID(),
        title: String,
        documentType: DocumentType,
        rawText: String = "",
        sourceType: SourceType,
        pageCount: Int = 1,
        thumbnailData: Data? = nil,
        dateCreated: Date = Date(),
        dateModified: Date = Date(),
        isFavorite: Bool = false,
        analysis: DocumentAnalysis? = nil,
        clauses: [ContractClause] = []
    ) {
        self.id = id
        self.title = title
        self.documentType = documentType
        self.rawText = rawText
        self.sourceType = sourceType
        self.pageCount = pageCount
        self.thumbnailData = thumbnailData
        self.dateCreated = dateCreated
        self.dateModified = dateModified
        self.isFavorite = isFavorite
        self.analysis = analysis
        self.clauses = clauses
    }
}

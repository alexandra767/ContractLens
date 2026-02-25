import SwiftUI
import SwiftData

struct DocumentListView: View {
    let documents: [LegalDocument]
    @Binding var selectedDocument: LegalDocument?
    @Binding var showingImportSheet: Bool
    @Binding var showingSettings: Bool

    @Environment(SubscriptionService.self) private var subscriptionService
    @Environment(UsageMeterService.self) private var usageMeterService
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = DocumentListViewModel()

    private let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]

    var body: some View {
        Group {
            if documents.isEmpty {
                emptyState
            } else {
                documentGrid
            }
        }
        .navigationTitle("ContractLens")
        .searchable(text: $viewModel.searchText, prompt: "Search contracts...")
        .toolbar {
            ToolbarItem(placement: .primaryAction) {
                Button {
                    showingImportSheet = true
                } label: {
                    Image(systemName: "plus")
                }
            }
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    showingSettings = true
                } label: {
                    Image(systemName: "gearshape")
                }
            }
            ToolbarItem(placement: .topBarTrailing) {
                Menu {
                    Picker("Sort", selection: $viewModel.sortOrder) {
                        ForEach(DocumentListViewModel.SortOrder.allCases, id: \.self) { order in
                            Text(order.rawValue).tag(order)
                        }
                    }

                    Divider()

                    Menu("Filter by Type") {
                        Button("All Types") { viewModel.selectedDocumentType = nil }
                        ForEach(DocumentType.allCases) { type in
                            Button(type.rawValue.capitalized) {
                                viewModel.selectedDocumentType = type
                            }
                        }
                    }
                } label: {
                    Image(systemName: "line.3.horizontal.decrease.circle")
                }
            }
        }
        .safeAreaInset(edge: .bottom) {
            if !subscriptionService.isProSubscriber {
                usageBanner
            }
        }
        .alert("Delete Document?", isPresented: $viewModel.showingDeleteConfirmation) {
            Button("Delete", role: .destructive) {
                viewModel.deleteDocument(context: modelContext)
            }
            Button("Cancel", role: .cancel) {}
        } message: {
            Text("This will permanently delete the document and its analysis.")
        }
    }

    private var emptyState: some View {
        ContentUnavailableView {
            Label("No Documents", systemImage: "doc.text.magnifyingglass")
        } description: {
            Text("Import a contract, lease, or NDA to get started with AI analysis.")
        } actions: {
            Button {
                showingImportSheet = true
            } label: {
                Text("Import Document")
                    .font(.headline)
            }
            .buttonStyle(.borderedProminent)
        }
    }

    private var documentGrid: some View {
        ScrollView {
            LazyVGrid(columns: columns, spacing: 16) {
                ForEach(viewModel.filteredDocuments(documents)) { document in
                    DocumentCardView(document: document)
                        .onTapGesture {
                            selectedDocument = document
                        }
                        .contextMenu {
                            Button {
                                viewModel.toggleFavorite(document, context: modelContext)
                            } label: {
                                Label(
                                    document.isFavorite ? "Unfavorite" : "Favorite",
                                    systemImage: document.isFavorite ? "star.slash" : "star"
                                )
                            }

                            Divider()

                            Button(role: .destructive) {
                                viewModel.confirmDelete(document)
                            } label: {
                                Label("Delete", systemImage: "trash")
                            }
                        }
                }
            }
            .padding()
        }
    }

    private var usageBanner: some View {
        HStack {
            Image(systemName: "chart.bar.fill")
                .foregroundStyle(.clSky)
            Text("\(usageMeterService.remainingFreeAnalyses) of \(AppConstants.freeAnalysesPerMonth) free analyses remaining")
                .font(.subheadline)
            Spacer()
        }
        .padding()
        .background(.ultraThinMaterial)
    }
}

struct DocumentCardView: View {
    let document: LegalDocument

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                DocumentTypeIcon(type: document.documentType)
                Spacer()
                if document.isFavorite {
                    Image(systemName: "star.fill")
                        .foregroundStyle(.yellow)
                        .font(.caption)
                }
                if let analysis = document.analysis {
                    RiskBadge(level: analysis.overallRiskLevel)
                }
            }

            Text(document.title)
                .font(.headline)
                .lineLimit(2)

            Text(document.documentType.rawValue.capitalized)
                .font(.caption)
                .foregroundStyle(.secondary)

            Spacer(minLength: 0)

            Text(document.dateModified.formatted(date: .abbreviated, time: .omitted))
                .font(.caption2)
                .foregroundStyle(.tertiary)
        }
        .padding()
        .frame(minHeight: 140)
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

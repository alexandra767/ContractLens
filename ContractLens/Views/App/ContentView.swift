import SwiftUI
import SwiftData
import PhotosUI

struct ContentView: View {
    @Environment(SubscriptionService.self) private var subscriptionService
    @Environment(UsageMeterService.self) private var usageMeterService
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \LegalDocument.dateModified, order: .reverse) private var documents: [LegalDocument]

    @State private var showingImportSheet = false
    @State private var showingSettings = false

    var body: some View {
        NavigationStack {
            DocumentListView(
                documents: documents,
                showingImportSheet: $showingImportSheet,
                showingSettings: $showingSettings
            )
        }
        .sheet(isPresented: $showingImportSheet) {
            DocumentImportSheet()
        }
        .sheet(isPresented: $showingSettings) {
            NavigationStack {
                SettingsView()
            }
        }
    }
}

struct DocumentImportSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var viewModel = DocumentImportViewModel()
    @State private var selectedPhotoItem: PhotosPickerItem?

    var body: some View {
        NavigationStack {
            VStack(spacing: 24) {
                Text("Import Document")
                    .font(.title2.bold())
                    .padding(.top)

                VStack(spacing: 16) {
                    ImportOptionButton(
                        title: "Scan Document",
                        subtitle: "Use your camera to scan pages",
                        icon: "camera.fill",
                        color: .clSky
                    ) {
                        viewModel.selectCamera()
                    }

                    ImportOptionButton(
                        title: "Import PDF",
                        subtitle: "Choose a PDF from your files",
                        icon: "doc.fill",
                        color: .clNavy
                    ) {
                        viewModel.selectFileImporter()
                    }

                    PhotosPicker(
                        selection: $selectedPhotoItem,
                        matching: .images
                    ) {
                        HStack(spacing: 16) {
                            Image(systemName: "photo.fill")
                                .font(.title2)
                                .foregroundStyle(.white)
                                .frame(width: 48, height: 48)
                                .background(.green, in: RoundedRectangle(cornerRadius: 12))

                            VStack(alignment: .leading, spacing: 2) {
                                Text("Import from Photos")
                                    .font(.headline)
                                    .foregroundStyle(.primary)
                                Text("Select a photo of a document")
                                    .font(.subheadline)
                                    .foregroundStyle(.secondary)
                            }

                            Spacer()

                            Image(systemName: "chevron.right")
                                .foregroundStyle(.tertiary)
                        }
                        .padding()
                        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal)

                if viewModel.isProcessing {
                    ProgressView("Processing document...")
                        .padding()
                }

                Spacer()
            }
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                }
            }
            .fullScreenCover(isPresented: $viewModel.showingCamera) {
                CameraScannerView { images in
                    Task {
                        await viewModel.importCameraImages(images, context: modelContext)
                        if case .success = viewModel.importState { dismiss() }
                    }
                }
            }
            .fileImporter(
                isPresented: $viewModel.showingFileImporter,
                allowedContentTypes: [.pdf],
                allowsMultipleSelection: false
            ) { result in
                switch result {
                case .success(let urls):
                    if let url = urls.first {
                        Task {
                            await viewModel.importPDF(from: url, context: modelContext)
                            if case .success = viewModel.importState { dismiss() }
                        }
                    }
                case .failure(let error):
                    viewModel.importState = .error(error.localizedDescription)
                }
            }
            .onChange(of: selectedPhotoItem) {
                guard let item = selectedPhotoItem else { return }
                selectedPhotoItem = nil
                Task {
                    if let data = try? await item.loadTransferable(type: Data.self),
                       let image = UIImage(data: data) {
                        await viewModel.importPhoto(image, context: modelContext)
                        if case .success = viewModel.importState { dismiss() }
                    } else {
                        viewModel.importState = .error("Failed to load the selected photo.")
                    }
                }
            }
            .alert("Import Error", isPresented: .init(
                get: { if case .error = viewModel.importState { return true } else { return false } },
                set: { if !$0 { viewModel.dismiss() } }
            )) {
                Button("OK") { viewModel.dismiss() }
            } message: {
                if case .error(let msg) = viewModel.importState {
                    Text(msg)
                }
            }
        }
    }
}

struct ImportOptionButton: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: 16) {
                Image(systemName: icon)
                    .font(.title2)
                    .foregroundStyle(.white)
                    .frame(width: 48, height: 48)
                    .background(color, in: RoundedRectangle(cornerRadius: 12))

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.primary)
                    Text(subtitle)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                Image(systemName: "chevron.right")
                    .foregroundStyle(.tertiary)
            }
            .padding()
            .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
        }
        .buttonStyle(.plain)
    }
}

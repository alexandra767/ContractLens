import SwiftUI
import SwiftData

struct AnalysisView: View {
    let document: LegalDocument

    @Environment(SubscriptionService.self) private var subscriptionService
    @Environment(UsageMeterService.self) private var usageMeterService
    @Environment(\.modelContext) private var modelContext

    @State private var viewModel = AnalysisViewModel()
    @State private var selectedTab = 0
    @State private var showingPaywall = false
    @State private var showingExportSheet = false

    var body: some View {
        Group {
            if let analysis = document.analysis {
                analysisContent(analysis)
            } else if viewModel.isAnalyzing {
                AnalysisProgressView(viewModel: viewModel)
            } else {
                noAnalysisView
            }
        }
        .navigationTitle(document.title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            if document.analysis != nil {
                ToolbarItem(placement: .primaryAction) {
                    Menu {
                        if subscriptionService.isProSubscriber {
                            Button {
                                showingExportSheet = true
                            } label: {
                                Label("Export as PDF", systemImage: "square.and.arrow.up")
                            }

                            Button {
                                Task {
                                    await viewModel.retry(document: document, context: modelContext)
                                }
                            } label: {
                                Label("Re-Analyze", systemImage: "arrow.clockwise")
                            }
                        } else {
                            Button {
                                showingPaywall = true
                            } label: {
                                Label("Export (Pro)", systemImage: "lock.fill")
                            }
                        }
                    } label: {
                        Image(systemName: "ellipsis.circle")
                    }
                }
            }
        }
        .sheet(isPresented: $showingPaywall) {
            PaywallView()
        }
        .sheet(isPresented: $showingExportSheet) {
            if let analysis = document.analysis {
                let exportService = ExportService()
                let pdfData = exportService.generatePDFReport(for: document)
                let tempURL = FileManager.default.temporaryDirectory.appendingPathComponent("\(document.title).pdf")
                let _ = try? pdfData.write(to: tempURL)
                ShareLink(item: tempURL)
            }
        }
    }

    // MARK: - No Analysis View

    private var noAnalysisView: some View {
        VStack(spacing: 24) {
            Spacer()

            Image(systemName: "wand.and.stars")
                .font(.system(size: 60))
                .foregroundStyle(.clSky)

            Text("Ready to Analyze")
                .font(.title2.bold())

            Text("AI will identify key clauses, assess risk levels, and explain everything in plain English.")
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Button {
                if usageMeterService.canAnalyze(isPro: subscriptionService.isProSubscriber) {
                    Task {
                        usageMeterService.recordAnalysis()
                        await viewModel.analyze(document: document, context: modelContext)
                    }
                } else {
                    showingPaywall = true
                }
            } label: {
                Label("Analyze Document", systemImage: "sparkles")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(.clSky, in: RoundedRectangle(cornerRadius: 16))
            }
            .padding(.horizontal, 40)

            LegalDisclaimerBanner()
                .padding(.horizontal)

            Spacer()
        }
    }

    // MARK: - Analysis Content

    private func analysisContent(_ analysis: DocumentAnalysis) -> some View {
        VStack(spacing: 0) {
            Picker("Section", selection: $selectedTab) {
                Text("Summary").tag(0)
                Text("Clauses").tag(1)
                Text("Parties").tag(2)
                Text("Dates").tag(3)
                Text("Full Text").tag(4)
            }
            .pickerStyle(.segmented)
            .padding()

            TabView(selection: $selectedTab) {
                SummaryTabView(analysis: analysis)
                    .tag(0)

                ClauseListView(
                    clauses: document.clauses.sorted { $0.sortOrder < $1.sortOrder },
                    isPro: subscriptionService.isProSubscriber,
                    showingPaywall: $showingPaywall
                )
                .tag(1)

                PartiesView(parties: analysis.parties)
                    .tag(2)

                KeyDatesView(dates: analysis.keyDates)
                    .tag(3)

                FullTextView(text: document.rawText)
                    .tag(4)
            }
            .tabViewStyle(.page(indexDisplayMode: .never))
        }
    }
}

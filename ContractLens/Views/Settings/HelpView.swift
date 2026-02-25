import SwiftUI

struct HelpView: View {
    @State private var expandedSection: String? = "getting-started"

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {

                // MARK: - Header
                VStack(spacing: 12) {
                    Image(systemName: "questionmark.circle.fill")
                        .font(.system(size: 48))
                        .foregroundStyle(.white)
                        .frame(width: 90, height: 90)
                        .background(
                            LinearGradient(
                                colors: [.clNavy, .clSky],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .clipShape(RoundedRectangle(cornerRadius: 20))
                        .shadow(color: .clSky.opacity(0.3), radius: 10, y: 4)

                    Text("Help & Support")
                        .font(.title.bold())
                        .foregroundStyle(.clNavy)

                    Text("Everything you need to get the most from ContractLens.")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 32)
                }
                .padding(.top, 8)

                // MARK: - Sections
                VStack(spacing: 12) {
                    helpSection(
                        id: "getting-started",
                        icon: "arrow.right.circle.fill",
                        color: .clSky,
                        title: "Getting Started",
                        items: gettingStartedItems
                    )

                    helpSection(
                        id: "analysis",
                        icon: "sparkles",
                        color: Color(red: 0.6, green: 0.3, blue: 0.9),
                        title: "Running an Analysis",
                        items: analysisItems
                    )

                    helpSection(
                        id: "results",
                        icon: "chart.bar.doc.horizontal.fill",
                        color: .clNavy,
                        title: "Understanding Your Results",
                        items: resultsItems
                    )

                    helpSection(
                        id: "managing",
                        icon: "folder.fill",
                        color: Color(red: 0.9, green: 0.55, blue: 0.1),
                        title: "Managing Documents",
                        items: managingItems
                    )

                    helpSection(
                        id: "pro",
                        icon: "crown.fill",
                        color: Color(red: 0.85, green: 0.65, blue: 0.1),
                        title: "ContractLens Pro",
                        items: proItems
                    )

                    helpSection(
                        id: "privacy",
                        icon: "lock.shield.fill",
                        color: .clRiskLow,
                        title: "Privacy & Security",
                        items: privacyItems
                    )
                }
                .padding(.horizontal, 16)

                // MARK: - Contact Support
                contactCard
                    .padding(.horizontal, 16)

                Spacer(minLength: 32)
            }
        }
        .background(Color.clBackground)
        .navigationTitle("Help & Support")
        .navigationBarTitleDisplayMode(.inline)
    }

    // MARK: - Section Builder

    private func helpSection(
        id: String,
        icon: String,
        color: Color,
        title: String,
        items: [HelpItem]
    ) -> some View {
        VStack(spacing: 0) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                    expandedSection = expandedSection == id ? nil : id
                }
            } label: {
                HStack(spacing: 14) {
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundStyle(.white)
                        .frame(width: 36, height: 36)
                        .background(color, in: RoundedRectangle(cornerRadius: 10))

                    Text(title)
                        .font(.headline)
                        .foregroundStyle(.clNavy)

                    Spacer()

                    Image(systemName: "chevron.down")
                        .font(.caption.bold())
                        .foregroundStyle(.clSlate)
                        .rotationEffect(.degrees(expandedSection == id ? 180 : 0))
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: expandedSection)
                }
                .padding(16)
            }
            .buttonStyle(.plain)

            if expandedSection == id {
                Divider()
                    .padding(.horizontal, 16)

                VStack(spacing: 0) {
                    ForEach(Array(items.enumerated()), id: \.offset) { index, item in
                        HelpItemRow(item: item)
                        if index < items.count - 1 {
                            Divider()
                                .padding(.leading, 56)
                        }
                    }
                }
                .transition(.opacity.combined(with: .move(edge: .top)))
            }
        }
        .background(Color.clCardBackground, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
    }

    // MARK: - Contact Card

    private var contactCard: some View {
        VStack(spacing: 16) {
            HStack(spacing: 14) {
                Image(systemName: "envelope.circle.fill")
                    .font(.system(size: 36))
                    .foregroundStyle(
                        LinearGradient(colors: [.clNavy, .clSky], startPoint: .topLeading, endPoint: .bottomTrailing)
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text("Still need help?")
                        .font(.headline)
                        .foregroundStyle(.clNavy)
                    Text("We usually reply within 24 hours.")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            Link(destination: URL(string: "mailto:alexandratitus768@gmail.com?subject=ContractLens%20Support")!) {
                Text("Email Support")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(
                        LinearGradient(colors: [.clNavy, .clSky], startPoint: .leading, endPoint: .trailing),
                        in: RoundedRectangle(cornerRadius: 12)
                    )
            }
        }
        .padding(16)
        .background(Color.clCardBackground, in: RoundedRectangle(cornerRadius: 16))
        .shadow(color: .black.opacity(0.06), radius: 8, y: 3)
    }

    // MARK: - Help Content

    private var gettingStartedItems: [HelpItem] {[
        HelpItem(
            icon: "doc.fill",
            iconColor: .clNavy,
            title: "Import a PDF",
            body: "Tap the + button in the top right, then choose \"Import PDF\". Select any contract or legal document from your Files app. The text is extracted automatically."
        ),
        HelpItem(
            icon: "camera.fill",
            iconColor: .clSky,
            title: "Scan a Physical Document",
            body: "Tap + and choose \"Scan Document\". Point your camera at each page and tap the shutter. You can scan multiple pages — they'll be combined into one document. Requires a real device (not available in Simulator)."
        ),
        HelpItem(
            icon: "photo.fill",
            iconColor: Color(red: 0.2, green: 0.7, blue: 0.3),
            title: "Import from Photos",
            body: "Tap + and choose \"Import from Photos\". Select a photo you've already taken of a document. The app uses on-device OCR to extract the text."
        ),
        HelpItem(
            icon: "lightbulb.fill",
            iconColor: Color(red: 0.9, green: 0.7, blue: 0.1),
            title: "Tips for Best Results",
            body: "For scans and photos, use good lighting and keep pages flat. The cleaner the image, the more accurate the text extraction — and the better the AI analysis will be."
        )
    ]}

    private var analysisItems: [HelpItem] {[
        HelpItem(
            icon: "sparkles",
            iconColor: Color(red: 0.6, green: 0.3, blue: 0.9),
            title: "How to Analyze a Document",
            body: "Tap a document in your list to open it. You'll see a \"Analyze Document\" button — tap it to start. The AI runs entirely on your device, so no internet connection is needed."
        ),
        HelpItem(
            icon: "clock.fill",
            iconColor: .clSky,
            title: "How Long Does It Take?",
            body: "Most contracts analyze in 15–45 seconds depending on their length. A progress screen shows what the AI is doing at each step. You can cancel at any time with the Cancel button."
        ),
        HelpItem(
            icon: "arrow.clockwise.circle.fill",
            iconColor: .clSlate,
            title: "Re-Analyzing a Document",
            body: "Pro subscribers can re-analyze a document at any time using the ··· menu in the top right of the analysis screen. This is useful if you want a fresh read after making notes."
        ),
        HelpItem(
            icon: "chart.bar.fill",
            iconColor: Color(red: 0.9, green: 0.55, blue: 0.1),
            title: "Free Tier Limits",
            body: "Free accounts can analyze 3 documents per month and see the first 3 clauses. Upgrade to Pro for unlimited analyses and full clause access."
        )
    ]}

    private var resultsItems: [HelpItem] {[
        HelpItem(
            icon: "doc.text.fill",
            iconColor: .clNavy,
            title: "Summary Tab",
            body: "A plain-English overview of the contract: what it is, the overall risk level (Low / Medium / High), the top concerns to be aware of, and the positive aspects working in your favour."
        ),
        HelpItem(
            icon: "list.bullet.clipboard.fill",
            iconColor: .clSky,
            title: "Clauses Tab",
            body: "Every identified clause with its own risk rating and a plain-English explanation. Free accounts see the first 3 clauses. Pro unlocks all of them. Tap any clause to read the full explanation."
        ),
        HelpItem(
            icon: "person.2.fill",
            iconColor: Color(red: 0.6, green: 0.3, blue: 0.9),
            title: "Parties Tab",
            body: "Lists everyone named in the contract — their role (e.g. Employer, Employee, Landlord) and any key obligations attributed to them."
        ),
        HelpItem(
            icon: "calendar",
            iconColor: Color(red: 0.9, green: 0.55, blue: 0.1),
            title: "Dates Tab",
            body: "All important dates and deadlines extracted from the contract — start dates, end dates, notice periods, renewal windows, and payment due dates."
        ),
        HelpItem(
            icon: "text.alignleft",
            iconColor: .clSlate,
            title: "Full Text Tab",
            body: "The complete extracted text of your document. Use the search bar at the top to find specific words or phrases — matching text is highlighted as you type."
        ),
        HelpItem(
            icon: "exclamationmark.triangle.fill",
            iconColor: .clRiskHigh,
            title: "Understanding Risk Levels",
            body: "Green = Low risk (standard, fair terms). Yellow = Medium risk (worth reviewing carefully). Red = High risk (unusual, one-sided, or potentially harmful clauses). Always consult a lawyer for important decisions."
        )
    ]}

    private var managingItems: [HelpItem] {[
        HelpItem(
            icon: "hand.tap.fill",
            iconColor: .clSky,
            title: "Open a Document",
            body: "Tap any document card in the main list to open it and view (or start) its analysis."
        ),
        HelpItem(
            icon: "hand.point.up.left.fill",
            iconColor: .clNavy,
            title: "Delete or Favorite",
            body: "Long-press any document card to reveal options: Favorite (stars the document for quick access) or Delete (permanently removes the document and its analysis after confirmation)."
        ),
        HelpItem(
            icon: "magnifyingglass",
            iconColor: Color(red: 0.6, green: 0.3, blue: 0.9),
            title: "Search Your Documents",
            body: "Use the search bar at the bottom of the main screen to find documents by title."
        ),
        HelpItem(
            icon: "line.3.horizontal.decrease.circle.fill",
            iconColor: Color(red: 0.9, green: 0.55, blue: 0.1),
            title: "Sort & Filter",
            body: "Tap the filter icon (top right, next to +) to sort by date or name, or filter by document type — contracts, leases, NDAs, employment agreements, and more."
        ),
        HelpItem(
            icon: "trash.fill",
            iconColor: .clRiskHigh,
            title: "Delete Everything",
            body: "Go to Settings → Data → Delete All Documents to wipe all documents and analyses at once. This cannot be undone."
        )
    ]}

    private var proItems: [HelpItem] {[
        HelpItem(
            icon: "crown.fill",
            iconColor: Color(red: 0.85, green: 0.65, blue: 0.1),
            title: "What's Included in Pro",
            body: "Unlimited analyses, all clauses revealed, PDF export, re-analyze documents, unlimited document history, and iCloud sync across all your devices."
        ),
        HelpItem(
            icon: "dollarsign.circle.fill",
            iconColor: .clRiskLow,
            title: "One-Time Purchase",
            body: "ContractLens Pro is a one-time $4.99 purchase — not a subscription. Pay once and it's yours forever, including all future updates."
        ),
        HelpItem(
            icon: "square.and.arrow.up.fill",
            iconColor: .clSky,
            title: "Export as PDF",
            body: "Pro subscribers can export any analysis as a formatted PDF report. Open the document, tap ··· in the top right, and choose \"Export as PDF\"."
        ),
        HelpItem(
            icon: "arrow.clockwise",
            iconColor: .clSlate,
            title: "Restore Your Purchase",
            body: "Already purchased Pro on another device or after reinstalling? Go to Settings → Subscription → Restore Purchase, or tap \"Restore Purchase\" on the upgrade screen."
        ),
        HelpItem(
            icon: "icloud.fill",
            iconColor: .clSky,
            title: "iCloud Sync",
            body: "Pro subscribers can enable iCloud Sync in Settings to keep documents and analyses in sync across all their iPhone and iPad devices. Requires an app restart to take effect after toggling."
        )
    ]}

    private var privacyItems: [HelpItem] {[
        HelpItem(
            icon: "iphone.and.arrow.forward",
            iconColor: .clNavy,
            title: "100% On-Device AI",
            body: "All analysis is done by Apple's on-device Foundation Models running locally on your iPhone or iPad. Your documents are never sent to any server — not ours, not Apple's, not anyone's."
        ),
        HelpItem(
            icon: "lock.fill",
            iconColor: .clRiskLow,
            title: "No Account Required",
            body: "ContractLens doesn't require you to create an account or log in. Your documents are stored only on your device (and optionally in your personal iCloud, if you enable sync)."
        ),
        HelpItem(
            icon: "externaldrive.fill",
            iconColor: .clSky,
            title: "Where Your Data Lives",
            body: "Documents and analyses are stored in your device's private SwiftData store. With iCloud Sync enabled (Pro), data is stored in your personal iCloud container — only you can access it."
        ),
        HelpItem(
            icon: "exclamationmark.shield.fill",
            iconColor: .clRiskMedium,
            title: "Legal Disclaimer",
            body: "ContractLens provides AI-generated analysis for informational purposes only. It is not legal advice. Always consult a qualified lawyer before making decisions based on any contract analysis."
        )
    ]}
}

// MARK: - Help Item Model

struct HelpItem {
    let icon: String
    let iconColor: Color
    let title: String
    let body: String
}

// MARK: - Help Item Row

private struct HelpItemRow: View {
    let item: HelpItem
    @State private var isExpanded = false

    var body: some View {
        Button {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.8)) {
                isExpanded.toggle()
            }
        } label: {
            VStack(spacing: 0) {
                HStack(spacing: 14) {
                    Image(systemName: item.icon)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundStyle(item.iconColor)
                        .frame(width: 28, height: 28)
                        .background(item.iconColor.opacity(0.12), in: RoundedRectangle(cornerRadius: 8))

                    Text(item.title)
                        .font(.subheadline.weight(.medium))
                        .foregroundStyle(.clNavy)

                    Spacer()

                    Image(systemName: "chevron.right")
                        .font(.caption2.bold())
                        .foregroundStyle(.clSlate.opacity(0.5))
                        .rotationEffect(.degrees(isExpanded ? 90 : 0))
                        .animation(.spring(response: 0.3, dampingFraction: 0.8), value: isExpanded)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)

                if isExpanded {
                    Text(item.body)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .lineSpacing(3)
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 16)
                        .padding(.bottom, 14)
                        .transition(.opacity.combined(with: .move(edge: .top)))
                }
            }
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Preview

#Preview {
    NavigationStack {
        HelpView()
    }
}

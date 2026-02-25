import SwiftUI

struct ClauseListView: View {
    let clauses: [ContractClause]
    let isPro: Bool
    @Binding var showingPaywall: Bool

    @State private var sortByRisk = false
    @State private var selectedClause: ContractClause?

    private var displayedClauses: [ContractClause] {
        var result = clauses
        if sortByRisk {
            result.sort { riskOrder($0.riskLevel) > riskOrder($1.riskLevel) }
        }
        if !isPro {
            return Array(result.prefix(AppConstants.freeClauseLimit))
        }
        return result
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 12) {
                HStack {
                    Text("\(clauses.count) Clauses Found")
                        .font(.headline)
                    Spacer()
                    Button {
                        withAnimation { sortByRisk.toggle() }
                    } label: {
                        Label(
                            sortByRisk ? "Sort by Order" : "Sort by Risk",
                            systemImage: sortByRisk ? "list.number" : "exclamationmark.triangle"
                        )
                        .font(.subheadline)
                    }
                }
                .padding(.horizontal)

                ForEach(displayedClauses) { clause in
                    ClauseCardView(clause: clause)
                        .onTapGesture {
                            selectedClause = clause
                        }
                }

                if !isPro && clauses.count > AppConstants.freeClauseLimit {
                    Button {
                        showingPaywall = true
                    } label: {
                        HStack {
                            Image(systemName: "lock.fill")
                            Text("Upgrade to see all \(clauses.count) clauses")
                        }
                        .font(.subheadline.bold())
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.clSky, in: RoundedRectangle(cornerRadius: 12))
                    }
                    .padding(.horizontal)
                }
            }
            .padding(.vertical)
        }
        .sheet(item: $selectedClause) { clause in
            NavigationStack {
                ClauseDetailView(clause: clause)
            }
        }
    }

    private func riskOrder(_ level: RiskLevel) -> Int {
        switch level {
        case .low: return 0
        case .medium: return 1
        case .high: return 2
        }
    }
}

struct ClauseCardView: View {
    let clause: ContractClause
    @State private var isExpanded = false

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Rectangle()
                    .fill(clause.riskLevel.color)
                    .frame(width: 4)
                    .clipShape(Capsule())

                VStack(alignment: .leading, spacing: 4) {
                    HStack {
                        Image(systemName: clause.category.icon)
                            .foregroundStyle(.secondary)
                            .font(.caption)

                        Text(clause.category.displayName)
                            .font(.caption)
                            .foregroundStyle(.secondary)

                        Spacer()

                        RiskBadge(level: clause.riskLevel)
                    }

                    Text(clause.title)
                        .font(.subheadline.bold())

                    if isExpanded {
                        Text(clause.plainEnglishExplanation)
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                            .transition(.opacity.combined(with: .move(edge: .top)))
                    }
                }
            }

            HStack {
                Spacer()
                Image(systemName: isExpanded ? "chevron.up" : "chevron.down")
                    .font(.caption)
                    .foregroundStyle(.tertiary)
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 12))
        .padding(.horizontal)
        .onTapGesture {
            withAnimation(.easeInOut(duration: 0.2)) {
                isExpanded.toggle()
            }
        }
    }
}

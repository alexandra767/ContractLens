import SwiftUI

struct PartiesView: View {
    let parties: [PartyInfo]

    var body: some View {
        ScrollView {
            if parties.isEmpty {
                ContentUnavailableView(
                    "No Parties Found",
                    systemImage: "person.2.slash",
                    description: Text("The AI could not identify specific parties in this document.")
                )
            } else {
                VStack(spacing: 16) {
                    ForEach(parties) { party in
                        PartyCard(party: party)
                    }
                }
                .padding()
            }
        }
    }
}

struct PartyCard: View {
    let party: PartyInfo

    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .font(.title2)
                    .foregroundStyle(.clSky)

                VStack(alignment: .leading) {
                    Text(party.name)
                        .font(.headline)
                    Text(party.role)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }

                Spacer()
            }

            if !party.obligations.isEmpty {
                Divider()

                VStack(alignment: .leading, spacing: 6) {
                    Text("Obligations")
                        .font(.caption.bold())
                        .foregroundStyle(.secondary)

                    ForEach(party.obligations, id: \.self) { obligation in
                        HStack(alignment: .top, spacing: 8) {
                            Image(systemName: "arrow.right.circle.fill")
                                .font(.caption)
                                .foregroundStyle(.clSky)
                            Text(obligation)
                                .font(.subheadline)
                        }
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial, in: RoundedRectangle(cornerRadius: 16))
    }
}

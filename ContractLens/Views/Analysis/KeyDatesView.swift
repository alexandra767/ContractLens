import SwiftUI

struct KeyDatesView: View {
    let dates: [KeyDateInfo]

    var body: some View {
        ScrollView {
            if dates.isEmpty {
                ContentUnavailableView(
                    "No Dates Found",
                    systemImage: "calendar.badge.exclamationmark",
                    description: Text("The AI could not identify specific dates or deadlines in this document.")
                )
            } else {
                VStack(spacing: 0) {
                    ForEach(Array(dates.enumerated()), id: \.offset) { index, dateInfo in
                        DateTimelineItem(dateInfo: dateInfo, isLast: index == dates.count - 1)
                    }
                }
                .padding()
            }
        }
    }
}

struct DateTimelineItem: View {
    let dateInfo: KeyDateInfo
    let isLast: Bool

    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // Timeline indicator
            VStack(spacing: 0) {
                Circle()
                    .fill(dateInfo.isDeadline ? Color.clRiskHigh : Color.clSky)
                    .frame(width: 12, height: 12)

                if !isLast {
                    Rectangle()
                        .fill(Color(.systemGray4))
                        .frame(width: 2)
                        .frame(maxHeight: .infinity)
                }
            }
            .frame(width: 12)

            // Content
            VStack(alignment: .leading, spacing: 6) {
                HStack {
                    Text(dateInfo.label)
                        .font(.subheadline.bold())

                    Spacer()

                    if dateInfo.isDeadline {
                        Label("Deadline", systemImage: "exclamationmark.triangle.fill")
                            .font(.caption2.bold())
                            .foregroundStyle(.white)
                            .padding(.horizontal, 8)
                            .padding(.vertical, 3)
                            .background(.red, in: Capsule())
                    }
                }

                Text(dateInfo.dateString)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .padding(.bottom, isLast ? 0 : 24)
        }
    }
}

import SwiftUI

struct AnalysisProgressView: View {
    let viewModel: AnalysisViewModel

    @Environment(\.dismiss) private var dismiss

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            ZStack {
                Circle()
                    .stroke(Color.clSky.opacity(0.2), lineWidth: 8)
                    .frame(width: 120, height: 120)

                Circle()
                    .trim(from: 0, to: viewModel.progress)
                    .stroke(Color.clSky, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 120, height: 120)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 0.5), value: viewModel.progress)

                Text("\(Int(viewModel.progress * 100))%")
                    .font(.title.bold())
                    .foregroundStyle(.clNavy)
            }
            .accessibilityElement(children: .ignore)
            .accessibilityLabel("Analysis progress")
            .accessibilityValue("\(Int(viewModel.progress * 100)) percent")

            Text("Analyzing Document")
                .font(.title2.bold())

            if let step = viewModel.currentStep {
                Text(step.rawValue)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .transition(.opacity)
                    .animation(.easeInOut, value: step)
            }

            ProgressView(value: viewModel.progress)
                .tint(.clSky)
                .padding(.horizontal, 60)
                .accessibilityLabel("Analysis progress bar")
                .accessibilityValue("\(Int(viewModel.progress * 100)) percent complete")

            Button {
                viewModel.cancelAnalysis()
            } label: {
                Text("Cancel Analysis")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }
            .accessibilityHint("Stops the current document analysis")

            Spacer()

            Text("All analysis runs on-device. Your data never leaves this phone.")
                .font(.caption)
                .foregroundStyle(.tertiary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
        }
    }
}

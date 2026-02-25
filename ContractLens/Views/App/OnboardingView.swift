import SwiftUI

struct OnboardingView: View {
    @Binding var hasSeenOnboarding: Bool
    @State private var currentPage = 0

    var body: some View {
        TabView(selection: $currentPage) {
            OnboardingPage(
                icon: "doc.text.magnifyingglass",
                title: "Understand Any Contract in Seconds",
                description: "AI-powered analysis breaks down complex legal language into plain English you can actually understand.",
                color: .clSky
            )
            .tag(0)

            OnboardingPage(
                icon: "lock.shield.fill",
                title: "Your Privacy, Protected",
                description: "AI analysis runs 100% on your device using Apple's built-in intelligence. Your contracts never leave your phone. No external servers, no cloud AI, no data collection.",
                color: .clNavy
            )
            .tag(1)

            VStack(spacing: 32) {
                Spacer()

                Image(systemName: "checkmark.circle.fill")
                    .font(.system(size: 80))
                    .foregroundStyle(.green)

                Text("Get Started Free")
                    .font(.largeTitle.bold())

                Text("Analyze up to 3 contracts per month for free.\nUpgrade anytime for unlimited access.")
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 40)

                Button {
                    withAnimation {
                        hasSeenOnboarding = true
                    }
                } label: {
                    Text("Start Analyzing")
                        .font(.headline)
                        .foregroundStyle(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(.clSky, in: RoundedRectangle(cornerRadius: 16))
                }
                .padding(.horizontal, 40)

                Spacer()
            }
            .tag(2)
        }
        .tabViewStyle(.page(indexDisplayMode: .always))
        .indexViewStyle(.page(backgroundDisplayMode: .always))
    }
}

struct OnboardingPage: View {
    let icon: String
    let title: String
    let description: String
    let color: Color

    var body: some View {
        VStack(spacing: 32) {
            Spacer()

            Image(systemName: icon)
                .font(.system(size: 80))
                .foregroundStyle(color)

            Text(title)
                .font(.largeTitle.bold())
                .multilineTextAlignment(.center)
                .padding(.horizontal, 24)

            Text(description)
                .font(.body)
                .foregroundStyle(.secondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 40)

            Spacer()
            Spacer()
        }
        .accessibilityElement(children: .combine)
        .accessibilityLabel("\(title). \(description)")
    }
}

import SwiftUI

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Spacer(minLength: 20)

                // App Icon
                Image(systemName: "doc.text.magnifyingglass")
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

                // App name and version
                VStack(spacing: 6) {
                    Text(AppConstants.appName)
                        .font(.title.bold())
                        .foregroundStyle(.clNavy)

                    Text("Version \(appVersion)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)

                    Text(AppConstants.appTagline)
                        .font(.headline)
                        .foregroundStyle(.clSky)
                        .padding(.top, 2)
                }

                // Description
                VStack(spacing: 12) {
                    Text("Your contracts, analyzed privately.")
                        .font(.headline)
                        .foregroundStyle(.clNavy)

                    Text("""
                        ContractLens uses Apple's on-device AI to analyze legal documents \
                        entirely on your iPhone or iPad. Your documents never leave your device \
                        -- no servers, no cloud processing, no data collection. \
                        Get plain-English summaries, risk assessments, and clause-by-clause \
                        breakdowns in seconds, all while keeping your sensitive information completely private.
                        """)
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .lineSpacing(4)
                }
                .padding(.horizontal, 24)

                Divider()
                    .padding(.horizontal, 40)

                // Privacy link
                NavigationLink {
                    PrivacyPolicyView()
                } label: {
                    Label("Privacy Policy", systemImage: "hand.raised.fill")
                        .font(.subheadline.weight(.medium))
                }

                Spacer(minLength: 40)

                // Footer
                Text("Made with care")
                    .font(.footnote)
                    .foregroundStyle(.clSlate.opacity(0.6))
                    .padding(.bottom, 20)
            }
            .frame(maxWidth: .infinity)
        }
        .background(Color.clBackground)
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }

    private var appVersion: String {
        Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0"
    }
}

#Preview {
    NavigationStack {
        AboutView()
    }
}

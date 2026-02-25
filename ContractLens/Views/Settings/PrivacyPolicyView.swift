import SwiftUI

struct PrivacyPolicyView: View {
    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                Text("Privacy Policy")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.clNavy)

                Text("Your privacy is fundamental to ContractLens.")
                    .font(.headline)
                    .foregroundStyle(.clSlate)

                policySection(
                    title: "What We Don't Collect",
                    icon: "eye.slash.fill",
                    content: """
                        ContractLens does not collect, store, transmit, or share any of the following:

                        - Your documents or their contents
                        - Analysis results or summaries
                        - Personal information or identifiers
                        - Usage analytics or behavioral data
                        - Location data
                        - Device identifiers for tracking
                        - Crash reports sent to external servers
                        """
                )

                policySection(
                    title: "AI-Powered Analysis",
                    icon: "brain",
                    content: """
                        ContractLens uses Apple's Foundation Models to analyze your documents. \
                        This AI processing happens entirely on your device using Apple's built-in \
                        machine learning capabilities. No document data is sent to external AI \
                        services, cloud APIs, or third-party servers.

                        Apple's Foundation Models run locally on devices with Apple Silicon \
                        (iPhone 15 Pro or newer, iPad with M1 or newer). Apple may collect \
                        anonymized usage statistics about Foundation Models performance as \
                        described in Apple's own privacy policy. ContractLens has no access \
                        to or control over Apple's system-level data practices.
                        """
                )

                policySection(
                    title: "How Analysis Works",
                    icon: "cpu",
                    content: """
                        All document analysis is performed 100% on-device using Apple's \
                        Foundation Models framework. Your documents never leave your device. \
                        No text is sent to any external server or cloud API. AI processing \
                        happens entirely on your iPhone or iPad. No internet connection is \
                        required for analysis.
                        """
                )

                policySection(
                    title: "Your Data",
                    icon: "lock.shield.fill",
                    content: """
                        Documents and analysis results are stored locally on your device \
                        using SwiftData. If you enable iCloud, data syncs through your \
                        personal iCloud account under Apple's privacy policies.

                        You can delete any document or all data at any time from the \
                        Settings screen. Deleted data is permanently removed. ContractLens \
                        does not maintain any server-side backup of your data.
                        """
                )

                policySection(
                    title: "Contact",
                    icon: "envelope.fill",
                    content: """
                        If you have questions about this privacy policy, contact us at \
                        alexandratitus768@gmail.com.
                        """
                )
            }
            .padding(20)
        }
        .background(Color.clBackground)
        .navigationTitle("Privacy Policy")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func policySection(title: String, icon: String, content: String) -> some View {
        VStack(alignment: .leading, spacing: 10) {
            Label(title, systemImage: icon)
                .font(.title3.bold())
                .foregroundStyle(.clNavy)

            Text(content)
                .font(.subheadline)
                .foregroundStyle(.clSlate)
                .lineSpacing(4)
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(Color.clCardBackground)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        PrivacyPolicyView()
    }
}

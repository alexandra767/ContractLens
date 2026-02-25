import SwiftUI
import LocalAuthentication

struct AppLockView: View {
    @Binding var isUnlocked: Bool
    @State private var authError: String?

    var body: some View {
        ZStack {
            LinearGradient(
                colors: [.clNavy, .clSky],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 32) {
                Spacer()

                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 72))
                    .foregroundStyle(.white)

                Text("ContractLens")
                    .font(.largeTitle.bold())
                    .foregroundStyle(.white)

                Spacer()

                VStack(spacing: 16) {
                    Button {
                        authenticate()
                    } label: {
                        Label(biometricButtonLabel, systemImage: biometricIcon)
                            .font(.headline)
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(.white.opacity(0.2), in: RoundedRectangle(cornerRadius: 14))
                    }
                    .padding(.horizontal, 40)
                    .accessibilityLabel(biometricButtonLabel)

                    if let error = authError {
                        Text(error)
                            .font(.caption)
                            .foregroundStyle(.white.opacity(0.8))
                            .multilineTextAlignment(.center)
                            .padding(.horizontal, 40)
                    }
                }
                .padding(.bottom, 60)
            }
        }
        .onAppear {
            authenticate()
        }
    }

    private var biometricButtonLabel: String {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return "Unlock with Passcode"
        }
        return context.biometryType == .faceID ? "Unlock with Face ID" : "Unlock with Touch ID"
    }

    private var biometricIcon: String {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) else {
            return "lock.fill"
        }
        return context.biometryType == .faceID ? "faceid" : "touchid"
    }

    private func authenticate() {
        let context = LAContext()
        var error: NSError?
        guard context.canEvaluatePolicy(.deviceOwnerAuthentication, error: &error) else {
            authError = error?.localizedDescription
            return
        }
        context.evaluatePolicy(.deviceOwnerAuthentication,
                                localizedReason: "Unlock ContractLens") { success, evalError in
            DispatchQueue.main.async {
                if success {
                    isUnlocked = true
                    authError = nil
                } else if let e = evalError as? LAError, e.code != .userCancel {
                    authError = e.localizedDescription
                }
            }
        }
    }
}

#Preview {
    AppLockView(isUnlocked: .constant(false))
}

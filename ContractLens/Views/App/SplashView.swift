import SwiftUI

struct SplashView: View {
    @State private var isActive = false
    @State private var opacity: Double = 0

    var body: some View {
        if isActive {
            ContentView()
        } else {
            VStack(spacing: 16) {
                Image(systemName: "doc.text.magnifyingglass")
                    .font(.system(size: 64))
                    .foregroundStyle(Color.clNavy)

                Text(AppConstants.appName)
                    .font(.largeTitle.bold())
                    .foregroundStyle(Color.clNavy)

                Text(AppConstants.appTagline)
                    .font(.subheadline)
                    .foregroundStyle(Color.clSlate)
            }
            .opacity(opacity)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.clBackground)
            .onAppear {
                withAnimation(.easeIn(duration: 0.8)) {
                    opacity = 1
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
                    withAnimation { isActive = true }
                }
            }
        }
    }
}

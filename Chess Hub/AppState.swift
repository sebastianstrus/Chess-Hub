import SwiftUI
import Combine

// MARK: - App State

class AppState: ObservableObject {
    @Published var hasSeenOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasSeenOnboarding, forKey: "hasSeenOnboarding") }
    }
    @Published var showSplash: Bool = true

    init() {
        self.hasSeenOnboarding = UserDefaults.standard.bool(forKey: "hasSeenOnboarding")
    }
}

// MARK: - Root View

struct RootView: View {
    @EnvironmentObject var appState: AppState

    var body: some View {
        ZStack {
            if appState.showSplash {
                SplashView()
                    .transition(.opacity)
                    .zIndex(2)
            } else if !appState.hasSeenOnboarding {
                OnboardingView()
                    .transition(.asymmetric(
                        insertion: .opacity,
                        removal: .move(edge: .leading).combined(with: .opacity)
                    ))
                    .zIndex(1)
            } else {
                MainTabView()
                    .transition(.opacity)
                    .zIndex(0)
            }
        }
        .animation(.easeInOut(duration: 0.6), value: appState.showSplash)
        .animation(.easeInOut(duration: 0.5), value: appState.hasSeenOnboarding)
    }
}

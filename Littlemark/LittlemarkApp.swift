import SwiftUI
import SwiftData

@main
struct LittlemarkApp: App {
    @State private var launch = AppLaunchViewModel {
        #if DEBUG
        if ScreenshotDemo.isEnabled {
            return try ScreenshotDemo.makeDependencyContainer()
        }
        #endif
        return DependencyContainer(modelContainer: try ModelContainerFactory.make())
    }
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false
    @State private var languageManager = LanguageManager.shared
    @State private var themeManager = ThemeManager.shared
    @State private var languageId = UUID()

    var body: some Scene {
        WindowGroup {
            Group {
                if let container = launch.container {
                    Group {
                        if hasCompletedOnboarding {
                            ContentView(container: container)
                        } else {
                            OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                        }
                    }
                    .task {
                        await container.ensureDefaultUser()
                    }
                    .modelContainer(container.modelContainer)
                } else {
                    StoreErrorView(onRetry: launch.retry)
                }
            }
            .id(languageId)
            .environment(languageManager)
            .environment(themeManager)
            .environment(\.locale, Locale(identifier: languageManager.currentLanguage.rawValue))
            .preferredColorScheme(themeManager.colorScheme)
            .onChange(of: languageManager.currentLanguage) {
                languageId = UUID()
            }
        }
    }
}

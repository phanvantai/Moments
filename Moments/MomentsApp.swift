import SwiftUI
import SwiftData

@main
struct MomentsApp: App {
    let container: DependencyContainer
    @AppStorage("hasCompletedOnboarding") private var hasCompletedOnboarding = false

    init() {
        let schema = Schema([
            SDMoment.self,
            SDMediaItem.self,
            SDUser.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let appSupportURL = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask).first!
            if !FileManager.default.fileExists(atPath: appSupportURL.path) {
                try FileManager.default.createDirectory(at: appSupportURL, withIntermediateDirectories: true)
            }
            let modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            self.container = DependencyContainer(modelContainer: modelContainer)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            if hasCompletedOnboarding {
                ContentView(container: container)
                    .task {
                        await container.ensureDefaultUser()
                    }
            } else {
                OnboardingView(hasCompletedOnboarding: $hasCompletedOnboarding)
                    .task {
                        await container.ensureDefaultUser()
                    }
            }
        }
        .modelContainer(container.modelContainer)
    }
}

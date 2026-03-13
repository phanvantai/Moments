import SwiftUI
import SwiftData

@main
struct MomentsApp: App {
    let container: DependencyContainer

    init() {
        let schema = Schema([
            SDMoment.self,
            SDMediaItem.self,
            SDUser.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            let modelContainer = try ModelContainer(for: schema, configurations: [modelConfiguration])
            self.container = DependencyContainer(modelContainer: modelContainer)
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }

    var body: some Scene {
        WindowGroup {
            ContentView(container: container)
                .task {
                    await container.ensureDefaultUser()
                }
        }
        .modelContainer(container.modelContainer)
    }
}

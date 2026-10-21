import Foundation
import SwiftData

@MainActor
final class DependencyContainer {
    let modelContainer: ModelContainer

    // Repositories
    let momentRepository: MomentRepositoryProtocol
    let mediaRepository: MediaRepositoryProtocol

    // Services
    let mediaFileService: MediaFileServiceProtocol
    let permissionService: PermissionServiceProtocol
    let locationService: LocationServiceProtocol
    let weatherService: WeatherServiceProtocol
    let categoryEngine: CategoryEngineProtocol

    // Use Cases
    let createMomentUseCase: CreateMomentUseCaseProtocol
    let fetchMomentsUseCase: FetchMomentsUseCaseProtocol
    let deleteMomentUseCase: DeleteMomentUseCaseProtocol

    init(modelContainer: ModelContainer) {
        self.modelContainer = modelContainer

        // Services
        let mediaFileService = MediaFileService()
        self.mediaFileService = mediaFileService
        self.permissionService = PermissionService()
        self.locationService = LocationService()
        self.weatherService = WeatherService()
        self.categoryEngine = CategoryEngine()

        // Repositories
        let momentRepository = MomentRepository(modelContainer: modelContainer)
        self.momentRepository = momentRepository

        let mediaRepository = MediaRepository(mediaFileService: mediaFileService)
        self.mediaRepository = mediaRepository

        // Use Cases
        self.createMomentUseCase = CreateMomentUseCase(momentRepository: momentRepository)
        self.fetchMomentsUseCase = FetchMomentsUseCase(momentRepository: momentRepository)
        self.deleteMomentUseCase = DeleteMomentUseCase(
            momentRepository: momentRepository,
            mediaRepository: mediaRepository
        )
    }

    // MARK: - View Model Factories

    func makeTimelineViewModel() -> TimelineViewModel {
        TimelineViewModel(
            fetchMomentsUseCase: fetchMomentsUseCase,
            deleteMomentUseCase: deleteMomentUseCase
        )
    }

    func makeCreateMomentViewModel(initialStep: CreateMomentStep) -> CreateMomentViewModel {
        CreateMomentViewModel(
            initialStep: initialStep,
            createMomentUseCase: createMomentUseCase,
            permissionService: permissionService,
            mediaRepository: mediaRepository,
            locationService: locationService,
            weatherService: weatherService,
            categoryEngine: categoryEngine
        )
    }

    func ensureDefaultUser() async {
        let context = ModelContext(modelContainer)
        let defaultUserId = User.default.id
        let descriptor = FetchDescriptor<SDUser>(
            predicate: #Predicate { $0.id == defaultUserId }
        )
        do {
            let existing = try context.fetch(descriptor)
            if existing.isEmpty {
                let sdUser = UserMapper.toSDModel(User.default)
                context.insert(sdUser)
                try context.save()
            }
        } catch {
            // Default user creation failed - non-fatal
        }
    }
}

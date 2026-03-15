import Foundation

@Observable
@MainActor
final class CreateMomentViewModel: Identifiable {
    let id = UUID()
    // MARK: - State

    var capturedMediaItems: [MediaItem] = []
    var voiceNote: VoiceNote?
    var text: String = ""
    var tags: [String] = []
    var errorMessage: String?
    var isSaved: Bool = false
    var isSaving: Bool = false

    // Smart features state
    private(set) var currentLocation: Location?
    private(set) var currentWeather: Weather?
    private(set) var suggestedCategoryKeys: [String] = []
    var selectedCategoryKeys: Set<String> = []
    var isLocationEnabled: Bool = true
    private(set) var isLoadingSmartFeatures: Bool = false

    // Permission availability
    private(set) var isCameraAvailable: Bool = true
    private(set) var isVoiceAvailable: Bool = true
    private(set) var isGalleryAvailable: Bool = true

    var canSave: Bool {
        !capturedMediaItems.isEmpty || voiceNote != nil
    }

    // MARK: - Dependencies

    private let createMomentUseCase: CreateMomentUseCaseProtocol
    private let permissionService: PermissionServiceProtocol
    let mediaRepository: MediaRepositoryProtocol
    private let locationService: LocationServiceProtocol
    private let weatherService: WeatherServiceProtocol
    private let categoryEngine: CategoryEngineProtocol

    init(
        createMomentUseCase: CreateMomentUseCaseProtocol,
        permissionService: PermissionServiceProtocol,
        mediaRepository: MediaRepositoryProtocol,
        locationService: LocationServiceProtocol,
        weatherService: WeatherServiceProtocol,
        categoryEngine: CategoryEngineProtocol
    ) {
        self.createMomentUseCase = createMomentUseCase
        self.permissionService = permissionService
        self.mediaRepository = mediaRepository
        self.locationService = locationService
        self.weatherService = weatherService
        self.categoryEngine = categoryEngine
    }

    // MARK: - Media Management

    func addMedia(_ item: MediaItem) {
        capturedMediaItems.append(item)
    }

    func removeMedia(_ id: UUID) {
        capturedMediaItems.removeAll { $0.id == id }
    }

    func setVoiceNote(_ note: VoiceNote) {
        voiceNote = note
    }

    func removeVoiceNote() {
        voiceNote = nil
    }

    // MARK: - Tags

    func addTag(_ tag: String) {
        let trimmed = tag.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty, !tags.contains(trimmed) else { return }
        tags.append(trimmed)
    }

    func removeTag(_ tag: String) {
        tags.removeAll { $0 == tag }
    }

    // MARK: - Permissions

    func refreshPermissions() async {
        let cameraStatus = await permissionService.status(for: .camera)
        let micStatus = await permissionService.status(for: .microphone)
        let photoStatus = await permissionService.status(for: .photoLibrary)

        isCameraAvailable = cameraStatus != .denied && cameraStatus != .restricted
        isVoiceAvailable = micStatus != .denied && micStatus != .restricted
        isGalleryAvailable = photoStatus != .denied && photoStatus != .restricted
    }

    func requestPermission(_ type: PermissionType) async -> PermissionStatus {
        await permissionService.request(type)
    }

    // MARK: - Media Saving

    func savePhoto(data: Data) async {
        do {
            let fileName = "\(UUID().uuidString).jpg"
            let filePath = try await mediaRepository.saveMedia(data: data, fileName: fileName)
            let mediaItem = MediaItem(
                momentId: UUID(),
                type: .photo,
                filePath: filePath,
                width: 0,
                height: 0,
                sortOrder: capturedMediaItems.count
            )
            addMedia(mediaItem)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func saveVideo(data: Data) async {
        do {
            let fileName = "\(UUID().uuidString).mov"
            let filePath = try await mediaRepository.saveMedia(data: data, fileName: fileName)
            let thumbnailPath = try? await mediaRepository.generateVideoThumbnail(videoPath: filePath)
            let mediaItem = MediaItem(
                momentId: UUID(),
                type: .video,
                filePath: filePath,
                thumbnailPath: thumbnailPath,
                width: 0,
                height: 0,
                sortOrder: capturedMediaItems.count
            )
            addMedia(mediaItem)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func saveVoiceRecording(data: Data, duration: TimeInterval, transcript: String?) async {
        do {
            let fileName = "\(UUID().uuidString).m4a"
            let filePath = try await mediaRepository.saveVoiceNote(data: data, fileName: fileName)
            let voiceNote = VoiceNote(
                filePath: filePath,
                duration: duration,
                transcript: transcript
            )
            setVoiceNote(voiceNote)
        } catch {
            errorMessage = error.localizedDescription
        }
    }

    func saveGalleryItem(data: Data, isVideo: Bool) async {
        print("[VM] saveGalleryItem called, isVideo=\(isVideo), dataSize=\(data.count)")
        do {
            let ext = isVideo ? "mov" : "jpg"
            let fileName = "\(UUID().uuidString).\(ext)"
            let filePath = try await mediaRepository.saveMedia(data: data, fileName: fileName)
            print("[VM] Media saved at: \(filePath)")
            let mediaItem = MediaItem(
                momentId: UUID(),
                type: isVideo ? .video : .photo,
                filePath: filePath,
                width: 0,
                height: 0,
                sortOrder: capturedMediaItems.count
            )
            addMedia(mediaItem)
            print("[VM] Media item added, total count: \(capturedMediaItems.count)")
        } catch {
            print("[VM] saveGalleryItem error: \(error)")
            errorMessage = error.localizedDescription
        }
    }

    // MARK: - Smart Features

    func loadSmartFeatures() async {
        isLoadingSmartFeatures = true

        // Fetch location
        currentLocation = await locationService.getCurrentLocation()

        // Fetch weather if location available
        if let location = currentLocation {
            currentWeather = await weatherService.fetchWeather(
                latitude: location.latitude,
                longitude: location.longitude
            )
        }

        // Suggest categories
        await refreshCategories()

        isLoadingSmartFeatures = false
    }

    func refreshCategories() async {
        let categoryKeys = await categoryEngine.suggest(
            text: text.isEmpty ? nil : text,
            voiceTranscript: voiceNote?.transcript,
            imageData: nil,
            location: currentLocation
        )
        suggestedCategoryKeys = categoryKeys
        selectedCategoryKeys = Set(categoryKeys)
    }

    func toggleCategory(_ key: String) {
        if selectedCategoryKeys.contains(key) {
            selectedCategoryKeys.remove(key)
        } else {
            selectedCategoryKeys.insert(key)
        }
    }

    func disableLocation() {
        isLocationEnabled = false
        currentLocation = nil
        currentWeather = nil
    }

    // MARK: - Save

    func save() async {
        guard canSave else { return }
        isSaving = true
        errorMessage = nil

        let categories = selectedCategoryKeys.compactMap { MomentCategory.find(byKey: $0) }

        let moment = Moment(
            userId: User.default.id,
            text: text.isEmpty ? nil : text,
            mediaItems: capturedMediaItems,
            voiceNote: voiceNote,
            location: isLocationEnabled ? currentLocation : nil,
            categories: categories,
            tags: tags,
            weather: currentWeather
        )

        do {
            try await createMomentUseCase.execute(moment)
            resetState()
            isSaved = true
        } catch {
            errorMessage = error.localizedDescription
        }
        isSaving = false
    }

    // MARK: - Reset

    func resetState() {
        capturedMediaItems = []
        voiceNote = nil
        text = ""
        tags = []
        errorMessage = nil
        isSaved = false
        currentLocation = nil
        currentWeather = nil
        suggestedCategoryKeys = []
        selectedCategoryKeys = []
        isLocationEnabled = true
    }
}

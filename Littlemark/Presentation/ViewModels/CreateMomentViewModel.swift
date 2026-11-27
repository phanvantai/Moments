import Foundation

@Observable
@MainActor
final class CreateMomentViewModel: Identifiable {
    let id = UUID()
    let initialStep: CreateMomentStep

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
    private(set) var weatherAttribution: WeatherAttribution?
    private(set) var suggestedCategoryKeys: [String] = []
    var selectedCategoryKeys: Set<String> = []
    var isLocationEnabled: Bool = true
    private(set) var isLoadingSmartFeatures: Bool = false

    // Date/time editing
    var selectedDate: Date = Date()

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
        initialStep: CreateMomentStep,
        createMomentUseCase: CreateMomentUseCaseProtocol,
        permissionService: PermissionServiceProtocol,
        mediaRepository: MediaRepositoryProtocol,
        locationService: LocationServiceProtocol,
        weatherService: WeatherServiceProtocol,
        categoryEngine: CategoryEngineProtocol
    ) {
        self.initialStep = initialStep
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

    /// Removes the item and deletes the files it wrote (the media file and, for videos, its thumbnail).
    func removeMedia(_ id: UUID) async {
        guard let item = capturedMediaItems.first(where: { $0.id == id }) else { return }
        capturedMediaItems.removeAll { $0.id == id }
        await deleteFiles(of: item)
    }

    func setVoiceNote(_ note: VoiceNote) {
        voiceNote = note
    }

    func removeVoiceNote() async {
        guard let note = voiceNote else { return }
        voiceNote = nil
        try? await mediaRepository.deleteVoiceNote(filePath: note.filePath)
    }

    /// Called when the user leaves the capture flow without saving: deletes every
    /// file written for this draft, then resets the state.
    func discardDraft() async {
        let items = capturedMediaItems
        capturedMediaItems = []
        for item in items {
            await deleteFiles(of: item)
        }
        await removeVoiceNote()
        resetState()
    }

    private func deleteFiles(of item: MediaItem) async {
        try? await mediaRepository.deleteMedia(filePath: item.filePath)
        if let thumbnailPath = item.thumbnailPath {
            try? await mediaRepository.deleteMedia(filePath: thumbnailPath)
        }
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

    /// Moves the recorded or picked video into the media folder without loading it into memory.
    func saveVideo(fileURL: URL) async {
        do {
            let fileName = "\(UUID().uuidString).mov"
            let filePath = try await mediaRepository.importMedia(from: fileURL, fileName: fileName)
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

    func saveVoiceRecording(fileURL: URL, duration: TimeInterval, transcript: String?) async {
        do {
            let fileName = "\(UUID().uuidString).m4a"
            let filePath = try await mediaRepository.importVoiceNote(from: fileURL, fileName: fileName)
            await removeVoiceNote()
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

    // MARK: - Smart Features

    func loadSmartFeatures() async {
        isLoadingSmartFeatures = true

        // Request location permission if not yet determined, then fetch location
        let locationStatus = await permissionService.status(for: .location)
        if locationStatus == .notDetermined {
            _ = await permissionService.request(.location)
        }
        currentLocation = await locationService.getCurrentLocation()

        // Fetch weather if location available
        if let location = currentLocation {
            currentWeather = await weatherService.fetchWeather(
                latitude: location.latitude,
                longitude: location.longitude,
                date: selectedDate
            )
            await loadWeatherAttributionIfNeeded()
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

    // MARK: - Date Editing

    func updateDate(_ newDate: Date) async {
        selectedDate = newDate
        await refetchWeatherIfNeeded()
    }

    // MARK: - Location Editing

    func updateLocation(_ newLocation: Location) async {
        currentLocation = newLocation
        isLocationEnabled = true
        await refetchWeatherIfNeeded()
        await refreshCategories()
    }

    // MARK: - Weather Re-fetch

    private func refetchWeatherIfNeeded() async {
        currentWeather = nil
        guard let location = currentLocation, isLocationEnabled else { return }
        currentWeather = await weatherService.fetchWeather(
            latitude: location.latitude,
            longitude: location.longitude,
            date: selectedDate
        )
        await loadWeatherAttributionIfNeeded()
    }

    private func loadWeatherAttributionIfNeeded() async {
        guard currentWeather != nil, weatherAttribution == nil else { return }
        weatherAttribution = await weatherService.fetchAttribution()
    }

    // MARK: - Save

    func save() async {
        guard canSave else { return }
        isSaving = true
        errorMessage = nil

        let categories = selectedCategoryKeys.compactMap { MomentCategory.find(byKey: $0) }

        let moment = Moment(
            userId: User.default.id,
            createdAt: selectedDate,
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
        selectedDate = Date()
    }
}

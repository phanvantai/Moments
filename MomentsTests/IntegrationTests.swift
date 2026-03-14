import Testing
import Foundation
@testable import Moments

// MARK: - Integration Tests (Mock External Services)

@MainActor
struct IntegrationTests {
    let mockMomentRepo = MockMomentRepository()
    let mockMediaRepo = MockMediaRepository()
    let mockPermissionService = MockPermissionService()
    let mockLocationService = MockLocationService()
    let mockWeatherService = MockWeatherService()
    let mockCategoryEngine = MockCategoryEngine()

    // MARK: - Full Flow: Create → Save → Load → Verify

    @Test func test_fullFlow_createSaveLoadVerify() async throws {
        // Setup
        let createUseCase = CreateMomentUseCase(momentRepository: mockMomentRepo)
        let fetchUseCase = FetchMomentsUseCase(momentRepository: mockMomentRepo)

        let vm = CreateMomentViewModel(
            createMomentUseCase: createUseCase,
            permissionService: mockPermissionService,
            mediaRepository: mockMediaRepo,
            locationService: mockLocationService,
            weatherService: mockWeatherService,
            categoryEngine: mockCategoryEngine
        )

        // Step 1: Add media
        let photo = MockMomentFactory.makePhotoMediaItem()
        vm.addMedia(photo)
        vm.text = "Integration test moment"
        vm.addTag("test")

        #expect(vm.canSave == true)

        // Step 2: Save
        await vm.save()

        #expect(vm.isSaved == true)
        #expect(mockMomentRepo.createCallCount == 1)

        // Step 3: Verify saved data
        let savedMoment = mockMomentRepo.lastCreatedMoment!
        #expect(savedMoment.text == "Integration test moment")
        #expect(savedMoment.tags == ["test"])
        #expect(savedMoment.mediaItems.count == 1)

        // Step 4: Load back
        mockMomentRepo.momentsToReturn = [savedMoment]
        let loaded = try await fetchUseCase.execute()

        #expect(loaded.count == 1)
        #expect(loaded.first?.text == "Integration test moment")
        #expect(loaded.first?.tags == ["test"])
    }

    // MARK: - Full Flow: Create → Delete → Verify Removed

    @Test func test_fullFlow_createDeleteVerify() async throws {
        // Setup
        let createUseCase = CreateMomentUseCase(momentRepository: mockMomentRepo)
        let deleteUseCase = DeleteMomentUseCase(
            momentRepository: mockMomentRepo,
            mediaRepository: mockMediaRepo
        )

        // Step 1: Create moment
        let moment = MockMomentFactory.makeFullMoment()
        try await createUseCase.execute(moment)

        #expect(mockMomentRepo.createCallCount == 1)

        // Step 2: Setup for delete - make moment fetchable
        mockMomentRepo.momentToReturn = moment

        // Step 3: Delete
        try await deleteUseCase.execute(momentId: moment.id)

        #expect(mockMomentRepo.fetchByIdCallCount == 1)
        #expect(mockMomentRepo.deleteCallCount == 1)
        #expect(mockMomentRepo.lastDeletedId == moment.id)

        // Step 4: Verify media files cleaned up
        // Full moment has: 2 media items (1 photo + 1 video with thumbnail) + 1 voice note
        #expect(mockMediaRepo.deleteMediaCallCount == 3) // photo + video + thumbnail
        #expect(mockMediaRepo.deleteVoiceNoteCallCount == 1)
    }

    // MARK: - Multiple Moments → Load → Sorted Correctly

    @Test func test_multipleMoments_loadSortedByDate() async throws {
        let fetchUseCase = FetchMomentsUseCase(momentRepository: mockMomentRepo)

        let older = MockMomentFactory.makeMoment(
            createdAt: Date(timeIntervalSince1970: 1_000_000),
            title: "Older"
        )
        let newer = MockMomentFactory.makeMoment(
            createdAt: Date(timeIntervalSince1970: 2_000_000),
            title: "Newer"
        )
        let newest = MockMomentFactory.makeMoment(
            createdAt: Date(timeIntervalSince1970: 3_000_000),
            title: "Newest"
        )

        mockMomentRepo.momentsToReturn = [older, newest, newer] // out of order

        let loaded = try await fetchUseCase.execute()

        #expect(loaded.count == 3)
        #expect(loaded[0].title == "Newest")
        #expect(loaded[1].title == "Newer")
        #expect(loaded[2].title == "Older")
    }

    // MARK: - CategoryEngine Full Pipeline

    @Test func test_categoryEngine_fullPipeline_textAnalysis() async {
        let engine = CategoryEngine()

        let results = await engine.suggest(
            text: "Đi công viên chơi với gia đình",
            voiceTranscript: nil,
            imageData: nil,
            location: nil
        )

        // Should contain "outdoor" (công viên) and "family" (gia đình) and "play" (chơi)
        #expect(!results.isEmpty)
        #expect(results.contains("outdoor"))
        #expect(results.contains("family"))
    }

    @Test func test_categoryEngine_noInput_returnsDaily() async {
        let engine = CategoryEngine()

        let results = await engine.suggest(
            text: nil,
            voiceTranscript: nil,
            imageData: nil,
            location: nil
        )

        #expect(results == ["daily"])
    }

    @Test func test_categoryEngine_emptyText_returnsDaily() async {
        let engine = CategoryEngine()

        let results = await engine.suggest(
            text: "",
            voiceTranscript: nil,
            imageData: nil,
            location: nil
        )

        #expect(results == ["daily"])
    }

    @Test func test_categoryEngine_locationBasedCategory() async {
        let engine = CategoryEngine()
        let location = Location(
            latitude: 10.0,
            longitude: 106.0,
            name: "Central Park",
            placeType: "park"
        )

        let results = await engine.suggest(
            text: nil,
            voiceTranscript: nil,
            imageData: nil,
            location: location
        )

        #expect(results.contains("outdoor"))
    }

    @Test func test_categoryEngine_voiceTranscriptAnalysis() async {
        let engine = CategoryEngine()

        let results = await engine.suggest(
            text: nil,
            voiceTranscript: "Đi khám bệnh viện",
            imageData: nil,
            location: nil
        )

        #expect(results.contains("health"))
    }

    // MARK: - ViewModel Full Flow with Smart Features

    @Test func test_viewModel_fullFlowWithSmartFeatures() async {
        let location = MockMomentFactory.makeLocation()
        let weather = MockMomentFactory.makeWeather()
        mockLocationService.locationToReturn = location
        mockWeatherService.weatherToReturn = weather
        mockCategoryEngine.categoriesToReturn = ["outdoor", "family"]
        let mockCreateUseCase = MockCreateMomentUseCase()

        let vm = CreateMomentViewModel(
            createMomentUseCase: mockCreateUseCase,
            permissionService: mockPermissionService,
            mediaRepository: mockMediaRepo,
            locationService: mockLocationService,
            weatherService: mockWeatherService,
            categoryEngine: mockCategoryEngine
        )

        // Step 1: Load smart features
        await vm.loadSmartFeatures()

        #expect(vm.currentLocation != nil)
        #expect(vm.currentWeather != nil)
        #expect(vm.suggestedCategoryKeys.count == 2)
        #expect(vm.selectedCategoryKeys.count == 2)

        // Step 2: Add media and text
        vm.addMedia(MockMomentFactory.makePhotoMediaItem())
        vm.text = "Family outing"
        vm.addTag("weekend")

        // Step 3: Deselect one category
        vm.toggleCategory("family")
        #expect(!vm.selectedCategoryKeys.contains("family"))

        // Step 4: Save
        await vm.save()

        let saved = mockCreateUseCase.lastExecutedMoment!
        #expect(saved.location == location)
        #expect(saved.weather == weather)
        #expect(saved.categories.map(\.key) == ["outdoor"])
        #expect(saved.text == "Family outing")
        #expect(saved.tags == ["weekend"])
    }

    // MARK: - Timeline ViewModel Full Flow

    @Test func test_timelineViewModel_loadDeleteReload() async {
        let moments = [
            MockMomentFactory.makePhotoMoment(),
            MockMomentFactory.makeVideoMoment(),
            MockMomentFactory.makeVoiceOnlyMoment()
        ]
        let mockFetch = MockFetchMomentsUseCase()
        let mockDelete = MockDeleteMomentUseCase()
        mockFetch.momentsToReturn = moments

        let vm = TimelineViewModel(
            fetchMomentsUseCase: mockFetch,
            deleteMomentUseCase: mockDelete
        )

        // Step 1: Load
        await vm.loadMoments()
        #expect(vm.moments.count == 3)

        // Step 2: Delete one
        await vm.deleteMoment(id: moments[0].id)
        #expect(vm.moments.count == 2)
        #expect(mockDelete.executeCallCount == 1)

        // Step 3: Verify remaining moments
        #expect(!vm.moments.contains(where: { $0.id == moments[0].id }))
        #expect(vm.moments.contains(where: { $0.id == moments[1].id }))
        #expect(vm.moments.contains(where: { $0.id == moments[2].id }))
    }

    // MARK: - Save with Media Files

    @Test func test_viewModel_savePhoto_thenSave_fullFlow() async {
        let mockCreateUseCase = MockCreateMomentUseCase()
        mockMediaRepo.savedFilePath = "Media/photo.jpg"

        let vm = CreateMomentViewModel(
            createMomentUseCase: mockCreateUseCase,
            permissionService: mockPermissionService,
            mediaRepository: mockMediaRepo,
            locationService: mockLocationService,
            weatherService: mockWeatherService,
            categoryEngine: mockCategoryEngine
        )

        // Step 1: Save photo
        await vm.savePhoto(data: Data([0xFF, 0xD8, 0xFF]))

        #expect(vm.capturedMediaItems.count == 1)
        #expect(vm.capturedMediaItems.first?.filePath == "Media/photo.jpg")

        // Step 2: Save moment
        await vm.save()

        #expect(mockCreateUseCase.executeCallCount == 1)
        #expect(mockCreateUseCase.lastExecutedMoment?.mediaItems.count == 1)
    }

    // MARK: - Voice Recording without Transcript (Speech Fail)

    @Test func test_voiceRecording_noTranscript_savesSuccessfully() async {
        let mockCreateUseCase = MockCreateMomentUseCase()
        mockMediaRepo.savedVoicePath = "Voice/note.m4a"

        let vm = CreateMomentViewModel(
            createMomentUseCase: mockCreateUseCase,
            permissionService: mockPermissionService,
            mediaRepository: mockMediaRepo,
            locationService: mockLocationService,
            weatherService: mockWeatherService,
            categoryEngine: mockCategoryEngine
        )

        // Speech failed - no transcript
        await vm.saveVoiceRecording(data: Data([0x01]), duration: 5.0, transcript: nil)

        #expect(vm.voiceNote != nil)
        #expect(vm.voiceNote?.transcript == nil)
        #expect(vm.voiceNote?.duration == 5.0)
        #expect(vm.canSave == true)

        // Should still save successfully
        await vm.save()

        #expect(mockCreateUseCase.executeCallCount == 1)
        #expect(mockCreateUseCase.lastExecutedMoment?.voiceNote?.transcript == nil)
    }
}


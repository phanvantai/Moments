import Testing
import Foundation
@testable import Littlemark

@MainActor
struct CreateMomentViewModelTests {
    let mockUseCase = MockCreateMomentUseCase()
    let mockPermissionService = MockPermissionService()
    let mockMediaRepository = MockMediaRepository()
    let mockLocationService = MockLocationService()
    let mockWeatherService = MockWeatherService()
    let mockCategoryEngine = MockCategoryEngine()
    let videoURL = URL(fileURLWithPath: "/tmp/capture.mov")
    let voiceURL = URL(fileURLWithPath: "/tmp/recording.m4a")

    func makeSUT(initialStep: CreateMomentStep = .camera) -> CreateMomentViewModel {
        CreateMomentViewModel(
            initialStep: initialStep,
            createMomentUseCase: mockUseCase,
            permissionService: mockPermissionService,
            mediaRepository: mockMediaRepository,
            locationService: mockLocationService,
            weatherService: mockWeatherService,
            categoryEngine: mockCategoryEngine
        )
    }

    // MARK: - Initial State

    @Test func test_initial_noMedia_canSaveIsFalse() {
        let vm = makeSUT()

        #expect(vm.capturedMediaItems.isEmpty)
        #expect(vm.canSave == false)
        #expect(vm.text.isEmpty)
        #expect(vm.tags.isEmpty)
    }

    @Test func test_initial_isSavedIsFalse() {
        let vm = makeSUT()

        #expect(vm.isSaved == false)
    }

    @Test func test_initial_isSavingIsFalse() {
        let vm = makeSUT()

        #expect(vm.isSaving == false)
    }

    @Test func test_initial_errorMessageIsNil() {
        let vm = makeSUT()

        #expect(vm.errorMessage == nil)
    }

    @Test func test_initial_voiceNoteIsNil() {
        let vm = makeSUT()

        #expect(vm.voiceNote == nil)
    }

    @Test func test_initial_allPermissionsAvailable() {
        let vm = makeSUT()

        #expect(vm.isCameraAvailable == true)
        #expect(vm.isVoiceAvailable == true)
        #expect(vm.isGalleryAvailable == true)
    }

    // MARK: - Add/Remove Media

    @Test func test_addPhoto_canSaveBecomesTrue() {
        let vm = makeSUT()
        let media = MockMomentFactory.makePhotoMediaItem()

        vm.addMedia(media)

        #expect(vm.capturedMediaItems.count == 1)
        #expect(vm.canSave == true)
    }

    @Test func test_addVoiceNote_canSaveBecomesTrue() {
        let vm = makeSUT()
        let voice = MockMomentFactory.makeVoiceNote()

        vm.setVoiceNote(voice)

        #expect(vm.voiceNote != nil)
        #expect(vm.canSave == true)
    }

    @Test func test_removeLastMedia_canSaveBecomesFalse() async {
        let vm = makeSUT()
        let media = MockMomentFactory.makePhotoMediaItem()
        vm.addMedia(media)

        await vm.removeMedia(media.id)

        #expect(vm.capturedMediaItems.isEmpty)
        #expect(vm.canSave == false)
    }

    @Test func test_removeLastMedia_withVoiceNote_canSaveStaysTrue() async {
        let vm = makeSUT()
        let media = MockMomentFactory.makePhotoMediaItem()
        vm.addMedia(media)
        vm.setVoiceNote(MockMomentFactory.makeVoiceNote())

        await vm.removeMedia(media.id)

        #expect(vm.capturedMediaItems.isEmpty)
        #expect(vm.canSave == true)
    }

    @Test func test_removeVoiceNote_removesNote() async {
        let vm = makeSUT()
        vm.setVoiceNote(MockMomentFactory.makeVoiceNote())

        await vm.removeVoiceNote()

        #expect(vm.voiceNote == nil)
        #expect(vm.canSave == false)
    }

    @Test func test_removeVoiceNote_withMedia_canSaveStaysTrue() async {
        let vm = makeSUT()
        let media = MockMomentFactory.makePhotoMediaItem()
        vm.addMedia(media)
        vm.setVoiceNote(MockMomentFactory.makeVoiceNote())

        await vm.removeVoiceNote()

        #expect(vm.voiceNote == nil)
        #expect(vm.canSave == true)
    }

    @Test func test_removeMedia_nonExistentId_doesNothing() async {
        let vm = makeSUT()
        let media = MockMomentFactory.makePhotoMediaItem()
        vm.addMedia(media)

        await vm.removeMedia(UUID()) // Non-existent ID

        #expect(vm.capturedMediaItems.count == 1)
    }

    // MARK: - Text

    @Test func test_setText_updatesText() {
        let vm = makeSUT()

        vm.text = "Some description"

        #expect(vm.text == "Some description")
        // Text alone should NOT make canSave true
        #expect(vm.canSave == false)
    }

    // MARK: - Tags

    @Test func test_addTag_updatesTagsList() {
        let vm = makeSUT()

        vm.addTag("family")

        #expect(vm.tags == ["family"])
    }

    @Test func test_addDuplicateTag_doesNotAddDuplicate() {
        let vm = makeSUT()
        vm.addTag("family")

        vm.addTag("family")

        #expect(vm.tags == ["family"])
    }

    @Test func test_addMultipleTags_allAdded() {
        let vm = makeSUT()

        vm.addTag("family")
        vm.addTag("outdoor")

        #expect(vm.tags.count == 2)
        #expect(vm.tags.contains("family"))
        #expect(vm.tags.contains("outdoor"))
    }

    @Test func test_removeTag_removesFromList() {
        let vm = makeSUT()
        vm.addTag("family")
        vm.addTag("outdoor")

        vm.removeTag("family")

        #expect(vm.tags == ["outdoor"])
    }

    @Test func test_addTag_emptyString_doesNotAdd() {
        let vm = makeSUT()

        vm.addTag("")

        #expect(vm.tags.isEmpty)
    }

    @Test func test_addTag_whitespaceOnly_doesNotAdd() {
        let vm = makeSUT()

        vm.addTag("   ")

        #expect(vm.tags.isEmpty)
    }

    @Test func test_addTag_trimsWhitespace() {
        let vm = makeSUT()

        vm.addTag("  family  ")

        #expect(vm.tags == ["family"])
    }

    @Test func test_removeTag_nonExistent_doesNothing() {
        let vm = makeSUT()
        vm.addTag("family")

        vm.removeTag("outdoor")

        #expect(vm.tags == ["family"])
    }

    // MARK: - Save

    @Test func test_save_callsUseCaseAndResetsState() async {
        let vm = makeSUT()
        let media = MockMomentFactory.makePhotoMediaItem()
        vm.addMedia(media)
        vm.text = "Test moment"
        vm.addTag("test")

        await vm.save()

        #expect(mockUseCase.executeCallCount == 1)
        // State should be reset after save
        #expect(vm.capturedMediaItems.isEmpty)
        #expect(vm.text.isEmpty)
        #expect(vm.tags.isEmpty)
        #expect(vm.voiceNote == nil)
        #expect(vm.canSave == false)
        #expect(vm.isSaved == true)
    }

    @Test func test_save_withNoMedia_doesNotCallUseCase() async {
        let vm = makeSUT()
        vm.text = "Text only"

        await vm.save()

        #expect(mockUseCase.executeCallCount == 0)
    }

    @Test func test_save_failure_setsErrorMessage() async {
        let vm = makeSUT()
        let media = MockMomentFactory.makePhotoMediaItem()
        vm.addMedia(media)
        mockUseCase.errorToThrow = TestError.saveFailed

        await vm.save()

        #expect(vm.errorMessage != nil)
        // Media should NOT be reset on failure
        #expect(vm.capturedMediaItems.count == 1)
    }

    @Test func test_save_failure_isSavedStaysFalse() async {
        let vm = makeSUT()
        let media = MockMomentFactory.makePhotoMediaItem()
        vm.addMedia(media)
        mockUseCase.errorToThrow = TestError.saveFailed

        await vm.save()

        #expect(vm.isSaved == false)
    }

    @Test func test_save_setsIsSavingDuringExecution() async {
        let vm = makeSUT()
        let media = MockMomentFactory.makePhotoMediaItem()
        vm.addMedia(media)

        await vm.save()

        // After save completes, isSaving should be false
        #expect(vm.isSaving == false)
    }

    @Test func test_save_withVoiceNoteOnly_callsUseCase() async {
        let vm = makeSUT()
        vm.setVoiceNote(MockMomentFactory.makeVoiceNote())

        await vm.save()

        #expect(mockUseCase.executeCallCount == 1)
        #expect(vm.isSaved == true)
    }

    @Test func test_save_passesCorrectMomentData() async {
        let vm = makeSUT()
        let media = MockMomentFactory.makePhotoMediaItem()
        vm.addMedia(media)
        vm.text = "My moment"
        vm.addTag("travel")

        await vm.save()

        let savedMoment = mockUseCase.lastExecutedMoment
        #expect(savedMoment != nil)
        #expect(savedMoment?.text == "My moment")
        #expect(savedMoment?.tags == ["travel"])
        #expect(savedMoment?.mediaItems.count == 1)
    }

    @Test func test_save_emptyText_passesNilText() async {
        let vm = makeSUT()
        let media = MockMomentFactory.makePhotoMediaItem()
        vm.addMedia(media)
        vm.text = ""

        await vm.save()

        let savedMoment = mockUseCase.lastExecutedMoment
        #expect(savedMoment?.text == nil)
    }

    // MARK: - Permissions

    @Test func test_cameraPermissionDenied_cameraOptionHidden() async {
        mockPermissionService.permissionStatuses[.camera] = .denied
        let vm = makeSUT()

        await vm.refreshPermissions()

        #expect(vm.isCameraAvailable == false)
    }

    @Test func test_cameraPermissionAuthorized_cameraOptionVisible() async {
        mockPermissionService.permissionStatuses[.camera] = .authorized
        let vm = makeSUT()

        await vm.refreshPermissions()

        #expect(vm.isCameraAvailable == true)
    }

    @Test func test_microphonePermissionDenied_voiceOptionHidden() async {
        mockPermissionService.permissionStatuses[.microphone] = .denied
        let vm = makeSUT()

        await vm.refreshPermissions()

        #expect(vm.isVoiceAvailable == false)
    }

    @Test func test_photoLibraryPermissionDenied_galleryOptionHidden() async {
        mockPermissionService.permissionStatuses[.photoLibrary] = .denied
        let vm = makeSUT()

        await vm.refreshPermissions()

        #expect(vm.isGalleryAvailable == false)
    }

    @Test func test_allPermissionsNotDetermined_allOptionsAvailable() async {
        // notDetermined should still show options (will prompt on tap)
        let vm = makeSUT()

        await vm.refreshPermissions()

        #expect(vm.isCameraAvailable == true)
        #expect(vm.isVoiceAvailable == true)
        #expect(vm.isGalleryAvailable == true)
    }

    @Test func test_cameraPermissionRestricted_cameraOptionHidden() async {
        mockPermissionService.permissionStatuses[.camera] = .restricted
        let vm = makeSUT()

        await vm.refreshPermissions()

        #expect(vm.isCameraAvailable == false)
    }

    @Test func test_microphonePermissionRestricted_voiceOptionHidden() async {
        mockPermissionService.permissionStatuses[.microphone] = .restricted
        let vm = makeSUT()

        await vm.refreshPermissions()

        #expect(vm.isVoiceAvailable == false)
    }

    @Test func test_photoLibraryPermissionRestricted_galleryOptionHidden() async {
        mockPermissionService.permissionStatuses[.photoLibrary] = .restricted
        let vm = makeSUT()

        await vm.refreshPermissions()

        #expect(vm.isGalleryAvailable == false)
    }

    @Test func test_requestPermission_delegatesToService() async {
        mockPermissionService.requestResults[.camera] = .authorized
        let vm = makeSUT()

        let result = await vm.requestPermission(.camera)

        #expect(result == .authorized)
        #expect(mockPermissionService.requestCallCount == 1)
        #expect(mockPermissionService.lastRequestedPermission == .camera)
    }

    @Test func test_requestPermission_denied_returnsDenied() async {
        mockPermissionService.requestResults[.microphone] = .denied
        let vm = makeSUT()

        let result = await vm.requestPermission(.microphone)

        #expect(result == .denied)
    }

    // MARK: - Reset State

    @Test func test_resetState_clearsAllFields() {
        let vm = makeSUT()
        vm.addMedia(MockMomentFactory.makePhotoMediaItem())
        vm.setVoiceNote(MockMomentFactory.makeVoiceNote())
        vm.text = "Some text"
        vm.addTag("tag1")
        vm.errorMessage = "Some error"
        vm.isSaved = true

        vm.resetState()

        #expect(vm.capturedMediaItems.isEmpty)
        #expect(vm.voiceNote == nil)
        #expect(vm.text.isEmpty)
        #expect(vm.tags.isEmpty)
        #expect(vm.errorMessage == nil)
        #expect(vm.isSaved == false)
    }

    // MARK: - Multiple Media

    @Test func test_addMultipleMedia_allTracked() {
        let vm = makeSUT()
        let photo1 = MockMomentFactory.makePhotoMediaItem()
        let photo2 = MockMomentFactory.makePhotoMediaItem()

        vm.addMedia(photo1)
        vm.addMedia(photo2)

        #expect(vm.capturedMediaItems.count == 2)
        #expect(vm.canSave == true)
    }

    @Test func test_addMixedMedia_photoAndVideo() {
        let vm = makeSUT()
        let photo = MockMomentFactory.makePhotoMediaItem()
        let video = MockMomentFactory.makeVideoMediaItem()

        vm.addMedia(photo)
        vm.addMedia(video)

        #expect(vm.capturedMediaItems.count == 2)
        #expect(vm.capturedMediaItems[0].type == .photo)
        #expect(vm.capturedMediaItems[1].type == .video)
    }

    // MARK: - Media Repository Access

    @Test func test_mediaRepository_isAccessible() {
        let vm = makeSUT()

        #expect(vm.mediaRepository is MockMediaRepository)
    }

    // MARK: - Save Photo

    @Test func test_savePhoto_addsMediaItem() async {
        let vm = makeSUT()
        let data = Data([0x01, 0x02, 0x03])

        await vm.savePhoto(data: data)

        #expect(vm.capturedMediaItems.count == 1)
        #expect(vm.capturedMediaItems.first?.type == .photo)
        #expect(mockMediaRepository.saveMediaCallCount == 1)
    }

    @Test func test_savePhoto_setsFilePath() async {
        mockMediaRepository.savedFilePath = "Media/custom.jpg"
        let vm = makeSUT()

        await vm.savePhoto(data: Data([0x01]))

        #expect(vm.capturedMediaItems.first?.filePath == "Media/custom.jpg")
    }

    @Test func test_savePhoto_failure_setsErrorMessage() async {
        mockMediaRepository.errorToThrow = TestError.saveFailed
        let vm = makeSUT()

        await vm.savePhoto(data: Data([0x01]))

        #expect(vm.capturedMediaItems.isEmpty)
        #expect(vm.errorMessage != nil)
    }

    @Test func test_savePhoto_incrementsSortOrder() async {
        let vm = makeSUT()

        await vm.savePhoto(data: Data([0x01]))
        await vm.savePhoto(data: Data([0x02]))

        #expect(vm.capturedMediaItems.count == 2)
        #expect(vm.capturedMediaItems[0].sortOrder == 0)
        #expect(vm.capturedMediaItems[1].sortOrder == 1)
    }

    // MARK: - Save Video

    @Test func test_saveVideo_importsFileWithoutLoadingData() async {
        let vm = makeSUT()

        await vm.saveVideo(fileURL: videoURL)

        #expect(vm.capturedMediaItems.count == 1)
        #expect(vm.capturedMediaItems.first?.type == .video)
        #expect(mockMediaRepository.importMediaCallCount == 1)
        #expect(mockMediaRepository.lastImportedMediaURL == videoURL)
        #expect(mockMediaRepository.lastImportedMediaFileName?.hasSuffix(".mov") == true)
        #expect(mockMediaRepository.saveMediaCallCount == 0)
    }

    @Test func test_saveVideo_generatesThumbnail() async {
        mockMediaRepository.thumbnailPath = "Thumbnails/thumb.jpg"
        let vm = makeSUT()

        await vm.saveVideo(fileURL: videoURL)

        #expect(vm.capturedMediaItems.first?.thumbnailPath == "Thumbnails/thumb.jpg")
        #expect(mockMediaRepository.generateVideoThumbnailCallCount == 1)
    }

    @Test func test_saveVideo_failure_setsErrorMessage() async {
        mockMediaRepository.errorToThrow = TestError.saveFailed
        let vm = makeSUT()

        await vm.saveVideo(fileURL: videoURL)

        #expect(vm.capturedMediaItems.isEmpty)
        #expect(vm.errorMessage != nil)
    }

    // MARK: - Save Voice Recording

    @Test func test_saveVoiceRecording_setsVoiceNote() async {
        let vm = makeSUT()

        await vm.saveVoiceRecording(fileURL: voiceURL, duration: 10.0, transcript: "Hello")

        #expect(vm.voiceNote != nil)
        #expect(vm.voiceNote?.duration == 10.0)
        #expect(vm.voiceNote?.transcript == "Hello")
        #expect(mockMediaRepository.importVoiceNoteCallCount == 1)
        #expect(mockMediaRepository.lastImportedVoiceURL == voiceURL)
    }

    @Test func test_saveVoiceRecording_withNilTranscript() async {
        let vm = makeSUT()

        await vm.saveVoiceRecording(fileURL: voiceURL, duration: 5.0, transcript: nil)

        #expect(vm.voiceNote?.transcript == nil)
        #expect(vm.voiceNote?.duration == 5.0)
    }

    @Test func test_saveVoiceRecording_failure_setsErrorMessage() async {
        mockMediaRepository.errorToThrow = TestError.saveFailed
        let vm = makeSUT()

        await vm.saveVoiceRecording(fileURL: voiceURL, duration: 10.0, transcript: nil)

        #expect(vm.voiceNote == nil)
        #expect(vm.errorMessage != nil)
    }

    @Test func test_saveVoiceRecording_setsFilePath() async {
        mockMediaRepository.savedVoicePath = "Voice/custom.m4a"
        let vm = makeSUT()

        await vm.saveVoiceRecording(fileURL: voiceURL, duration: 5.0, transcript: nil)

        #expect(vm.voiceNote?.filePath == "Voice/custom.m4a")
    }

    @Test func test_saveVoiceRecording_replacingExistingNote_deletesOldFile() async {
        let vm = makeSUT()
        vm.setVoiceNote(MockMomentFactory.makeVoiceNote())

        await vm.saveVoiceRecording(fileURL: voiceURL, duration: 5.0, transcript: nil)

        #expect(mockMediaRepository.deletedVoicePaths == ["Voice/note.m4a"])
    }

    // MARK: - Mixed Media

    @Test func test_savePhoto_doesNotGenerateThumbnail() async {
        let vm = makeSUT()

        await vm.savePhoto(data: Data([0x01]))

        #expect(vm.capturedMediaItems.first?.thumbnailPath == nil)
        #expect(mockMediaRepository.generateVideoThumbnailCallCount == 0)
    }

    @Test func test_mixedMedia_keepsOrderAndSortOrder() async {
        let vm = makeSUT()

        await vm.savePhoto(data: Data([0x01]))
        await vm.saveVideo(fileURL: videoURL)
        await vm.savePhoto(data: Data([0x03]))

        #expect(vm.capturedMediaItems.map(\.type) == [.photo, .video, .photo])
        #expect(vm.capturedMediaItems.map(\.sortOrder) == [0, 1, 2])
    }

    // MARK: - Removing Media Deletes Files

    @Test func test_removeMedia_deletesFile() async {
        let vm = makeSUT()
        let photo = MockMomentFactory.makePhotoMediaItem()
        vm.addMedia(photo)

        await vm.removeMedia(photo.id)

        #expect(mockMediaRepository.deletedMediaPaths == [photo.filePath])
    }

    @Test func test_removeMedia_video_deletesFileAndThumbnail() async {
        let vm = makeSUT()
        let video = MockMomentFactory.makeVideoMediaItem()
        vm.addMedia(video)

        await vm.removeMedia(video.id)

        #expect(mockMediaRepository.deletedMediaPaths == [video.filePath, video.thumbnailPath!])
    }

    @Test func test_removeMedia_deleteFails_stillRemovesItem() async {
        let vm = makeSUT()
        let photo = MockMomentFactory.makePhotoMediaItem()
        vm.addMedia(photo)
        mockMediaRepository.errorToThrow = TestError.saveFailed

        await vm.removeMedia(photo.id)

        #expect(vm.capturedMediaItems.isEmpty)
    }

    @Test func test_removeVoiceNote_deletesFile() async {
        let vm = makeSUT()
        vm.setVoiceNote(MockMomentFactory.makeVoiceNote())

        await vm.removeVoiceNote()

        #expect(mockMediaRepository.deletedVoicePaths == ["Voice/note.m4a"])
    }

    // MARK: - Discard Draft

    @Test func test_discardDraft_deletesAllCapturedFilesAndResets() async {
        let vm = makeSUT()
        let photo = MockMomentFactory.makePhotoMediaItem()
        let video = MockMomentFactory.makeVideoMediaItem()
        vm.addMedia(photo)
        vm.addMedia(video)
        vm.setVoiceNote(MockMomentFactory.makeVoiceNote())
        vm.text = "Draft"

        await vm.discardDraft()

        #expect(mockMediaRepository.deletedMediaPaths == [photo.filePath, video.filePath, video.thumbnailPath!])
        #expect(mockMediaRepository.deletedVoicePaths == ["Voice/note.m4a"])
        #expect(vm.capturedMediaItems.isEmpty)
        #expect(vm.voiceNote == nil)
        #expect(vm.text.isEmpty)
    }

    @Test func test_discardDraft_emptyDraft_deletesNothing() async {
        let vm = makeSUT()

        await vm.discardDraft()

        #expect(mockMediaRepository.deleteMediaCallCount == 0)
        #expect(mockMediaRepository.deleteVoiceNoteCallCount == 0)
    }

    @Test func test_discardDraft_afterSave_keepsSavedFiles() async {
        let vm = makeSUT()
        vm.addMedia(MockMomentFactory.makePhotoMediaItem())
        await vm.save()

        await vm.discardDraft()

        #expect(mockMediaRepository.deleteMediaCallCount == 0)
    }

    // MARK: - Smart Features: Load

    @Test func test_loadSmartFeatures_requestsLocationPermission_whenNotDetermined() async {
        mockLocationService.locationToReturn = MockMomentFactory.makeLocation()
        let vm = makeSUT()

        await vm.loadSmartFeatures()

        #expect(mockPermissionService.lastRequestedPermission == .location)
        #expect(mockLocationService.getCurrentLocationCallCount == 1)
        #expect(vm.currentLocation != nil)
    }

    @Test func test_loadSmartFeatures_skipsPermissionRequest_whenAlreadyAuthorized() async {
        mockPermissionService.permissionStatuses[.location] = .authorized
        mockLocationService.locationToReturn = MockMomentFactory.makeLocation()
        let vm = makeSUT()
        let initialRequestCount = mockPermissionService.requestCallCount

        await vm.loadSmartFeatures()

        // Should NOT have called request since already authorized
        #expect(mockPermissionService.requestCallCount == initialRequestCount)
        #expect(mockLocationService.getCurrentLocationCallCount == 1)
        #expect(vm.currentLocation != nil)
    }

    @Test func test_loadSmartFeatures_skipsPermissionRequest_whenDenied() async {
        mockPermissionService.permissionStatuses[.location] = .denied
        mockLocationService.locationToReturn = nil
        let vm = makeSUT()
        let initialRequestCount = mockPermissionService.requestCallCount

        await vm.loadSmartFeatures()

        // Should NOT have called request since already denied
        #expect(mockPermissionService.requestCallCount == initialRequestCount)
        #expect(mockLocationService.getCurrentLocationCallCount == 1)
    }

    @Test func test_loadSmartFeatures_callsLocationService() async {
        mockLocationService.locationToReturn = MockMomentFactory.makeLocation()
        let vm = makeSUT()

        await vm.loadSmartFeatures()

        #expect(mockLocationService.getCurrentLocationCallCount == 1)
        #expect(vm.currentLocation != nil)
    }

    @Test func test_loadSmartFeatures_callsWeatherService_whenLocationAvailable() async {
        let location = MockMomentFactory.makeLocation()
        mockLocationService.locationToReturn = location
        mockWeatherService.weatherToReturn = MockMomentFactory.makeWeather()
        let vm = makeSUT()

        await vm.loadSmartFeatures()

        #expect(mockWeatherService.fetchWeatherCallCount == 1)
        #expect(mockWeatherService.lastLatitude == location.latitude)
        #expect(mockWeatherService.lastLongitude == location.longitude)
        #expect(vm.currentWeather != nil)
    }

    @Test func test_loadSmartFeatures_withWeather_loadsAttribution() async {
        mockLocationService.locationToReturn = MockMomentFactory.makeLocation()
        mockWeatherService.weatherToReturn = MockMomentFactory.makeWeather()
        let vm = makeSUT()

        await vm.loadSmartFeatures()

        #expect(vm.weatherAttribution == mockWeatherService.attributionToReturn)
    }

    @Test func test_loadSmartFeatures_noWeather_doesNotLoadAttribution() async {
        mockLocationService.locationToReturn = MockMomentFactory.makeLocation()
        mockWeatherService.weatherToReturn = nil
        let vm = makeSUT()

        await vm.loadSmartFeatures()

        #expect(vm.weatherAttribution == nil)
        #expect(mockWeatherService.fetchAttributionCallCount == 0)
    }

    @Test func test_loadSmartFeatures_skipsWeather_whenNoLocation() async {
        mockLocationService.locationToReturn = nil
        let vm = makeSUT()

        await vm.loadSmartFeatures()

        #expect(mockWeatherService.fetchWeatherCallCount == 0)
        #expect(vm.currentWeather == nil)
    }

    @Test func test_loadSmartFeatures_callsCategoryEngine() async {
        mockCategoryEngine.categoriesToReturn = ["outdoor", "food"]
        let vm = makeSUT()

        await vm.loadSmartFeatures()

        #expect(mockCategoryEngine.suggestCallCount == 1)
        #expect(vm.suggestedCategoryKeys == ["outdoor", "food"])
        #expect(vm.selectedCategoryKeys == Set(["outdoor", "food"]))
    }

    // MARK: - Smart Features: Location Denied

    @Test func test_save_locationDenied_savedWithoutLocation() async {
        mockLocationService.locationToReturn = nil
        mockCategoryEngine.categoriesToReturn = ["daily"]
        let vm = makeSUT()
        vm.addMedia(MockMomentFactory.makePhotoMediaItem())
        await vm.loadSmartFeatures()

        await vm.save()

        let savedMoment = mockUseCase.lastExecutedMoment
        #expect(savedMoment?.location == nil)
    }

    // MARK: - Smart Features: Weather Fail

    @Test func test_save_weatherFail_savedWithoutWeather() async {
        mockLocationService.locationToReturn = MockMomentFactory.makeLocation()
        mockWeatherService.weatherToReturn = nil
        mockCategoryEngine.categoriesToReturn = ["daily"]
        let vm = makeSUT()
        vm.addMedia(MockMomentFactory.makePhotoMediaItem())
        await vm.loadSmartFeatures()

        await vm.save()

        let savedMoment = mockUseCase.lastExecutedMoment
        #expect(savedMoment?.weather == nil)
    }

    // MARK: - Smart Features: Toggle Category

    @Test func test_toggleCategory_off_removesFromSelected() async {
        mockCategoryEngine.categoriesToReturn = ["outdoor", "food"]
        let vm = makeSUT()
        await vm.loadSmartFeatures()

        vm.toggleCategory("outdoor")

        #expect(!vm.selectedCategoryKeys.contains("outdoor"))
        #expect(vm.selectedCategoryKeys.contains("food"))
    }

    @Test func test_toggleCategory_on_addsToSelected() async {
        mockCategoryEngine.categoriesToReturn = ["outdoor", "food"]
        let vm = makeSUT()
        await vm.loadSmartFeatures()

        // Toggle off then on
        vm.toggleCategory("outdoor")
        vm.toggleCategory("outdoor")

        #expect(vm.selectedCategoryKeys.contains("outdoor"))
    }

    @Test func test_save_selectedCategories_savedInMoment() async {
        mockCategoryEngine.categoriesToReturn = ["outdoor", "food"]
        let vm = makeSUT()
        vm.addMedia(MockMomentFactory.makePhotoMediaItem())
        await vm.loadSmartFeatures()

        // Deselect "food"
        vm.toggleCategory("food")

        await vm.save()

        let savedMoment = mockUseCase.lastExecutedMoment
        let categoryKeys = savedMoment?.categories.map(\.key) ?? []
        #expect(categoryKeys.contains("outdoor"))
        #expect(!categoryKeys.contains("food"))
    }

    // MARK: - Smart Features: Disable Location

    @Test func test_disableLocation_clearsLocationAndWeather() async {
        mockLocationService.locationToReturn = MockMomentFactory.makeLocation()
        mockWeatherService.weatherToReturn = MockMomentFactory.makeWeather()
        let vm = makeSUT()
        await vm.loadSmartFeatures()

        vm.disableLocation()

        #expect(vm.currentLocation == nil)
        #expect(vm.currentWeather == nil)
        #expect(vm.isLocationEnabled == false)
    }

    @Test func test_save_locationDisabled_savedWithoutLocation() async {
        mockLocationService.locationToReturn = MockMomentFactory.makeLocation()
        mockWeatherService.weatherToReturn = MockMomentFactory.makeWeather()
        mockCategoryEngine.categoriesToReturn = ["daily"]
        let vm = makeSUT()
        vm.addMedia(MockMomentFactory.makePhotoMediaItem())
        await vm.loadSmartFeatures()
        vm.disableLocation()

        await vm.save()

        let savedMoment = mockUseCase.lastExecutedMoment
        #expect(savedMoment?.location == nil)
    }

    // MARK: - Smart Features: Reset

    @Test func test_resetState_clearsSmartFeatures() async {
        mockLocationService.locationToReturn = MockMomentFactory.makeLocation()
        mockWeatherService.weatherToReturn = MockMomentFactory.makeWeather()
        mockCategoryEngine.categoriesToReturn = ["outdoor"]
        let vm = makeSUT()
        await vm.loadSmartFeatures()

        vm.resetState()

        #expect(vm.currentLocation == nil)
        #expect(vm.currentWeather == nil)
        #expect(vm.suggestedCategoryKeys.isEmpty)
        #expect(vm.selectedCategoryKeys.isEmpty)
        #expect(vm.isLocationEnabled == true)
    }

    // MARK: - Smart Features: Initial State

    @Test func test_initial_smartFeaturesEmpty() {
        let vm = makeSUT()

        #expect(vm.currentLocation == nil)
        #expect(vm.currentWeather == nil)
        #expect(vm.suggestedCategoryKeys.isEmpty)
        #expect(vm.selectedCategoryKeys.isEmpty)
        #expect(vm.isLocationEnabled == true)
        #expect(vm.isLoadingSmartFeatures == false)
    }

    @Test func test_save_passesLocationWeatherCategories() async {
        let location = MockMomentFactory.makeLocation()
        let weather = MockMomentFactory.makeWeather()
        mockLocationService.locationToReturn = location
        mockWeatherService.weatherToReturn = weather
        mockCategoryEngine.categoriesToReturn = ["outdoor"]
        let vm = makeSUT()
        vm.addMedia(MockMomentFactory.makePhotoMediaItem())
        await vm.loadSmartFeatures()

        await vm.save()

        let savedMoment = mockUseCase.lastExecutedMoment
        #expect(savedMoment?.location == location)
        #expect(savedMoment?.weather == weather)
        #expect(savedMoment?.categories.map(\.key) == ["outdoor"])
    }

    // MARK: - Date Editing

    @Test func test_initial_selectedDate_isApproximatelyNow() {
        let vm = makeSUT()
        let now = Date()

        #expect(abs(vm.selectedDate.timeIntervalSince(now)) < 5)
    }

    @Test func test_updateDate_updatesSelectedDate() async {
        let vm = makeSUT()
        let pastDate = Date(timeIntervalSince1970: 1_700_000_000)

        await vm.updateDate(pastDate)

        #expect(vm.selectedDate == pastDate)
    }

    @Test func test_updateDate_refetchesWeather_whenLocationExists() async {
        let location = MockMomentFactory.makeLocation()
        let weather = MockMomentFactory.makeWeather()
        mockLocationService.locationToReturn = location
        mockWeatherService.weatherToReturn = weather
        let vm = makeSUT()
        await vm.loadSmartFeatures()
        let initialCallCount = mockWeatherService.fetchWeatherCallCount

        let pastDate = Date(timeIntervalSince1970: 1_700_000_000)
        await vm.updateDate(pastDate)

        #expect(mockWeatherService.fetchWeatherCallCount > initialCallCount)
        #expect(mockWeatherService.lastDate == pastDate)
    }

    @Test func test_updateDate_noLocation_doesNotFetchWeather() async {
        mockLocationService.locationToReturn = nil
        let vm = makeSUT()
        await vm.loadSmartFeatures()
        let initialCallCount = mockWeatherService.fetchWeatherCallCount

        await vm.updateDate(Date())

        #expect(mockWeatherService.fetchWeatherCallCount == initialCallCount)
    }

    @Test func test_save_usesSelectedDate_asCreatedAt() async {
        let vm = makeSUT()
        vm.addMedia(MockMomentFactory.makePhotoMediaItem())
        let customDate = Date(timeIntervalSince1970: 1_600_000_000)
        await vm.updateDate(customDate)

        await vm.save()

        let savedMoment = mockUseCase.lastExecutedMoment
        #expect(savedMoment?.createdAt == customDate)
    }

    @Test func test_save_defaultDate_isApproximatelyNow() async {
        let vm = makeSUT()
        vm.addMedia(MockMomentFactory.makePhotoMediaItem())
        let now = Date()

        await vm.save()

        let savedMoment = mockUseCase.lastExecutedMoment
        #expect(savedMoment != nil)
        #expect(abs(savedMoment!.createdAt.timeIntervalSince(now)) < 5)
    }

    @Test func test_resetState_resetsSelectedDate() async {
        let vm = makeSUT()
        await vm.updateDate(Date(timeIntervalSince1970: 1_600_000_000))

        vm.resetState()

        let now = Date()
        #expect(abs(vm.selectedDate.timeIntervalSince(now)) < 5)
    }

    // MARK: - Location Editing

    @Test func test_updateLocation_setsNewLocation() async {
        let vm = makeSUT()
        let newLocation = Location(latitude: 35.6762, longitude: 139.6503, name: "Tokyo")

        await vm.updateLocation(newLocation)

        #expect(vm.currentLocation == newLocation)
        #expect(vm.isLocationEnabled == true)
    }

    @Test func test_updateLocation_reEnablesLocation() async {
        let vm = makeSUT()
        vm.disableLocation()
        #expect(vm.isLocationEnabled == false)

        let newLocation = MockMomentFactory.makeLocation()
        await vm.updateLocation(newLocation)

        #expect(vm.isLocationEnabled == true)
        #expect(vm.currentLocation == newLocation)
    }

    @Test func test_updateLocation_refetchesWeather() async {
        mockWeatherService.weatherToReturn = MockMomentFactory.makeWeather()
        let vm = makeSUT()
        let newLocation = Location(latitude: 35.6762, longitude: 139.6503, name: "Tokyo")

        await vm.updateLocation(newLocation)

        #expect(mockWeatherService.fetchWeatherCallCount == 1)
        #expect(mockWeatherService.lastLatitude == 35.6762)
        #expect(mockWeatherService.lastLongitude == 139.6503)
    }

    @Test func test_updateLocation_refreshesCategories() async {
        mockCategoryEngine.categoriesToReturn = ["travel"]
        let vm = makeSUT()
        let newLocation = Location(latitude: 35.6762, longitude: 139.6503, name: "Tokyo")

        await vm.updateLocation(newLocation)

        #expect(mockCategoryEngine.suggestCallCount == 1)
    }

    @Test func test_updateLocation_clearsOldWeather_beforeRefetch() async {
        let location = MockMomentFactory.makeLocation()
        let weather = MockMomentFactory.makeWeather()
        mockLocationService.locationToReturn = location
        mockWeatherService.weatherToReturn = weather
        let vm = makeSUT()
        await vm.loadSmartFeatures()
        #expect(vm.currentWeather != nil)

        // Set weatherToReturn to nil to simulate fetch returning nil
        mockWeatherService.weatherToReturn = nil
        let newLocation = Location(latitude: 0, longitude: 0, name: "Null Island")
        await vm.updateLocation(newLocation)

        // Old weather should be cleared even though new fetch returned nil
        #expect(vm.currentWeather == nil)
    }

    @Test func test_save_afterUpdateLocation_passesNewLocation() async {
        mockWeatherService.weatherToReturn = MockMomentFactory.makeWeather()
        let vm = makeSUT()
        vm.addMedia(MockMomentFactory.makePhotoMediaItem())
        let newLocation = Location(latitude: 48.8566, longitude: 2.3522, name: "Paris")
        await vm.updateLocation(newLocation)

        await vm.save()

        let savedMoment = mockUseCase.lastExecutedMoment
        #expect(savedMoment?.location == newLocation)
    }
}

private enum TestError: Error {
    case saveFailed
}

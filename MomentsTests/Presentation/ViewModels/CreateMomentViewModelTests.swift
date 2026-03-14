import Testing
import Foundation
@testable import Moments

@MainActor
struct CreateMomentViewModelTests {
    let mockUseCase = MockCreateMomentUseCase()
    let mockPermissionService = MockPermissionService()
    let mockMediaRepository = MockMediaRepository()
    let mockLocationService = MockLocationService()
    let mockWeatherService = MockWeatherService()
    let mockCategoryEngine = MockCategoryEngine()

    func makeSUT() -> CreateMomentViewModel {
        CreateMomentViewModel(
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

    @Test func test_removeLastMedia_canSaveBecomesFalse() {
        let vm = makeSUT()
        let media = MockMomentFactory.makePhotoMediaItem()
        vm.addMedia(media)

        vm.removeMedia(media.id)

        #expect(vm.capturedMediaItems.isEmpty)
        #expect(vm.canSave == false)
    }

    @Test func test_removeLastMedia_withVoiceNote_canSaveStaysTrue() {
        let vm = makeSUT()
        let media = MockMomentFactory.makePhotoMediaItem()
        vm.addMedia(media)
        vm.setVoiceNote(MockMomentFactory.makeVoiceNote())

        vm.removeMedia(media.id)

        #expect(vm.capturedMediaItems.isEmpty)
        #expect(vm.canSave == true)
    }

    @Test func test_removeVoiceNote_removesNote() {
        let vm = makeSUT()
        vm.setVoiceNote(MockMomentFactory.makeVoiceNote())

        vm.removeVoiceNote()

        #expect(vm.voiceNote == nil)
        #expect(vm.canSave == false)
    }

    @Test func test_removeVoiceNote_withMedia_canSaveStaysTrue() {
        let vm = makeSUT()
        let media = MockMomentFactory.makePhotoMediaItem()
        vm.addMedia(media)
        vm.setVoiceNote(MockMomentFactory.makeVoiceNote())

        vm.removeVoiceNote()

        #expect(vm.voiceNote == nil)
        #expect(vm.canSave == true)
    }

    @Test func test_removeMedia_nonExistentId_doesNothing() {
        let vm = makeSUT()
        let media = MockMomentFactory.makePhotoMediaItem()
        vm.addMedia(media)

        vm.removeMedia(UUID()) // Non-existent ID

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

    @Test func test_saveVideo_addsVideoMediaItem() async {
        let vm = makeSUT()
        let data = Data([0x01, 0x02])

        await vm.saveVideo(data: data)

        #expect(vm.capturedMediaItems.count == 1)
        #expect(vm.capturedMediaItems.first?.type == .video)
        #expect(mockMediaRepository.saveMediaCallCount == 1)
    }

    @Test func test_saveVideo_generatesThumbnail() async {
        mockMediaRepository.thumbnailPath = "Thumbnails/thumb.jpg"
        let vm = makeSUT()

        await vm.saveVideo(data: Data([0x01]))

        #expect(vm.capturedMediaItems.first?.thumbnailPath == "Thumbnails/thumb.jpg")
        #expect(mockMediaRepository.generateVideoThumbnailCallCount == 1)
    }

    @Test func test_saveVideo_failure_setsErrorMessage() async {
        mockMediaRepository.errorToThrow = TestError.saveFailed
        let vm = makeSUT()

        await vm.saveVideo(data: Data([0x01]))

        #expect(vm.capturedMediaItems.isEmpty)
        #expect(vm.errorMessage != nil)
    }

    // MARK: - Save Voice Recording

    @Test func test_saveVoiceRecording_setsVoiceNote() async {
        let vm = makeSUT()
        let data = Data([0x01, 0x02])

        await vm.saveVoiceRecording(data: data, duration: 10.0, transcript: "Hello")

        #expect(vm.voiceNote != nil)
        #expect(vm.voiceNote?.duration == 10.0)
        #expect(vm.voiceNote?.transcript == "Hello")
        #expect(mockMediaRepository.saveVoiceNoteCallCount == 1)
    }

    @Test func test_saveVoiceRecording_withNilTranscript() async {
        let vm = makeSUT()

        await vm.saveVoiceRecording(data: Data([0x01]), duration: 5.0, transcript: nil)

        #expect(vm.voiceNote?.transcript == nil)
        #expect(vm.voiceNote?.duration == 5.0)
    }

    @Test func test_saveVoiceRecording_failure_setsErrorMessage() async {
        mockMediaRepository.errorToThrow = TestError.saveFailed
        let vm = makeSUT()

        await vm.saveVoiceRecording(data: Data([0x01]), duration: 10.0, transcript: nil)

        #expect(vm.voiceNote == nil)
        #expect(vm.errorMessage != nil)
    }

    @Test func test_saveVoiceRecording_setsFilePath() async {
        mockMediaRepository.savedVoicePath = "Voice/custom.m4a"
        let vm = makeSUT()

        await vm.saveVoiceRecording(data: Data([0x01]), duration: 5.0, transcript: nil)

        #expect(vm.voiceNote?.filePath == "Voice/custom.m4a")
    }

    // MARK: - Save Gallery Item

    @Test func test_saveGalleryItem_photo_addsPhotoItem() async {
        let vm = makeSUT()

        await vm.saveGalleryItem(data: Data([0x01]), isVideo: false)

        #expect(vm.capturedMediaItems.count == 1)
        #expect(vm.capturedMediaItems.first?.type == .photo)
    }

    @Test func test_saveGalleryItem_video_addsVideoItem() async {
        let vm = makeSUT()

        await vm.saveGalleryItem(data: Data([0x01]), isVideo: true)

        #expect(vm.capturedMediaItems.count == 1)
        #expect(vm.capturedMediaItems.first?.type == .video)
    }

    @Test func test_saveGalleryItem_failure_setsErrorMessage() async {
        mockMediaRepository.errorToThrow = TestError.saveFailed
        let vm = makeSUT()

        await vm.saveGalleryItem(data: Data([0x01]), isVideo: false)

        #expect(vm.capturedMediaItems.isEmpty)
        #expect(vm.errorMessage != nil)
    }

    @Test func test_saveGalleryItem_multipleItems() async {
        let vm = makeSUT()

        await vm.saveGalleryItem(data: Data([0x01]), isVideo: false)
        await vm.saveGalleryItem(data: Data([0x02]), isVideo: true)
        await vm.saveGalleryItem(data: Data([0x03]), isVideo: false)

        #expect(vm.capturedMediaItems.count == 3)
        #expect(vm.capturedMediaItems[0].type == .photo)
        #expect(vm.capturedMediaItems[1].type == .video)
        #expect(vm.capturedMediaItems[2].type == .photo)
    }

    @Test func test_saveGalleryItem_incrementsSortOrder() async {
        let vm = makeSUT()

        await vm.saveGalleryItem(data: Data([0x01]), isVideo: false)
        await vm.saveGalleryItem(data: Data([0x02]), isVideo: true)

        #expect(vm.capturedMediaItems[0].sortOrder == 0)
        #expect(vm.capturedMediaItems[1].sortOrder == 1)
    }

    // MARK: - Smart Features: Load

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
}

private enum TestError: Error {
    case saveFailed
}

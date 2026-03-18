import Testing
import SwiftUI
import Foundation
@testable import Moments

struct ReviewMomentViewTests {

    // MARK: - FlowLayout

    @Test func test_flowLayout_defaultSpacing_isEight() {
        let layout = FlowLayout()

        #expect(layout.spacing == 8)
    }

    @Test func test_flowLayout_customSpacing_isSet() {
        let layout = FlowLayout(spacing: 12)

        #expect(layout.spacing == 12)
    }

    // MARK: - View Construction

    @MainActor
    @Test func test_reviewMomentView_canBeConstructed() {
        let mockUseCase = MockCreateMomentUseCase()
        let mockPermissionService = MockPermissionService()
        let mockMediaRepo = MockMediaRepository()
        let vm = CreateMomentViewModel(
            createMomentUseCase: mockUseCase,
            permissionService: mockPermissionService,
            mediaRepository: mockMediaRepo,
            locationService: MockLocationService(),
            weatherService: MockWeatherService(),
            categoryEngine: MockCategoryEngine()
        )

        let view = ReviewMomentView(
            viewModel: vm,
            onDismiss: {}
        )

        #expect(view.viewModel === vm)
    }

    // MARK: - Duration Formatting (tested via ViewModel interaction)

    @MainActor
    @Test func test_viewModel_withVoiceNote_showsDuration() {
        let mockUseCase = MockCreateMomentUseCase()
        let mockPermissionService = MockPermissionService()
        let mockMediaRepo = MockMediaRepository()
        let vm = CreateMomentViewModel(
            createMomentUseCase: mockUseCase,
            permissionService: mockPermissionService,
            mediaRepository: mockMediaRepo,
            locationService: MockLocationService(),
            weatherService: MockWeatherService(),
            categoryEngine: MockCategoryEngine()
        )

        let voiceNote = VoiceNote(filePath: "test.m4a", duration: 125, transcript: "Hello world")
        vm.setVoiceNote(voiceNote)

        #expect(vm.voiceNote != nil)
        #expect(vm.voiceNote?.duration == 125)
        #expect(vm.voiceNote?.transcript == "Hello world")
    }
}

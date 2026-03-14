import Testing
import Foundation
@testable import Moments

struct CreateMomentViewTests {

    // MARK: - CreateMomentStep enum

    @Test func test_step_captureMenu_isDefault() {
        let step: CreateMomentStep = .captureMenu

        #expect(step == .captureMenu)
    }

    @Test func test_step_allCasesExist() {
        let steps: [CreateMomentStep] = [.captureMenu, .camera, .voice, .gallery, .review]

        #expect(steps.count == 5)
    }

    @Test func test_step_camera_notEqualToVoice() {
        #expect(CreateMomentStep.camera != CreateMomentStep.voice)
    }

    @Test func test_step_gallery_notEqualToReview() {
        #expect(CreateMomentStep.gallery != CreateMomentStep.review)
    }

    @Test func test_step_captureMenu_notEqualToCamera() {
        #expect(CreateMomentStep.captureMenu != CreateMomentStep.camera)
    }

    @Test func test_step_voice_notEqualToGallery() {
        #expect(CreateMomentStep.voice != CreateMomentStep.gallery)
    }

    @Test func test_step_review_notEqualToCaptureMenu() {
        #expect(CreateMomentStep.review != CreateMomentStep.captureMenu)
    }

    @Test func test_step_equatable_sameValues() {
        #expect(CreateMomentStep.camera == CreateMomentStep.camera)
        #expect(CreateMomentStep.voice == CreateMomentStep.voice)
        #expect(CreateMomentStep.gallery == CreateMomentStep.gallery)
        #expect(CreateMomentStep.review == CreateMomentStep.review)
        #expect(CreateMomentStep.captureMenu == CreateMomentStep.captureMenu)
    }

    // MARK: - GalleryMediaResult

    @Test func test_galleryMediaResult_photo_hasCorrectType() {
        let data = Data([0x01, 0x02, 0x03])
        let result = GalleryMediaResult(data: data, type: .photo)

        #expect(result.type == .photo)
        #expect(result.data == data)
    }

    @Test func test_galleryMediaResult_video_hasCorrectType() {
        let data = Data([0x01, 0x02, 0x03])
        let result = GalleryMediaResult(data: data, type: .video)

        #expect(result.type == .video)
    }

    @Test func test_galleryMediaResult_emptyData_isValid() {
        let result = GalleryMediaResult(data: Data(), type: .photo)

        #expect(result.data.isEmpty)
    }

    @Test func test_galleryMediaResult_largeData() {
        let data = Data(repeating: 0xFF, count: 1024 * 1024)
        let result = GalleryMediaResult(data: data, type: .video)

        #expect(result.data.count == 1024 * 1024)
        #expect(result.type == .video)
    }
}

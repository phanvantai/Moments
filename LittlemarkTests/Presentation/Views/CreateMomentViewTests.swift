import Testing
import Foundation
@testable import Littlemark

struct CreateMomentViewTests {

    // MARK: - CreateMomentStep enum

    @Test func test_step_allCasesExist() {
        let steps: [CreateMomentStep] = [.camera, .voice, .gallery, .review]

        #expect(steps.count == 4)
    }

    @Test func test_step_camera_notEqualToVoice() {
        #expect(CreateMomentStep.camera != CreateMomentStep.voice)
    }

    @Test func test_step_gallery_notEqualToReview() {
        #expect(CreateMomentStep.gallery != CreateMomentStep.review)
    }

    @Test func test_step_voice_notEqualToGallery() {
        #expect(CreateMomentStep.voice != CreateMomentStep.gallery)
    }

    @Test func test_step_review_notEqualToCamera() {
        #expect(CreateMomentStep.review != CreateMomentStep.camera)
    }

    @Test func test_step_equatable_sameValues() {
        #expect(CreateMomentStep.camera == CreateMomentStep.camera)
        #expect(CreateMomentStep.voice == CreateMomentStep.voice)
        #expect(CreateMomentStep.gallery == CreateMomentStep.gallery)
        #expect(CreateMomentStep.review == CreateMomentStep.review)
    }
}

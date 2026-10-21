import Testing
import Foundation
@testable import Littlemark

struct CreateMomentStepTests {

    @Test func test_camera_equatable() {
        let step1 = CreateMomentStep.camera
        let step2 = CreateMomentStep.camera

        #expect(step1 == step2)
    }

    @Test func test_voice_equatable() {
        let step = CreateMomentStep.voice

        #expect(step == .voice)
    }

    @Test func test_gallery_equatable() {
        let step = CreateMomentStep.gallery

        #expect(step == .gallery)
    }

    @Test func test_review_equatable() {
        let step = CreateMomentStep.review

        #expect(step == .review)
    }

    @Test func test_differentSteps_areNotEqual() {
        #expect(CreateMomentStep.camera != CreateMomentStep.voice)
        #expect(CreateMomentStep.voice != CreateMomentStep.gallery)
        #expect(CreateMomentStep.gallery != CreateMomentStep.review)
        #expect(CreateMomentStep.review != CreateMomentStep.camera)
    }

    @Test func test_allCases_areFour() {
        let steps: [CreateMomentStep] = [
            .camera, .voice, .gallery, .review
        ]
        #expect(steps.count == 4)
        let uniqueSteps = Set(steps.map { "\($0)" })
        #expect(uniqueSteps.count == 4)
    }
}

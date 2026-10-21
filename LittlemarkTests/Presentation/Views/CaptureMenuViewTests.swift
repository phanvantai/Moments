import Testing
import Foundation
@testable import Littlemark

struct CaptureMenuViewTests {

    // MARK: - Visibility based on permissions

    @Test func test_allAvailable_showsAllOptions() {
        var cameraTapped = false
        var voiceTapped = false
        var galleryTapped = false

        let view = CaptureMenuView(
            isCameraAvailable: true,
            isVoiceAvailable: true,
            isGalleryAvailable: true,
            onCameraTap: { cameraTapped = true },
            onVoiceTap: { voiceTapped = true },
            onGalleryTap: { galleryTapped = true }
        )

        #expect(view.isCameraAvailable == true)
        #expect(view.isVoiceAvailable == true)
        #expect(view.isGalleryAvailable == true)
    }

    @Test func test_cameraDenied_cameraUnavailable() {
        let view = CaptureMenuView(
            isCameraAvailable: false,
            isVoiceAvailable: true,
            isGalleryAvailable: true,
            onCameraTap: {},
            onVoiceTap: {},
            onGalleryTap: {}
        )

        #expect(view.isCameraAvailable == false)
        #expect(view.isVoiceAvailable == true)
        #expect(view.isGalleryAvailable == true)
    }

    @Test func test_voiceDenied_voiceUnavailable() {
        let view = CaptureMenuView(
            isCameraAvailable: true,
            isVoiceAvailable: false,
            isGalleryAvailable: true,
            onCameraTap: {},
            onVoiceTap: {},
            onGalleryTap: {}
        )

        #expect(view.isVoiceAvailable == false)
    }

    @Test func test_galleryDenied_galleryUnavailable() {
        let view = CaptureMenuView(
            isCameraAvailable: true,
            isVoiceAvailable: true,
            isGalleryAvailable: false,
            onCameraTap: {},
            onVoiceTap: {},
            onGalleryTap: {}
        )

        #expect(view.isGalleryAvailable == false)
    }

    @Test func test_allDenied_allUnavailable() {
        let view = CaptureMenuView(
            isCameraAvailable: false,
            isVoiceAvailable: false,
            isGalleryAvailable: false,
            onCameraTap: {},
            onVoiceTap: {},
            onGalleryTap: {}
        )

        #expect(view.isCameraAvailable == false)
        #expect(view.isVoiceAvailable == false)
        #expect(view.isGalleryAvailable == false)
    }
}

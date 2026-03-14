import Testing
import UIKit
import Foundation
@testable import Moments

struct CameraViewTests {

    // MARK: - Notification Names

    @Test func test_capturePhoto_notificationName_isCorrect() {
        #expect(Notification.Name.capturePhoto.rawValue == "capturePhoto")
    }

    @Test func test_startVideoRecording_notificationName_isCorrect() {
        #expect(Notification.Name.startVideoRecording.rawValue == "startVideoRecording")
    }

    @Test func test_stopVideoRecording_notificationName_isCorrect() {
        #expect(Notification.Name.stopVideoRecording.rawValue == "stopVideoRecording")
    }

    @Test func test_notificationNames_areUnique() {
        let names: Set<Notification.Name> = [
            .capturePhoto,
            .startVideoRecording,
            .stopVideoRecording
        ]
        #expect(names.count == 3)
    }

    // MARK: - CameraViewController

    @MainActor
    @Test func test_cameraViewController_canBeCreated() {
        let vc = CameraViewController()

        #expect(vc.onPhotoCaptured == nil)
        #expect(vc.onVideoCaptured == nil)
        #expect(vc.onError == nil)
    }

    @MainActor
    @Test func test_cameraViewController_callbacksCanBeSet() {
        let vc = CameraViewController()
        var photoCalled = false
        var videoCalled = false
        var errorCalled = false

        vc.onPhotoCaptured = { _ in photoCalled = true }
        vc.onVideoCaptured = { _ in videoCalled = true }
        vc.onError = { _ in errorCalled = true }

        #expect(vc.onPhotoCaptured != nil)
        #expect(vc.onVideoCaptured != nil)
        #expect(vc.onError != nil)

        // Invoke callbacks to verify they work
        vc.onPhotoCaptured?(Data())
        vc.onVideoCaptured?(URL(fileURLWithPath: "/tmp/test.mov"))
        vc.onError?("test error")

        #expect(photoCalled)
        #expect(videoCalled)
        #expect(errorCalled)
    }
}

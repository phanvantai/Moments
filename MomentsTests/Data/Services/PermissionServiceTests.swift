import Testing
import Foundation
@testable import Moments

struct PermissionServiceTests {
    let sut = MockPermissionService()

    // MARK: - Camera

    @Test func test_camera_authorized_returnsAuthorized() async {
        sut.permissionStatuses[.camera] = .authorized

        let status = await sut.status(for: .camera)

        #expect(status == .authorized)
    }

    @Test func test_camera_denied_returnsDenied() async {
        sut.permissionStatuses[.camera] = .denied

        let status = await sut.status(for: .camera)

        #expect(status == .denied)
    }

    // MARK: - Photo Library

    @Test func test_photoLibrary_authorized_returnsAuthorized() async {
        sut.permissionStatuses[.photoLibrary] = .authorized

        let status = await sut.status(for: .photoLibrary)

        #expect(status == .authorized)
    }

    @Test func test_photoLibrary_denied_returnsDenied() async {
        sut.permissionStatuses[.photoLibrary] = .denied

        let status = await sut.status(for: .photoLibrary)

        #expect(status == .denied)
    }

    // MARK: - Microphone

    @Test func test_microphone_authorized_returnsAuthorized() async {
        sut.permissionStatuses[.microphone] = .authorized

        let status = await sut.status(for: .microphone)

        #expect(status == .authorized)
    }

    @Test func test_microphone_denied_returnsDenied() async {
        sut.permissionStatuses[.microphone] = .denied

        let status = await sut.status(for: .microphone)

        #expect(status == .denied)
    }

    // MARK: - Location

    @Test func test_location_authorized_returnsAuthorized() async {
        sut.permissionStatuses[.location] = .authorized

        let status = await sut.status(for: .location)

        #expect(status == .authorized)
    }

    @Test func test_location_denied_returnsDenied() async {
        sut.permissionStatuses[.location] = .denied

        let status = await sut.status(for: .location)

        #expect(status == .denied)
    }

    // MARK: - Speech Recognition

    @Test func test_speechRecognition_authorized_returnsAuthorized() async {
        sut.permissionStatuses[.speechRecognition] = .authorized

        let status = await sut.status(for: .speechRecognition)

        #expect(status == .authorized)
    }

    @Test func test_speechRecognition_denied_returnsDenied() async {
        sut.permissionStatuses[.speechRecognition] = .denied

        let status = await sut.status(for: .speechRecognition)

        #expect(status == .denied)
    }

    // MARK: - Request does not re-request when already decided

    @Test func test_request_whenAlreadyAuthorized_doesNotRequestAgain() async {
        sut.permissionStatuses[.camera] = .authorized
        sut.requestResults[.camera] = .authorized

        _ = await sut.status(for: .camera)
        let statusBefore = sut.statusCallCount

        // Calling request again still works
        _ = await sut.request(.camera)
        #expect(sut.requestCallCount == 1)
        #expect(sut.statusCallCount == statusBefore)
    }

    @Test func test_request_whenNotDetermined_requestsAndReturns() async {
        sut.permissionStatuses[.camera] = .notDetermined
        sut.requestResults[.camera] = .authorized

        let result = await sut.request(.camera)

        #expect(result == .authorized)
        #expect(sut.requestCallCount == 1)
        // After request, status should be updated
        let newStatus = await sut.status(for: .camera)
        #expect(newStatus == .authorized)
    }

    @Test func test_notDetermined_returnsNotDetermined() async {
        // Default is notDetermined
        let status = await sut.status(for: .camera)

        #expect(status == .notDetermined)
    }
}

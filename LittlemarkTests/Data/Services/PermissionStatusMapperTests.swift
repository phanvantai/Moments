import Testing
import AVFoundation
import Photos
import CoreLocation
import Speech
@testable import Littlemark

struct PermissionStatusMapperTests {

    // MARK: - AVAuthorizationStatus Mapping

    @Test func test_mapAVStatus_notDetermined_returnsNotDetermined() {
        let result = PermissionStatusMapper.mapAVStatus(.notDetermined)
        #expect(result == .notDetermined)
    }

    @Test func test_mapAVStatus_authorized_returnsAuthorized() {
        let result = PermissionStatusMapper.mapAVStatus(.authorized)
        #expect(result == .authorized)
    }

    @Test func test_mapAVStatus_denied_returnsDenied() {
        let result = PermissionStatusMapper.mapAVStatus(.denied)
        #expect(result == .denied)
    }

    @Test func test_mapAVStatus_restricted_returnsRestricted() {
        let result = PermissionStatusMapper.mapAVStatus(.restricted)
        #expect(result == .restricted)
    }

    // MARK: - PHAuthorizationStatus Mapping

    @Test func test_mapPHStatus_notDetermined_returnsNotDetermined() {
        let result = PermissionStatusMapper.mapPHStatus(.notDetermined)
        #expect(result == .notDetermined)
    }

    @Test func test_mapPHStatus_authorized_returnsAuthorized() {
        let result = PermissionStatusMapper.mapPHStatus(.authorized)
        #expect(result == .authorized)
    }

    @Test func test_mapPHStatus_limited_returnsAuthorized() {
        let result = PermissionStatusMapper.mapPHStatus(.limited)
        #expect(result == .authorized)
    }

    @Test func test_mapPHStatus_denied_returnsDenied() {
        let result = PermissionStatusMapper.mapPHStatus(.denied)
        #expect(result == .denied)
    }

    @Test func test_mapPHStatus_restricted_returnsRestricted() {
        let result = PermissionStatusMapper.mapPHStatus(.restricted)
        #expect(result == .restricted)
    }

    // MARK: - SFSpeechRecognizerAuthorizationStatus Mapping

    @Test func test_mapSpeechStatus_notDetermined_returnsNotDetermined() {
        let result = PermissionStatusMapper.mapSpeechStatus(.notDetermined)
        #expect(result == .notDetermined)
    }

    @Test func test_mapSpeechStatus_authorized_returnsAuthorized() {
        let result = PermissionStatusMapper.mapSpeechStatus(.authorized)
        #expect(result == .authorized)
    }

    @Test func test_mapSpeechStatus_denied_returnsDenied() {
        let result = PermissionStatusMapper.mapSpeechStatus(.denied)
        #expect(result == .denied)
    }

    @Test func test_mapSpeechStatus_restricted_returnsRestricted() {
        let result = PermissionStatusMapper.mapSpeechStatus(.restricted)
        #expect(result == .restricted)
    }

    // MARK: - CLAuthorizationStatus Mapping

    @Test func test_mapCLStatus_notDetermined_returnsNotDetermined() {
        let result = PermissionStatusMapper.mapCLAuthorizationStatus(.notDetermined)
        #expect(result == .notDetermined)
    }

    @Test func test_mapCLStatus_authorizedWhenInUse_returnsAuthorized() {
        let result = PermissionStatusMapper.mapCLAuthorizationStatus(.authorizedWhenInUse)
        #expect(result == .authorized)
    }

    @Test func test_mapCLStatus_authorizedAlways_returnsAuthorized() {
        let result = PermissionStatusMapper.mapCLAuthorizationStatus(.authorizedAlways)
        #expect(result == .authorized)
    }

    @Test func test_mapCLStatus_denied_returnsDenied() {
        let result = PermissionStatusMapper.mapCLAuthorizationStatus(.denied)
        #expect(result == .denied)
    }

    @Test func test_mapCLStatus_restricted_returnsRestricted() {
        let result = PermissionStatusMapper.mapCLAuthorizationStatus(.restricted)
        #expect(result == .restricted)
    }
}

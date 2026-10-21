import AVFoundation
import Photos
import CoreLocation
import Speech

final class PermissionService: PermissionServiceProtocol, @unchecked Sendable {

    func status(for permission: PermissionType) async -> PermissionStatus {
        switch permission {
        case .camera:
            return PermissionStatusMapper.mapAVStatus(AVCaptureDevice.authorizationStatus(for: .video))
        case .photoLibrary:
            return PermissionStatusMapper.mapPHStatus(PHPhotoLibrary.authorizationStatus(for: .readWrite))
        case .microphone:
            return PermissionStatusMapper.mapAVStatus(AVCaptureDevice.authorizationStatus(for: .audio))
        case .location:
            return PermissionStatusMapper.mapCLAuthorizationStatus(CLLocationManager().authorizationStatus)
        case .speechRecognition:
            return PermissionStatusMapper.mapSpeechStatus(SFSpeechRecognizer.authorizationStatus())
        }
    }

    func request(_ permission: PermissionType) async -> PermissionStatus {
        switch permission {
        case .camera:
            let granted = await AVCaptureDevice.requestAccess(for: .video)
            return granted ? .authorized : .denied
        case .photoLibrary:
            let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
            return PermissionStatusMapper.mapPHStatus(status)
        case .microphone:
            let granted = await AVCaptureDevice.requestAccess(for: .audio)
            return granted ? .authorized : .denied
        case .location:
            return await requestLocationPermission()
        case .speechRecognition:
            return await requestSpeechPermission()
        }
    }

    private func requestLocationPermission() async -> PermissionStatus {
        let delegate = LocationPermissionDelegate()
        let manager = CLLocationManager()
        manager.delegate = delegate
        manager.requestWhenInUseAuthorization()
        let status = await delegate.waitForAuthorization()
        return status
    }

    // MARK: - Speech

    private func requestSpeechPermission() async -> PermissionStatus {
        await withCheckedContinuation { continuation in
            SFSpeechRecognizer.requestAuthorization { status in
                continuation.resume(returning: PermissionStatusMapper.mapSpeechStatus(status))
            }
        }
    }
}

// MARK: - Location Permission Delegate

private final class LocationPermissionDelegate: NSObject, CLLocationManagerDelegate, @unchecked Sendable {
    private var continuation: CheckedContinuation<PermissionStatus, Never>?

    func waitForAuthorization() async -> PermissionStatus {
        await withCheckedContinuation { continuation in
            self.continuation = continuation
        }
    }

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        guard let continuation else { return }
        let mapped = PermissionStatusMapper.mapCLAuthorizationStatus(manager.authorizationStatus)
        guard mapped != .notDetermined else { return } // Wait for actual decision
        self.continuation = nil
        continuation.resume(returning: mapped)
    }
}

import Foundation

enum PermissionType: String, CaseIterable, Sendable {
    case camera
    case photoLibrary
    case microphone
    case location
    case speechRecognition
}

enum PermissionStatus: Equatable, Sendable {
    case notDetermined
    case authorized
    case denied
    case restricted
}

protocol PermissionServiceProtocol: Sendable {
    func status(for permission: PermissionType) async -> PermissionStatus
    func request(_ permission: PermissionType) async -> PermissionStatus
}

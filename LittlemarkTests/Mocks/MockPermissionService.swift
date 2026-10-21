import Foundation
@testable import Littlemark

final class MockPermissionService: PermissionServiceProtocol, @unchecked Sendable {
    // Call tracking
    var statusCallCount = 0
    var requestCallCount = 0
    var lastCheckedPermission: PermissionType?
    var lastRequestedPermission: PermissionType?

    // Configurable per-permission status
    var permissionStatuses: [PermissionType: PermissionStatus] = [:]
    var requestResults: [PermissionType: PermissionStatus] = [:]

    func status(for permission: PermissionType) async -> PermissionStatus {
        statusCallCount += 1
        lastCheckedPermission = permission
        return permissionStatuses[permission] ?? .notDetermined
    }

    func request(_ permission: PermissionType) async -> PermissionStatus {
        requestCallCount += 1
        lastRequestedPermission = permission
        let result = requestResults[permission] ?? .authorized
        permissionStatuses[permission] = result
        return result
    }
}

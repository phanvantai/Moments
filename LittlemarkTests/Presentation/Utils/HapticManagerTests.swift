import Testing
import Foundation
import UIKit
@testable import Littlemark

struct HapticManagerTests {

    // MARK: - Static Method Accessibility

    @Test func test_fabTap_doesNotCrash() {
        // Verify the method is callable (haptics are hardware-dependent)
        HapticManager.fabTap()
    }

    @Test func test_saveSuccess_doesNotCrash() {
        HapticManager.saveSuccess()
    }

    @Test func test_deleteWarning_doesNotCrash() {
        HapticManager.deleteWarning()
    }

    @Test func test_categoryToggle_doesNotCrash() {
        HapticManager.categoryToggle()
    }

    @Test func test_viewModeToggle_doesNotCrash() {
        HapticManager.viewModeToggle()
    }

    @Test func test_impact_light_doesNotCrash() {
        HapticManager.impact(.light)
    }

    @Test func test_impact_medium_doesNotCrash() {
        HapticManager.impact(.medium)
    }

    @Test func test_impact_heavy_doesNotCrash() {
        HapticManager.impact(.heavy)
    }

    @Test func test_notification_success_doesNotCrash() {
        HapticManager.notification(.success)
    }

    @Test func test_notification_warning_doesNotCrash() {
        HapticManager.notification(.warning)
    }

    @Test func test_notification_error_doesNotCrash() {
        HapticManager.notification(.error)
    }

    @Test func test_selection_doesNotCrash() {
        HapticManager.selection()
    }
}

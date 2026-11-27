import Testing
import SwiftUI
@testable import Littlemark

struct ThemeManagerTests {

    // MARK: - Default State

    @Test @MainActor func test_shared_returnsInstance() {
        let manager = ThemeManager.shared
        #expect(manager != nil)
    }

    // MARK: - Set Theme

    @Test @MainActor func test_setTheme_light_updatesCurrentTheme() {
        let manager = ThemeManager.shared
        manager.setTheme(.light)

        #expect(manager.currentTheme == .light)
    }

    @Test @MainActor func test_setTheme_dark_updatesCurrentTheme() {
        let manager = ThemeManager.shared
        manager.setTheme(.dark)

        #expect(manager.currentTheme == .dark)
    }

    @Test @MainActor func test_setTheme_system_updatesCurrentTheme() {
        let manager = ThemeManager.shared
        manager.setTheme(.system)

        #expect(manager.currentTheme == .system)
    }

    // MARK: - Color Scheme

    @Test @MainActor func test_colorScheme_system_returnsNil() {
        let manager = ThemeManager.shared
        manager.setTheme(.system)

        #expect(manager.colorScheme == nil)
    }

    @Test @MainActor func test_colorScheme_light_returnsLight() {
        let manager = ThemeManager.shared
        manager.setTheme(.light)

        #expect(manager.colorScheme == .light)
    }

    @Test @MainActor func test_colorScheme_dark_returnsDark() {
        let manager = ThemeManager.shared
        manager.setTheme(.dark)

        #expect(manager.colorScheme == .dark)
    }

    // MARK: - Persistence

    @Test @MainActor func test_setTheme_persistsToUserDefaults() {
        let manager = ThemeManager.shared
        manager.setTheme(.dark)

        let saved = UserDefaults.standard.string(forKey: "appTheme")
        #expect(saved == "dark")
    }

    @Test @MainActor func test_setTheme_light_persistsToUserDefaults() {
        let manager = ThemeManager.shared
        manager.setTheme(.light)

        let saved = UserDefaults.standard.string(forKey: "appTheme")
        #expect(saved == "light")
    }

    @Test @MainActor func test_setTheme_system_persistsToUserDefaults() {
        let manager = ThemeManager.shared
        manager.setTheme(.system)

        let saved = UserDefaults.standard.string(forKey: "appTheme")
        #expect(saved == "system")
    }
}

import Testing
import SwiftUI
@testable import Moments

struct AppThemeTests {

    // MARK: - Raw Values

    @Test func test_system_rawValue() {
        #expect(AppTheme.system.rawValue == "system")
    }

    @Test func test_light_rawValue() {
        #expect(AppTheme.light.rawValue == "light")
    }

    @Test func test_dark_rawValue() {
        #expect(AppTheme.dark.rawValue == "dark")
    }

    // MARK: - Init from Raw Value

    @Test func test_initFromRawValue_system() {
        #expect(AppTheme(rawValue: "system") == .system)
    }

    @Test func test_initFromRawValue_light() {
        #expect(AppTheme(rawValue: "light") == .light)
    }

    @Test func test_initFromRawValue_dark() {
        #expect(AppTheme(rawValue: "dark") == .dark)
    }

    @Test func test_initFromRawValue_invalid_returnsNil() {
        #expect(AppTheme(rawValue: "invalid") == nil)
    }

    // MARK: - Color Scheme

    @Test func test_colorScheme_system_returnsNil() {
        #expect(AppTheme.system.colorScheme == nil)
    }

    @Test func test_colorScheme_light_returnsLight() {
        #expect(AppTheme.light.colorScheme == .light)
    }

    @Test func test_colorScheme_dark_returnsDark() {
        #expect(AppTheme.dark.colorScheme == .dark)
    }

    // MARK: - Icon Name

    @Test func test_iconName_system() {
        #expect(AppTheme.system.iconName == "circle.lefthalf.filled")
    }

    @Test func test_iconName_light() {
        #expect(AppTheme.light.iconName == "sun.max.fill")
    }

    @Test func test_iconName_dark() {
        #expect(AppTheme.dark.iconName == "moon.fill")
    }

    // MARK: - Identifiable

    @Test func test_id_matchesRawValue() {
        for theme in AppTheme.allCases {
            #expect(theme.id == theme.rawValue)
        }
    }

    // MARK: - All Cases

    @Test func test_allCases_containsThreeCases() {
        #expect(AppTheme.allCases.count == 3)
        #expect(AppTheme.allCases.contains(.system))
        #expect(AppTheme.allCases.contains(.light))
        #expect(AppTheme.allCases.contains(.dark))
    }
}

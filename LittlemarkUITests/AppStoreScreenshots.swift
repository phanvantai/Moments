import XCTest

/// Takes the App Store screenshots from the DEBUG screenshot demo (see `ScreenshotDemo`).
///
/// Runs only when asked, on a 6.9" iPhone simulator with location granted:
/// ```
/// xcrun simctl privacy <udid> grant location com.randomtech.littlemark
/// TEST_RUNNER_LITTLEMARK_SCREENSHOTS=1 xcodebuild -scheme Littlemark \
///   -destination 'id=<udid>' -only-testing:LittlemarkUITests/AppStoreScreenshots test
/// xcrun xcresulttool export attachments --path <xcresult> --output-path screenshots/appstore/raw
/// ```
final class AppStoreScreenshots: XCTestCase {
    private var demoMediaPath: String {
        URL(fileURLWithPath: #filePath)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("screenshots/demo-media")
            .path
    }

    override func setUpWithError() throws {
        try XCTSkipUnless(ProcessInfo.processInfo.environment["LITTLEMARK_SCREENSHOTS"] == "1",
                          "Set TEST_RUNNER_LITTLEMARK_SCREENSHOTS=1 to take App Store screenshots")
        continueAfterFailure = true
    }

    // One test per language, so a stuck simulator only costs one run
    @MainActor func testEnglish() { takeScreenshots(language: "en") }
    @MainActor func testVietnamese() { takeScreenshots(language: "vi") }
    @MainActor func testJapanese() { takeScreenshots(language: "ja") }

    @MainActor
    private func takeScreenshots(language: String) {
        let timeline = launch(language: language, viewMode: "timeline")
        // Bring the two newest moments to the middle of the screen
        let start = timeline.coordinate(withNormalizedOffset: CGVector(dx: 0.3, dy: 0.3))
        // Slow drag with a hold at the end: no momentum, so the framing is the same every run
        start.press(
            forDuration: 0.1,
            thenDragTo: timeline.coordinate(withNormalizedOffset: CGVector(dx: 0.72, dy: 0.3)),
            withVelocity: .slow,
            thenHoldForDuration: 0.5
        )
        snap(timeline, "\(language)-1-timeline", wait: 2)

        snap(launch(language: language, viewMode: "grid", screen: "review"), "\(language)-2-review", wait: 6)
        snap(launch(language: language, viewMode: "timeline", screen: "detail"), "\(language)-3-detail", wait: 9)
        snap(launch(language: language, viewMode: "grid"), "\(language)-4-grid", wait: 4)
        snap(launch(language: language, viewMode: "grid", screen: "capture"), "\(language)-5-capture", wait: 3)
    }

    @MainActor
    private func launch(language: String, viewMode: String, screen: String? = nil) -> XCUIApplication {
        let app = XCUIApplication()
        app.launchArguments = [
            "-ScreenshotDemo",
            "-hasCompletedOnboarding", "YES",
            "-appLanguage", language,
            "-AppleLanguages", "(\(language))",
            "-moments_view_mode", viewMode,
        ]
        if let screen {
            app.launchArguments += ["-ScreenshotDemoScreen", screen]
        }
        app.launchEnvironment["SCREENSHOT_DEMO_MEDIA"] = demoMediaPath
        app.launch()
        XCTAssertTrue(app.wait(for: .runningForeground, timeout: 15))
        Thread.sleep(forTimeInterval: 3)
        return app
    }

    @MainActor
    private func snap(_ app: XCUIApplication, _ name: String, wait seconds: TimeInterval) {
        Thread.sleep(forTimeInterval: seconds)
        let attachment = XCTAttachment(screenshot: XCUIScreen.main.screenshot())
        attachment.name = name
        attachment.lifetime = .keepAlways
        add(attachment)
    }
}

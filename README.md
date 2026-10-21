# Littlemark

A simple, fast iOS app to capture and save meaningful moments in life without friction.

Capture photos, videos, and voice notes — enriched automatically with location, weather, and smart category suggestions.

## Requirements

- Xcode 15+
- iOS 17.0+
- macOS Sonoma+ (for development)

## Getting Started

1. Open `Littlemark.xcodeproj` in Xcode
2. Select an iOS 17+ simulator or device
3. Build and run (Cmd+R)

No external dependencies — the project uses only Apple frameworks.

## Architecture

Clean Architecture with MVVM presentation layer:

- **Domain** — Entities, repository/service protocols, use cases (pure Swift, no framework imports)
- **Data** — SwiftData persistence, concrete repository/service implementations
- **Presentation** — SwiftUI views, `@Observable` ViewModels, utilities

Dependency injection via `DependencyContainer` — all dependencies are explicit, no singletons.

## Testing

```bash
# Run all tests
xcodebuild -scheme Littlemark -destination 'platform=iOS Simulator,name=iPhone 16' test
```

Tests use Swift Testing framework (`@Test`, `#expect`) with protocol-based mocking. Test structure mirrors source layout.

## Features

- **Capture**: Camera, gallery picker, voice recorder
- **Browse**: Timeline and grid views with view mode toggle
- **Detail**: Full moment inspection with media viewer and voice playback
- **Smart enrichment**: Auto-detected categories (Vision + NLP), location, weather
- **Permissions**: Lazy requests with graceful degradation

## Frameworks Used

SwiftUI, SwiftData, AVFoundation, PhotosUI, CoreLocation, Speech, Vision, NaturalLanguage, WeatherKit

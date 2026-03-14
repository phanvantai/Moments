# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Build & Test Commands

**Important:** Do not hardcode a simulator device name. First check available destinations, then pick one:

```bash
# List available simulators
xcodebuild -scheme Moments -showdestinations 2>&1 | grep 'iOS Simulator'

# Build (use an available simulator from the list above)
xcodebuild -scheme Moments -destination 'platform=iOS Simulator,name=<DEVICE>' build

# Run all unit tests
xcodebuild -scheme Moments -destination 'platform=iOS Simulator,name=<DEVICE>' test

# Run a single test class
xcodebuild -scheme Moments -destination 'platform=iOS Simulator,name=<DEVICE>' \
  -only-testing:MomentsTests/CreateMomentUseCaseTests test

# Run a single test method
xcodebuild -scheme Moments -destination 'platform=iOS Simulator,name=<DEVICE>' \
  -only-testing:MomentsTests/CreateMomentUseCaseTests/test_execute_withMedia_createsMoment test
```

No linter or formatter is configured. No package manager (SPM/CocoaPods) — all dependencies are Apple frameworks.

## Test Strategy

After making changes, follow this order to minimize wasted test runs:

1. **Build first** — fix compile errors before running any tests.
2. **Run only related tests** — use `-only-testing:` to target test classes that cover the changed files. For example, if you changed `MomentDisplayHelper.swift`, run `MomentDisplayHelperTests` and `EdgeCaseTests` first.
3. **Always capture test output** — pipe through `grep -E "(passed|failed|error:)"` or `tail` so you can see which tests failed and why in a single run. Never run tests blindly then re-run just to read the output.
4. **Run the full suite once** — only after the targeted tests pass, run the full test suite as a final check. Avoid re-running the full suite multiple times.

## Architecture

Clean Architecture with three layers, strict dependency rule (outer layers depend inward):

```bash
Domain (pure Swift, no imports)
  ├── Entities/        — value types (struct): Moment, MediaItem, User, Location, etc.
  ├── Repositories/    — protocols: MomentRepositoryProtocol, MediaRepositoryProtocol
  ├── Services/        — protocols: PermissionServiceProtocol, LocationServiceProtocol, etc.
  └── UseCases/        — business logic: CreateMomentUseCase, FetchMomentsUseCase, DeleteMomentUseCase

Data (framework imports allowed)
  ├── SwiftData/       — @Model classes (SDMoment, SDMediaItem, SDUser) + MomentMapper
  ├── Repositories/    — concrete impls of domain repository protocols
  └── Services/        — concrete impls: PermissionService, CategoryEngine, LocationService, etc.

Presentation (SwiftUI)
  ├── ViewModels/      — @Observable @MainActor classes, one per screen/component
  ├── Views/           — SwiftUI views, composed from ViewModels
  ├── Models/          — presentation-only types (ViewMode, CreateMomentStep)
  └── Utils/           — HapticManager, ThumbnailCache, DurationFormatter, etc.
```

**DI**: `DependencyContainer` (in `DI/`) wires everything. Created once in `MomentsApp.init()`, passed to `ContentView`. ViewModels are created via factory methods (`makeTimelineViewModel()`, `makeCreateMomentViewModel()`).

**Persistence**: SwiftData with `SDMoment`/`SDMediaItem`/`SDUser` models. `MomentMapper` converts between domain entities and SwiftData models bidirectionally.

**Concurrency**: All ViewModels are `@MainActor`. Domain protocols are `Sendable`. Async/await throughout.

## Testing Conventions

- **Framework**: Swift Testing (`@Test`, `#expect`) — not XCTest
- **TDD required**: Write tests first, then implementation. All code must be testable.
- **Pattern**: Protocol-based mocking. Every service/repository has a protocol in Domain and a mock in `MomentsTests/Mocks/`.
- **Mock conventions**: Mocks track call counts (`createCallCount`), capture arguments (`lastCreatedMoment`), and support error injection (`errorToThrow`).
- **Test data**: `MockMomentFactory` provides pre-built domain objects for tests.
- **Test structure**: Mirrors source layout — `MomentsTests/Domain/UseCases/`, `MomentsTests/Data/Services/`, etc.
- **Naming**: `test_methodName_condition_expectedResult` pattern.

When adding a new service or repository:

1. Define protocol in `Domain/Services/` or `Domain/Repositories/`
2. Write tests using a mock
3. Create mock in `MomentsTests/Mocks/`
4. Implement concrete class in `Data/`
5. Wire into `DependencyContainer`

## Key Domain Rules

- A Moment **requires at least one media item** (photo, video, or voice note) to be saved — enforced by `CreateMomentUseCase`.
- `DeleteMomentUseCase` cascade-deletes associated media files before removing the moment.
- Categories are auto-suggested via multi-signal analysis (NLP + Vision + Location) with a 60% confidence threshold.
- MVP uses a single default user (`User.default` with hardcoded UUID).
- Permissions are requested lazily (only when the feature is used) with graceful degradation if denied.

## Platform

- iOS 17.0+ deployment target
- SwiftUI + SwiftData
- Apple frameworks only: AVFoundation, PhotosUI, CoreLocation, Speech, Vision, NaturalLanguage, WeatherKit

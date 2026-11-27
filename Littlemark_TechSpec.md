# LITTLEMARK — Technical Specification

## Implementation-Level Reference

Version 1.0 · March 2026
Covers: MVP v1.0 codebase (QC phase)

---

## 1. App Lifecycle & Initialization

### 1.1 App Entry (`LittlemarkApp.swift`)

- **SwiftData Schema**: Registers `SDMoment`, `SDMediaItem`, `SDUser` in a single `ModelContainer` (persistent, not in-memory).
- **Storage Directory**: Ensures `ApplicationSupport` directory exists at launch.
- **Default User**: `container.ensureDefaultUser()` runs on every launch — checks for UUID `00000000-0000-0000-0000-000000000001`, creates if missing with displayName `"Me"`.
- **Onboarding Gate**: `@AppStorage("hasCompletedOnboarding")` (Bool, default `false`). Shows `OnboardingView` until completed, then `ContentView`.
- **Theme Application**: `ThemeManager.shared` provides `colorScheme` (nil for system, `.light`, `.dark`). Applied via `.preferredColorScheme()`.
- **Language Application**: `LanguageManager.shared` provides locale. Applied via `.environment(\.locale, ...)`. A `languageId = UUID()` state forces full view rebuild on language change.

### 1.2 Dependency Injection (`DependencyContainer.swift`)

Created once in `LittlemarkApp.init()`, passed to `ContentView`. All services are instantiated eagerly. `@MainActor` isolated.

| Component | Type | Notes |
| ----------- | ------ | ------- |
| `MediaFileService` | Service | File I/O operations |
| `PermissionService` | Service | System permission requests |
| `LocationService` | Service | GPS + reverse geocoding |
| `WeatherService` | Service | WeatherKit integration |
| `CategoryEngine` | Service | NLP + Vision + Location analysis |
| `MomentRepository` | Repository (actor) | SwiftData CRUD, thread-safe |
| `MediaRepository` | Repository | Delegates to MediaFileService |
| `CreateMomentUseCase` | Use Case | Validates + persists |
| `FetchMomentsUseCase` | Use Case | Sorted fetch |
| `DeleteMomentUseCase` | Use Case | Cascade delete |

**Factory Methods**:

- `makeTimelineViewModel()` → injects FetchMomentsUseCase + DeleteMomentUseCase
- `makeCreateMomentViewModel()` → injects 6 dependencies (use case, permission, media repo, location, weather, category engine)

---

## 2. State Persistence

All persistent state and where it lives:

| Data | Storage | Key / Location | Default |
| ------ | --------- | --------------- | --------- |
| Moments | SwiftData | `SDMoment` table | — |
| Media files | FileSystem | `Documents/Media/` | — |
| Voice notes | FileSystem | `Documents/Voice/` | — |
| Video thumbnails | FileSystem | `Documents/Thumbnails/` | — |
| View mode | UserDefaults | `"moments_view_mode"` | `"timeline"` |
| App theme | UserDefaults | `"appTheme"` | `"system"` |
| App language | UserDefaults | `"appLanguage"` + `"AppleLanguages"` | `"en"` (English) |
| Onboarding completed | @AppStorage | `"hasCompletedOnboarding"` | `false` |
| Thumbnail cache | NSCache (memory only) | — | Cleared on app termination |

---

## 3. Home Screen (`ContentView.swift`)

### 3.1 View Mode

- **Default**: `.timeline` (fallback when no UserDefaults value exists).
- **Persistence**: On every toggle, `UserDefaults.standard.set(viewMode.rawValue, forKey: "moments_view_mode")` is called synchronously in the `didSet` of `TimelineViewModel.viewMode`.
- **Toggle**: Toolbar button in top-right. Toggles between `.timeline` and `.grid`. Icon changes: `"square.grid.2x2"` ↔ `"timeline.selection"` with `.symbolEffect(.replace)` transition.
- **View Transitions**: Timeline slides from leading edge, Grid slides from trailing edge. Both combined with opacity.

### 3.2 State Variables

| State | Type | Purpose |
| ------- | ------ | --------- |
| `timelineViewModel` | `TimelineViewModel?` | Lazy-loaded in `.task`, nil shows `ProgressView` |
| `createMomentViewModel` | `CreateMomentViewModel?` | Non-nil triggers `.fullScreenCover` (drives presentation) |
| `selectedMoment` | `Moment?` | Non-nil triggers `.sheet` for detail view |
| `showSettings` | `Bool` | Triggers settings sheet |
| `momentToDelete` | `UUID?` | Non-nil triggers delete confirmation dialog |
| `fabScale` | `CGFloat` | FAB press animation (1.0 → 0.85 → 1.0) |
| `fabRotation` | `Double` | FAB press animation (0° → 90° → 0°) |

### 3.3 Data Loading

- `TimelineViewModel` is created via `container.makeTimelineViewModel()` in a `.task` modifier.
- `loadMoments()` is called immediately after creation.
- Moments are fetched sorted by `createdAt` descending (newest first).
- Pull-to-refresh is available in both Timeline and Grid views via `onRefresh` callback.

### 3.4 FAB (Floating Action Button)

1. Tap triggers `HapticManager.fabTap()` (medium impact).
2. Spring animation: scale to 0.85 + rotate 90° (response 0.3, damping 0.6).
3. After 150ms delay (`DispatchQueue.main.asyncAfter`):
   - Scale/rotation spring back to normal.
   - `createMomentViewModel` is created via `container.makeCreateMomentViewModel()`.
   - Setting it non-nil triggers the `.fullScreenCover(item:)`.
4. Dismissal: Setting `createMomentViewModel = nil` dismisses the cover.

### 3.5 Delete Flow

1. Long-press on a moment card → context menu → "Delete".
2. Sets `momentToDelete = id` → triggers `.confirmationDialog`.
3. User confirms → `HapticManager.deleteWarning()` → `timelineViewModel.deleteMoment(id:)`.
4. `DeleteMomentUseCase` cascade-deletes: media files → thumbnails → voice note → SwiftData record.
5. Optimistic UI: `moments.removeAll { $0.id == id }` runs before async completion.

---

## 4. Create Moment Flow (`CreateMomentView.swift`)

### 4.1 Step Navigation

Steps are defined in `CreateMomentStep` enum: `.captureMenu` → `.camera` / `.voice` / `.gallery` → `.review`.

| Step | View | Transition |
| ------ | ------ | ------------ |
| `.captureMenu` | `CaptureMenuView` overlay | `.opacity` |
| `.camera` | `CameraView` | `.move(edge: .trailing)` + `.opacity` |
| `.voice` | `VoiceRecorderView` | `.move(edge: .trailing)` + `.opacity` |
| `.gallery` | Modal `PhotosPicker` | `.move(edge: .trailing)` + `.opacity` |
| `.review` | `ReviewMomentView` | `.move(edge: .bottom)` + `.opacity` |

All transitions use spring animation: response 0.35s, dampingFraction 0.8.

### 4.2 Capture Menu

- Semi-transparent black overlay (`Color.black.opacity(0.4)`). Tap outside dismisses.
- Three option buttons: Camera (blue), Voice (red), Gallery (green).
- Staggered entrance animation: delays 0s, 0.06s, 0.12s. Scale 0.85 → 1.0.
- Each button checks permission before navigating. If denied, shows banner with Settings deep-link.

### 4.3 Permission Flow

Each capture option follows:

1. Call `viewModel.requestPermission(.camera / .microphone / .photoLibrary)`.
2. If `.authorized` → navigate to capture step.
3. If `.denied` → show permission denied banner (orange icon + explanation + "Settings" button).
4. After any request → `viewModel.refreshPermissions()` to update button availability.

Voice recording also requests `.speechRecognition` after microphone is granted (non-blocking).

### 4.4 Gallery Picker

- Uses `.photosPicker(isPresented:selection:)` modifier (modal system picker).
- Picker opens automatically via `.onAppear { showPhotoPicker = true }`.
- Max selection: 20 items. Matching: `.any(of: [.images, .videos])`.
- On selection confirmed (`onChange(of: selectedPhotos)`), calls `loadSelectedPhotos()`.
- **Image loading**: Uses custom `TransferableImage` struct with `DataRepresentation(importedContentType: .image)`.
- **Video loading**: Uses custom `TransferableMovie` struct with `FileRepresentation(importedContentType: .movie)`. Copies to temp directory before reading.
- Type detection: Checks `item.supportedContentTypes` for `.movie` conformance.

### 4.5 Camera Capture

- `CameraPreviewRepresentable` wraps `UIImagePickerController`-style AVCaptureSession.
- Photo capture: Returns `Data`, saved as `UUID.jpg`.
- Video capture: Returns `URL`, read as `Data`, saved as `UUID.mov`. Thumbnail auto-generated.
- Recording indicator: Button animates from 72pt circle → 36pt circle when recording.

### 4.6 Voice Recording

- Uses `AVAudioRecorder` with `.m4a` format.
- Waveform visualization: 40 bars, normalized from -60dB–0dB → 0.0–1.0.
- Live transcription via `SFSpeechRecognizer` (on-device).
- On complete: Returns URL + duration + optional transcript.
- Saved as `UUID.m4a`.

### 4.7 Save Validation

`CreateMomentViewModel.canSave` returns `true` if `capturedMediaItems` is non-empty OR `voiceNote` is non-nil. `CreateMomentUseCase` enforces the same rule, throwing `CreateMomentError.noMedia` if violated.

---

## 5. Review & Save (`ReviewMomentView.swift`)

### 5.1 Review Screen Sections

1. **Media Preview**: Horizontal scroll of 120x120 thumbnails. Each has a remove (X) button.
2. **Voice Note**: Waveform icon + duration + transcript preview (if present). Removable.
3. **Text Field**: Multi-line TextField (3–6 lines). Optional.
4. **Smart Features**: Auto-loaded via `viewModel.loadSmartFeatures()` in `.task`.
5. **Tags**: Flow layout of tag chips + add new tag input.
6. **Add More Media**: Button returns to capture menu.

### 5.2 Smart Features Loading

Triggered automatically when ReviewMomentView appears:

1. **Location**: `locationService.getCurrentLocation()` → reverse geocodes to get name/address/placeType.
2. **Weather**: If location available, `weatherService.fetchWeather(latitude:, longitude:)`.
3. **Categories**: `categoryEngine.suggest(text:, voiceTranscript:, imageData:, location:)`.

All three are non-blocking. UI shows spinner (`isLoadingSmartFeatures`) while loading.

### 5.3 Category Suggestions

- All suggested categories are auto-selected (`selectedCategoryKeys = Set(categoryKeys)`).
- User can tap to toggle individual categories on/off.
- Tap triggers `HapticManager.categoryToggle()` (light impact).
- Visual: Selected = filled capsule with category color. Deselected = outline only.

### 5.4 Location Control

- Location badge shows name + map pin icon.
- User can remove location via X button → `viewModel.disableLocation()`.
- Disabling clears both location and weather (weather depends on location).

### 5.5 Save Flow

1. User taps "Save" (disabled if `!canSave`).
2. `viewModel.save()`:
   - Sets `isSaving = true`, clears `errorMessage`.
   - Resolves `selectedCategoryKeys` → `[MomentCategory]` via `MomentCategory.find(byKey:)`.
   - Creates `Moment` struct with `User.default.id`, all collected data.
   - Calls `createMomentUseCase.execute(moment)`.
   - On success: `resetState()`, `isSaved = true`.
   - On error: Sets `errorMessage`.
3. `isSaved = true` triggers `onChange` in CreateMomentView → `HapticManager.saveSuccess()` → `onSaved()` callback.
4. `onSaved()` in ContentView: Sets `createMomentViewModel = nil` (dismisses cover) + reloads timeline.

---

## 6. Timeline View (`TimelineView.swift`)

### 6.1 Layout

- Horizontal `ScrollView` with a `ZStack` containing:
  - Background gradient line (2pt width, `BrandColors.timelineGradient`).
  - `HStack(spacing: 20)` of `TimelineNodeView` items.
- Padding: 24pt horizontal.

### 6.2 Node Layout (`TimelineNodeView.swift`)

- **Alternating alignment**: Odd-indexed nodes align top, even-indexed align bottom (`index % 2 == 0`).
- **Connector line**: 20pt vertical gradient line connecting node circle to card.
- **Circle node**: 28pt outer circle (20% category color opacity) + 16pt inner circle (solid category color, white 2pt stroke, shadow).
- **Card**: 170pt wide. 56pt thumbnail + title (caption, bold) + relative date (caption2) + media type badges.
- **Card styling**: 14pt corner radius, 0.5pt border stroke, dual shadow (black 5% + category color 8%).

### 6.3 Entrance Animation

- Staggered spring animation: each node delayed by `index * 0.08` seconds.
- Scale: 0.6 → 1.0, opacity: 0 → 1.0.
- Response: 0.5s, dampingFraction: 0.7.

---

## 7. Grid View (`GridView.swift`)

### 7.1 Layout

- 2-column flexible grid (`[GridItem(.flexible()), GridItem(.flexible())]`), spacing 12pt.
- `LazyVGrid` inside `ScrollView`.

### 7.2 Date Grouping

Moments are grouped into sections by date:

- **Today** — same calendar day.
- **Yesterday** — previous calendar day.
- **This week** — within current calendar week.
- **Older** — formatted as "Month Year" (e.g., "March 2026").

### 7.3 Card Layout (`GridCardView.swift`)

- 160pt thumbnail area with resizable scaled-to-fill image.
- Placeholder for voice-only moments: gradient background + category emoji or camera icon.
- Content: title (subheadline, bold), relative date (caption2), up to 3 category badges.
- Video/voice badge overlay in top-trailing corner.
- 16pt corner radius, dual shadow, 0.5pt border.

### 7.4 Card Animation

- Spring entrance: scale 0.9 → 1.0, delay `index * 0.05`.
- Removal: scale to 0.85 with opacity fade.

---

## 8. Moment Detail (`MomentDetailView.swift`)

Presented as a `.sheet` modal from ContentView.

### 8.1 Sections

1. **Media Viewer**: If media exists, shows paged `MediaViewer` (max height: 45% of screen or 400pt).
2. **Title & Text**: Optional title (title2, rounded, bold) + text (body, rounded).
3. **Voice Player**: `VoicePlayerView` if voice note exists.
4. **Metadata Card**: Categories (flow layout), tags (flow layout), weather badge. Grouped in secondary background card with 14pt padding.
5. **Mini Map**: If location exists. Non-interactive `Map` view (150pt height, 14pt corner radius). "Open in Maps" overlay button. Tap opens Apple Maps via `MKMapItem.openInMaps()`.
6. **Timestamp**: Clock icon + formatted date (day/month/year/hour/minute).

### 8.2 Entrance Animation

- Spring: response 0.5s, dampingFraction 0.8, delay 0.1s.
- Media section: opacity 0→1, offset y: 10→0.
- Content section: opacity 0→1, offset y: 15→0.

---

## 9. Media Viewer (`MediaViewer.swift`)

- **TabView** with `.tabViewStyle(.page(indexDisplayMode: .never))` for horizontal swiping.
- **Photos**: `ZoomableImageView` with:
  - Pinch-to-zoom: 1x–5x range, spring reset below 1x.
  - Double-tap: Toggles between 1x and 2x.
  - Drag panning when zoomed.
- **Videos**: `AVKit.VideoPlayer`.
- **Page indicator**: Custom dots (8pt circles), filled for current page, 50% opacity for others.

---

## 10. Voice Player (`VoicePlayerView.swift` + `VoicePlayerViewModel.swift`)

### 10.1 Playback

- Uses `AVAudioPlayer` (wrapped via `AudioPlayerProtocol` for testability).
- Timer fires every 0.1s to update `currentTime`.
- Progress: `currentTime / duration` ratio.
- Auto-stops and resets when playback completes.

### 10.2 UI

- Play/pause button + procedural waveform (sine-wave bars) + time display.
- Bars: Colored up to progress point, faded beyond.
- Transcript shown below if present (caption, secondary color).
- `ultraThinMaterial` background with 14pt corner radius.
- Stops playback on `onDisappear`.

---

## 11. Smart Categorization Engine (`CategoryEngine.swift`)

### 11.1 Signal Sources & Weights

| Signal | Weight | Method |
| -------- | -------- | -------- |
| NLP (text + transcript) | 0.6 | Keyword matching per category |
| Vision (image classification) | 0.4 | `VNClassifyImageRequest`, top 5 labels at ≥0.3 confidence |
| Location (place type) | 0.5 | Maps placeType string to category key |

### 11.2 NLP Analysis

- Combines text + voice transcript, lowercased.
- Iterates each category's keyword list.
- First keyword match adds category with 0.6 weight. One match per category.

### 11.3 Vision Analysis

- `VNClassifyImageRequest` on image data.
- Filters results to confidence ≥ 0.3.
- Takes top 5 labels.
- Maps labels to categories: `"person"` → `"family"`, `"food"` → `"food"`, `"outdoor"` / `"plant"` → `"outdoor"`, etc.
- Deduplicates per category.

### 11.4 Location Analysis

Maps `placeType` to category:

- `"park"`, `"beach"` → `"outdoor"`
- `"hospital"` → `"health"`
- `"restaurant"` → `"food"`
- `"school"` → `"learn"`

### 11.5 Default Behavior

If no signals produce any categories, returns `["daily"]`.

---

## 12. Location Service (`LocationService.swift`)

- **Accuracy**: `kCLLocationAccuracyHundredMeters`.
- **Reverse Geocoding**: Uses `CLGeocoder` to get placemark.
  - **Name**: `areasOfInterest?.first` or `name`.
  - **Address**: Formatted from subThoroughfare + thoroughfare + subLocality + locality.
  - **Place Type**: Detected from `areasOfInterest` keywords mapped to: park, hospital, restaurant, school, museum, transport, hotel, shopping, beach, worship. Falls back to ocean/inlandWater properties.
- **Distance Calculation**: `Location.distance(to:)` uses Haversine formula with Earth radius 6,371,000m.
- Returns `nil` if permission denied or any step fails.

---

## 13. Weather Service (`WeatherService.swift`)

- Uses `WeatherKit.WeatherService.shared`.
- Fetches current weather for given coordinates.
- **Temperature**: Converted to Celsius.
- **Condition Mapping** (22 cases): Maps `WeatherCondition` enum to human-readable string + SF Symbol icon.
  - Examples: `.clear` → ("Sunny", "sun.max.fill"), `.rain` → ("Rainy", "cloud.rain.fill"), `.snow` → ("Snowy", "cloud.snow.fill").
- Returns `nil` if fetch fails (non-blocking, no error shown to user).

---

## 14. Permission Handling (`PermissionService.swift`)

### 14.1 Permission Types & System APIs

| Permission | System API | Notes |
| ------------ | ----------- | ------- |
| Camera | `AVCaptureDevice.requestAccess(for: .video)` | Boolean result |
| Photo Library | `PHPhotoLibrary.requestAuthorization(for: .readWrite)` | `.limited` treated as `.authorized` |
| Microphone | `AVCaptureDevice.requestAccess(for: .audio)` | Boolean result |
| Location | `CLLocationManager.requestWhenInUseAuthorization()` | Delegate callback via CheckedContinuation |
| Speech | `SFSpeechRecognizer.requestAuthorization()` | Callback via CheckedContinuation |

### 14.2 Status Mapping (`PermissionStatusMapper.swift`)

All system-specific status enums map to unified `PermissionStatus`: `.notDetermined`, `.authorized`, `.denied`, `.restricted`.

Location: both `.authorizedWhenInUse` and `.authorizedAlways` → `.authorized`.

### 14.3 UI Behavior

- Buttons dim (not hidden) when permission denied.
- `isCameraAvailable`, `isVoiceAvailable`, `isGalleryAvailable` flags updated after each permission check.
- Denied banner includes deep-link to iOS Settings: `UIApplication.openSettingsURLString`.

---

## 15. Theme Management (`ThemeManager.swift`)

- **Singleton**: `ThemeManager.shared`, `@Observable`, `@MainActor`.
- **Storage**: UserDefaults key `"appTheme"`.
- **Options**: `.system` (nil → follows device), `.light` (`.light`), `.dark` (`.dark`).
- **Applied**: Via `.preferredColorScheme()` on root view.
- **Change Detection**: `didSet` on `currentTheme` persists immediately.

---

## 16. Language Management (`LanguageManager.swift`)

- **Singleton**: `LanguageManager.shared`, `@Observable`, `@MainActor`.
- **Storage**: UserDefaults keys `"appLanguage"` + `"AppleLanguages"` (system array).
- **Languages**: `.english` ("en"), `.japanese` ("ja"), `.vietnamese` ("vi").
- **Default**: `.english`.
- **Bundle Loading**: `Bundle(path:)` for `.lproj` folder matching language rawValue.
- **Side Effect**: `setLanguage()` updates `AppleLanguages` system key for proper format/date localization.
- **View Rebuild**: Setting language triggers `languageId = UUID()` in LittlemarkApp, forcing complete view tree recreation.

---

## 17. Thumbnail Caching (`ThumbnailCache.swift`)

- **Type**: `actor` (thread-safe).
- **Singleton**: `ThumbnailCache.shared`.
- **Backend**: `NSCache` with:
  - `countLimit`: 100 images.
  - `totalCostLimit`: 50 MB (50 *1024* 1024).
- **Deduplication**: Tracks in-flight `loadingTasks: [String: Task<UIImage?, Never>]` to prevent concurrent loads for the same path.
- **Scaling**: Images resized to max 300x300 before caching (aspect ratio preserved).
- **Eviction**: Automatic via NSCache LRU policy. Also `clearCache()` method available.

---

## 18. Display Helpers

### 18.1 MomentDisplayHelper

- **Title Resolution** (priority order): `moment.title` → `moment.text` (first 30 chars) → first category label → `"Moment"`.
- **Category Color**: Maps category key to `BrandColors.category*` color. 10 mappings.
- **Media Badges**: `hasPhotoBadge`, `hasVideoBadge`, `hasVoiceBadge` — simple existence checks.
- **File URL**: Appends relative path to `FileManager.default.urls(for: .documentDirectory)`.

### 18.2 DurationFormatter

- `shortFormat(_:)`: `"M:SS"` (e.g., `"2:05"`).
- `paddedFormat(_:)`: `"MM:SS"` (e.g., `"02:05"`).

### 18.3 AudioLevelNormalizer

- `normalize(decibels:)`: Maps -60dB–0dB → 0.0–1.0 (clamped).
- `appendLevel(_:to:maxCount:)`: Circular buffer, default max 40 entries.

---

## 19. Haptic Feedback (`HapticManager.swift`)

| Action | Feedback Type | Intensity |
|--------|--------------|-----------|
| FAB tap | Impact | Medium |
| Save success | Notification | Success |
| Delete warning | Notification | Warning |
| Category toggle | Impact | Light |
| View mode toggle | Impact | Light |

---

## 20. Brand Colors (`BrandColors.swift`)

### 20.1 Primary Palette

| Name | RGB | Usage |
|------|-----|-------|
| `accent` | (0.96, 0.52, 0.39) | Primary warm coral |
| `accentDark` | (0.85, 0.38, 0.28) | Pressed/active state |
| `accentLight` | accent at 15% opacity | Subtle backgrounds |
| `warmBackground` | (0.99, 0.97, 0.95) | Page background |

### 20.2 Semantic Colors

| Name | RGB | Usage |
|------|-----|-------|
| `cardSurface` | (1.0, 0.99, 0.98) | Card backgrounds |
| `cardBorder` | (0.92, 0.90, 0.87) | Card stroke |
| `textSecondary` | (0.55, 0.52, 0.50) | Secondary text |
| `sectionHeader` | (0.45, 0.42, 0.40) | Section labels |

### 20.3 Category Colors

Yellow, Orange, Blue, Green, Purple, Red, Cyan, Pink, Indigo, Teal — one per category.

### 20.4 Gradients

- `fabGradient`: Coral to deeper coral (FAB button).
- `warmGradient`: Warm background tones.
- `timelineGradient`: Accent opacity 0.08 → 0.20 → 0.08 (timeline line).

---

## 21. Animation Constants

| Animation | Response | Damping | Delay | Notes |
|-----------|----------|---------|-------|-------|
| Standard transition | 0.35s | 0.8 | — | Step changes in create flow |
| FAB press | 0.3s | 0.6 | — | Scale + rotation |
| FAB release | 0.3s | 0.6 | 150ms | After press |
| Capture menu entrance | 0.45s | 0.75 | 0/0.06/0.12s | Staggered buttons |
| Timeline node entrance | 0.5s | 0.7 | index × 0.08s | Staggered nodes |
| Grid card entrance | — | — | index × 0.05s | Scale 0.9 → 1.0 |
| Detail entrance | 0.5s | 0.8 | 0.1s | Fade + slide |
| Category badge toggle | 0.15s (easeOut) | — | — | Color change |
| Empty state entrance | 0.6s | 0.75 | 0.1s | Scale + opacity |
| Save completion | — | — | — | Triggers onSaved callback |

---

## 22. File System Structure

```
Documents/
├── Media/
│   ├── {UUID}.jpg          # Photos
│   └── {UUID}.mov          # Videos
├── Voice/
│   └── {UUID}.m4a          # Voice recordings
└── Thumbnails/
    └── {UUID}_thumb.jpg    # Video thumbnails (JPEG quality 0.7)
```

---

## 23. Navigation Flow Summary

```
App Launch
  ├── hasCompletedOnboarding == false
  │   └── OnboardingView (paged) → set true → ContentView
  └── hasCompletedOnboarding == true
      └── ContentView
          ├── Timeline / Grid (toggle persisted)
          │   ├── Tap card → MomentDetailView (sheet)
          │   │   └── Media viewer, text, voice, map, weather, categories
          │   └── Long-press → Delete confirmation → cascade delete
          ├── FAB (+) → CreateMomentView (fullScreenCover)
          │   ├── CaptureMenu
          │   │   ├── Camera → photo/video capture → Review
          │   │   ├── Voice → recording → Review
          │   │   └── Gallery → PhotosPicker modal → Review
          │   └── ReviewMomentView
          │       ├── Smart features auto-load (location, weather, categories)
          │       ├── Edit text, tags, categories
          │       └── Save → dismiss → reload timeline
          └── Settings (sheet)
              ├── Theme picker (system/light/dark)
              └── Language picker (en/ja/vi)
```

---

## 24. Error Handling Strategy

| Scenario | Behavior | User Impact |
|----------|----------|-------------|
| No media on save | `CreateMomentError.noMedia` thrown | Save button disabled (canSave = false) |
| Media file save fails | Error caught, `errorMessage` set | Alert with retry option |
| Moment not found (delete) | `MomentRepositoryError.momentNotFound` | Error shown in timeline |
| Location unavailable | Returns nil | Moment saved without location |
| Weather fetch fails | Returns nil | Moment saved without weather |
| Vision/NLP fails | Returns empty | Falls back to "daily" category |
| Permission denied | Status = `.denied` | Banner with Settings link, feature dimmed |
| Media file delete fails | `try?` (non-fatal) | DB record still deleted |
| Thumbnail generation fails | `try?` (non-fatal) | Placeholder icon shown |

---

## 25. Testing Architecture

- **Framework**: Swift Testing (`@Test`, `#expect`), not XCTest.
- **Pattern**: Protocol-based mocking. Every service/repository has a protocol in Domain and a mock in `LittlemarkTests/Mocks/`.
- **Mock tracking**: Call counts (`createCallCount`), captured arguments (`lastCreatedMoment`), error injection (`errorToThrow`).
- **Test data**: `MockMomentFactory` provides pre-built domain objects.
- **Naming**: `test_methodName_condition_expectedResult`.
- **Structure**: Mirrors source: `LittlemarkTests/Domain/UseCases/`, `LittlemarkTests/Data/Services/`, etc.

---

## 26. External Framework Dependencies

| Framework | Usage |
|-----------|-------|
| SwiftUI | All UI, @Observable, @Bindable, @State |
| SwiftData | Persistence (@Model, ModelContainer, FetchDescriptor) |
| AVFoundation | Camera capture, audio recording, thumbnail generation |
| AVKit | Video playback (VideoPlayer) |
| PhotosUI | PhotosPicker, PHPhotoLibrary permissions |
| CoreLocation | GPS, CLGeocoder reverse geocoding |
| Speech | SFSpeechRecognizer for voice transcription |
| Vision | VNClassifyImageRequest for image categorization |
| NaturalLanguage | NLP text analysis (keyword extraction) |
| WeatherKit | Real-time weather data |
| MapKit | Map display in detail view |
| UIKit | Haptics, UIImage processing, UIApplication |
| UniformTypeIdentifiers | Media type detection in gallery picker |

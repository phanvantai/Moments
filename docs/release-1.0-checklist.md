# Littlemark 1.0 — Release Checklist

Status: In progress · Started 2026-10-29

Decisions (2026-10-29):

- iCloud sync **off** for 1.0 — data stays on device; sync is a v1.x feature.
- **iPhone only** for 1.0 (`TARGETED_DEVICE_FAMILY = 1`).
- **Grid view stays in** — re-enable the toggle and test pagination.

## Phase A — Code (Claude, TDD)

Do these in order. Each item: write tests → implement → targeted tests → full suite → commit.

- [x] **A1. Safe persistence**
  - [x] `VersionedSchema` (V1) + `SchemaMigrationPlan` for `SDMoment` / `SDMediaItem` / `SDUser` (`LittlemarkSchema.swift`)
  - [x] `ModelConfiguration(cloudKitDatabase: .none)` (`ModelContainerFactory.swift`)
  - [x] No `fatalError` on store load — `AppLaunchViewModel` + `StoreErrorView` with retry
  - [x] Remove CloudKit / `aps-environment` entitlements and the `remote-notification` background mode
  - Optional later: turn off iCloud + Push Notifications on the App ID in the developer portal
- [x] **A2. Stream videos to disk** — videos and voice recordings are moved into place by URL (`importMedia` / `importVoiceNote`); removed the unused `GalleryPickerView`
- [x] **A3. No orphan media files** — `removeMedia` / `removeVoiceNote` delete their files (+ video thumbnails); leaving the capture flow calls `discardDraft()`
- [x] **A4. Speech recognition** — `SpeechRecognitionPolicy`: on-device only, locale follows the app language; no on-device model → saved without transcript
- [x] **A5. Apple Weather attribution** — `WeatherAttributionView` (mark + "Other data sources") under the weather on Review and Detail
- [x] **A6. iPhone only** — `TARGETED_DEVICE_FAMILY = 1`
- [x] **A7. Grid view** — toggle back on; fixed grid order (was reversed) and the jump-to-end when older pages load (grid + timeline)
  - [x] Checked paging in the app with 80 demo moments (grid + timeline)
- [x] **A8. Privacy manifest** — `PrivacyInfo.xcprivacy` (UserDefaults reason `CA92.1`, no tracking, no collected data)
- [x] **A9. Cleanup** — remove `[Gallery]` debug `print`s and other leftover logging
- [x] **A10. Dynamic Type** — the fixed-size text labels (timeline date/time, grid category badges) use text styles, capped at xxxLarge; remaining fixed sizes are icons/emoji

## Phase B — Store & device (needs you)

- [ ] Privacy policy page online (Claude can draft the text)
- [ ] Support page online
- [ ] App Store description + keywords (Claude can draft, en/vi/ja)
- [ ] Category, age rating, App Privacy ("Data Not Collected"), price + countries, EU trader status
- [ ] iPhone 6.3" screenshots
- [ ] Archive + upload build, TestFlight on a real device
- [ ] Device QC: launch < 1s, smooth timeline scroll, memory with hundreds of moments
- [ ] Notes for App Review (WeatherKit, permissions)

## Phase C — Submit

- [ ] Submit 1.0 for review
- [ ] Live on the App Store

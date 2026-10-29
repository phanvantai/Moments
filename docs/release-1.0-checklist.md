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
- [x] **A11. Privacy policy + support links in Settings** (guideline 5.1.1)
- [x] **A12. Found while testing:** category labels were Vietnamese in every language; timeline stopped after 2 pages; grid could open at the top; review date row was off-center
- [x] **A10. Dynamic Type** — the fixed-size text labels (timeline date/time, grid category badges) use text styles, capped at xxxLarge; remaining fixed sizes are icons/emoji

## Phase B — Store & device

- [x] Privacy policy, support and landing pages written (`littlemark-landing/`, en/vi/ja)
- [ ] **Host the site** (blocked — needs you): repo `phanvantai/Moments` is private, so GitHub Pages
  needs a paid plan or a separate public repo. Then add DNS `littlemark CNAME phanvantai.github.io`
  on Cloudflare (taiphanvan.dev). The listing draft already uses `https://littlemark.taiphanvan.dev/…`
- [x] App Store metadata en/vi/ja (`APP_STORE_METADATA.md`) and saved as the Shipdeck listing draft
  (name, subtitle, promo, keywords, description, URLs, copyright, review contact + notes, manual release)
- [ ] Push the listing draft to App Store Connect (`asc.pushListing`, needs your approval) — after the site is live
- [ ] Review contact phone number (App Review needs one; not in the draft)
- [ ] Category: Lifestyle / Photo & Video · Age rating 4+ · App Privacy "Data Not Collected" · Free, all countries · EU trader status
- [x] Screenshots 6.9" en/vi/ja (`screenshots/appstore/`, taken by `AppStoreScreenshots` UI test)
- [ ] Upload screenshots to App Store Connect
- [ ] **Upload build 9** (blocked — needs you): `xcodebuild` has no Apple account ("No Accounts") and no
  Apple Distribution certificate on this Mac. Either archive in Xcode (Product → Archive → Distribute),
  or fix the Xcode Cloud workflow "Build main" (it still builds scheme **Moments**; the scheme is now
  **Littlemark**) and merge `develop` → `main`
- [ ] Select build 9 for version 1.0 (build 3 attached now has expired)
- [ ] TestFlight on a real device + device QC (launch < 1s, smooth scrolling with hundreds of moments)
- [ ] Optional: turn off iCloud + Push Notifications on the App ID (the app no longer uses them)

## Phase C — Submit

- [ ] Submit 1.0 for review
- [ ] Release (manual release is set — release when you're ready after approval)

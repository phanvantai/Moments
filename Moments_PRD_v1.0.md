# MOMENTS

## Personal Moment Keeper

**Product Requirements Document**
Version 1.0 · March 2026
Platform: iOS (Native – SwiftUI)

---

## 1. Overview

### 1.1 Vision

Moments là một ứng dụng iOS native giúp mọi người lưu giữ những khoảnh khắc đáng nhớ trong cuộc sống một cách đơn giản, nhanh chóng và thông minh. Không phức tạp, không rườm rà – chỉ tập trung vào việc ghi lại và lưu trữ những khoảnh khắc có ý nghĩa với bạn.

### 1.2 Problem Statement

Các app hiện tại trên thị trường thuộc hai nhóm chính:

- **Baby milestone trackers** (Sprouty, BabyPage, Qeepsake): chỉ phục vụ bố mẹ có con nhỏ, quá nặng về tracking (ngủ, ăn, tã, cân nặng), subscription đắt.
- **General journal apps** (Apple Journal, Day One, Journey): quá generic, đòi hỏi người dùng phải viết nhiều, không tối ưu cho việc "capture nhanh một khoảnh khắc rồi quay lại cuộc sống".

Chưa có app nào thật sự đơn giản chỉ tập trung vào: mở lên → chụp/quay → thêm vài dòng text hoặc voice → xong. Dành cho tất cả mọi người, không giới hạn bởi độ tuổi hay hoàn cảnh.

### 1.3 Target Users

Tất cả những ai muốn lưu giữ khoảnh khắc cuộc sống một cách đơn giản — bố mẹ ghi lại con lớn lên, người trẻ lưu kỷ niệm bạn bè và du lịch, hay bất kỳ ai bắt đầu nhận ra giá trị của từng khoảnh khắc nhỏ trong đời.

### 1.4 Motivation

Những khoảnh khắc rồi sẽ trôi đi. Nhưng thay vì để chúng tan dần trong ký ức, hãy ghi lại ngay với Moments. Mỗi khoảnh khắc — dù vui hay buồn — cũng là một phần của chúng ta, định hình nên con người chúng ta, là thứ khiến chúng ta thật sự sống.

*Every moment matters.*

---

## 2. Data Model

Thiết kế ưu tiên sự đơn giản cho MVP, nhưng cấu trúc sẵn sàng mở rộng cho các tính năng social trong tương lai (profile, sharing, reactions, comments). Các entity đánh dấu *(v1.x)* hoặc *(future)* chưa cần implement trong MVP nhưng đã được tính trong thiết kế.

### 2.1 User (local-first, future: multi-user)

| Field | Type | Description |
| --- | --- | --- |
| id | UUID | Unique identifier |
| displayName | String | Tên hiển thị |
| avatarPath | String? | Ảnh đại diện (local file) |
| createdAt | Date | Ngày tạo account |
| homeLocation | Location? | Vị trí "nhà" để tính khoảng cách travel *(v1.x)* |

*MVP: chỉ có 1 user mặc định, không cần login. Sau này mở rộng thành multi-user / social profile.*

### 2.2 Moment Entity

| Field | Type | Description |
| --- | --- | --- |
| id | UUID | Unique identifier, primary key |
| userId | UUID | Foreign key → User (MVP: mặc định 1 user) |
| createdAt | Date | Thời gian tạo moment |
| updatedAt | Date | Thời gian cập nhật cuối |
| title | String? | Tiêu đề ngắn (optional, có thể auto-generate từ text) |
| text | String? | Mô tả chi tiết bằng text |
| mediaItems | [MediaItem] | Mảng ảnh và video đính kèm (xem 2.3) |
| voiceNote | VoiceNote? | Ghi âm giọng nói (xem 2.4) |
| location | Location? | Địa điểm ghi nhận (xem 2.5) |
| categories | [Category] | Phân loại tự động + user confirm (xem 2.6) |
| tags | [String] | Custom tags tự do của user |
| isFavorite | Bool | Đánh dấu yêu thích, default = false |
| weather | Weather? | Thời tiết tại thời điểm ghi (auto từ API, xem 2.7) |
| visibility | Enum | .private \| .shared \| .public — default = .private *(future)* |

### 2.3 MediaItem

| Field | Type | Description |
| --- | --- | --- |
| id | UUID | Unique identifier |
| momentId | UUID | Foreign key → Moment |
| type | Enum | .photo \| .video |
| filePath | String | Đường dẫn local file trong app sandbox |
| thumbnailPath | String? | Thumbnail cho video (auto-generate) |
| duration | TimeInterval? | Thời lượng video (chỉ áp dụng cho .video) |
| width | Int | Chiều rộng ảnh/video (pixels) |
| height | Int | Chiều cao ảnh/video (pixels) |
| sortOrder | Int | Thứ tự hiển thị trong moment |

### 2.4 VoiceNote

| Field | Type | Description |
| --- | --- | --- |
| filePath | String | Đường dẫn file audio (.m4a) |
| duration | TimeInterval | Thời lượng ghi âm |
| transcript | String? | AI transcribe voice → text (on-device Speech framework) |

### 2.5 Location

| Field | Type | Description |
| --- | --- | --- |
| latitude | Double | Vĩ độ |
| longitude | Double | Kinh độ |
| name | String? | Tên địa điểm (reverse geocode hoặc user nhập) |
| address | String? | Địa chỉ đầy đủ (auto từ CLGeocoder) |
| placeType | String? | Loại địa điểm: home, park, hospital, restaurant... |

### 2.6 Category (Predefined)

| Icon | Key | Label | Auto-detect signals |
| --- | --- | --- | --- |
| ⭐ | first-time | Lần đầu tiên | Keywords: đầu tiên, lần đầu, biết... |
| 🏆 | milestone | Cột mốc | Keywords: tuổi, sinh nhật, tháng... |
| ☀️ | daily | Hàng ngày | Default khi không match category khác |
| 🌳 | outdoor | Ngoài trời | Location type: park, beach; Vision: outdoor scene |
| 👨‍👩‍👧 | family | Gia đình | Keywords: ông, bà, ba, mẹ, gia đình |
| 🏥 | health | Sức khoẻ | Location: hospital; Keywords: khám, tiêm, ốm |
| ✈️ | travel | Du lịch | Location xa nhà > 50km; Keywords: du lịch, trip |
| 🍼 | food | Ăn uống | Location: restaurant; Vision: food; Keywords: ăn, sữa |
| 🎮 | play | Vui chơi | Keywords: chơi, đồ chơi; Vision: playground |
| 📚 | learn | Học hỏi | Keywords: nói, đọc, viết, học, biết |

*Expandable: user có thể tạo custom category trong tương lai.*

### 2.7 Weather (Auto-fetch)

| Field | Type | Description |
| --- | --- | --- |
| condition | String | Sunny, Cloudy, Rainy, Stormy... |
| temperature | Double | Nhiệt độ (°C) |
| icon | String | SF Symbol name (sun.max, cloud.rain...) |

### 2.8 Future-ready Entities (chưa implement trong MVP)

Những entity này chưa cần build, nhưng data model đã tính sẵn để khi mở rộng không phải restructure:

| Entity | Mục đích | Khi nào cần |
| --- | --- | --- |
| Reaction | Emoji reactions trên moment (❤️ 😢 🔥) | Social features |
| Comment | Bình luận trên shared moments | Social features |
| Collection | Nhóm moments thành album/bộ sưu tập | v1.x |
| SharedMoment | Link sharing với permission control | Sharing features |

---

## 3. Smart Categorization

Hệ thống phân loại thông minh kết hợp nhiều tín hiệu để tự động gợi ý categories cho mỗi moment. Toàn bộ xử lý chạy on-device, không cần internet.

### 3.1 Signal Sources

1. **Vision Framework:** Phân tích ảnh/video để nhận diện scene (outdoor, indoor, food), objects (baby, toys, animals), và activities.
2. **NLP (NaturalLanguage framework):** Phân tích text description và voice transcript để tìm keywords match với các category.
3. **Location Context:** Loại địa điểm (park → outdoor, hospital → health, restaurant → food). Khoảng cách từ nhà > 50km → travel.
4. **Combine & Score:** Kết hợp tất cả signals, tính confidence score (0–100%), chỉ suggest categories có confidence ≥ 60%.

### 3.2 User Interaction

App gợi ý categories dưới dạng badges đã được pre-select. User chỉ cần:

- Tap confirm để chấp nhận gợi ý của AI
- Tap để bỏ bớt hoặc thêm category khác
- Không bao giờ bắt buộc user phải tự gõ tag từ đầu

---

## 4. Features (MVP v1.0)

Chỉ tập trung vào 2 việc duy nhất: **tạo moment** và **xem lại moments**. Mọi thứ khác để sau.

### 4.1 Tạo Moment

Nguyên tắc thiết kế: càng ít thao tác càng tốt. Mục tiêu là từ lúc mở app đến lúc lưu xong moment chỉ trong vài giây.

**Flow:** Mở app → Tap nút (+) → Chọn 1 trong 3 cách capture:

| Lựa chọn | Mô tả |
| --- | --- |
| 📷 Camera | Mở camera để chụp ảnh hoặc quay video |
| 🎙️ Voice | Bật mic ghi âm voice note ngay |
| 🖼️ Thư viện | Chọn photo/video có sẵn từ gallery |

Sau khi capture xong → màn hình review hiện ra → Tap "Lưu".

**Điều kiện lưu:** chỉ cần tối thiểu **1 media** (ảnh, video, hoặc voice note). Không bắt buộc phải có đủ cả ảnh lẫn text lẫn voice.

**Những gì tự động** (user không cần làm gì):

- Timestamp — gắn ngay lúc tạo
- Location — auto GPS + reverse geocode hiển thị tên địa điểm
- Weather — auto fetch từ WeatherKit
- Categories — AI gợi ý dựa trên content + location

**Những gì user có thể thêm** (optional, không bắt buộc):

- Thêm text mô tả
- Thêm media khác (đã chụp ảnh → có thể ghi thêm voice, hoặc ngược lại)
- Điều chỉnh categories do AI gợi ý
- Thêm custom tags

**Ví dụ các trường hợp sử dụng:**

- Nhanh nhất: tap (+) → chụp ảnh → tap "Lưu" = **2 taps, vài giây**
- Chỉ voice: tap (+) → ghi âm "con gái vừa biết đi!" → tap "Lưu" = **cũng chỉ vài giây**
- Đầy đủ: tap (+) → chọn ảnh từ gallery → thêm text → ghi voice → adjust tags → tap "Lưu"

Mọi thứ khác đã được app tự động lo. User muốn thêm chi tiết thì thêm, không thì thôi.

### 4.2 Xem Moments

Hai cách xem:

- **Timeline** — màn hình chính. Horizontal timeline với các nodes theo thứ tự thời gian. Scroll để duyệt, tap vào node để xem chi tiết moment (media full-screen, text, voice player, mini map, weather, categories).
- **Grid** — xem dạng lưới cards 2 cột. Thích hợp khi có nhiều moments, dễ scan bằng mắt.

### 4.3 Vòng sau (chưa implement)

Tất cả những tính năng dưới đây đã được tính trong data model nhưng chưa build trong MVP: Search / Filter, On This Day, Map View, Favorite, iCloud Sync, Share Moment, Video Recap, Widget, People, Mood, Collections / Albums, Social features (reactions, comments, public moments).

---

## 5. Tech Stack

| Layer | Technology |
| --- | --- |
| UI Framework | SwiftUI (iOS 17+) |
| Architecture | MVVM + Swift Observation (@Observable) |
| Local Storage | SwiftData (Core Data replacement, native Swift) |
| Media Storage | FileManager – app sandbox (Documents directory) |
| Camera / Gallery | PhotosUI (PhotosPicker) + AVFoundation |
| Location | CoreLocation + CLGeocoder (reverse geocode) |
| Voice Recording | AVAudioRecorder (.m4a format) |
| Voice Transcription | Speech framework (on-device, SFSpeechRecognizer) |
| Image Analysis | Vision framework (VNClassifyImageRequest) |
| NLP | NaturalLanguage framework (NLTagger, keyword extraction) |
| Weather | WeatherKit (Apple native, free tier 500K calls/month) |
| Cloud Sync (v1.x) | CloudKit (free with Apple Developer account) |

### 5.1 Why SwiftData?

SwiftData là lựa chọn tối ưu cho app này vì: native Swift (không cần ObjC bridging), tích hợp sẵn với SwiftUI (@Query macro), hỗ trợ CloudKit sync out-of-the-box, và lightweight hơn Core Data rất nhiều về boilerplate code.

### 5.2 Project Structure

Clean Architecture with three layers (Domain → Data → Presentation), strict dependency rule (outer layers depend inward).

```bash
Moments/
├── MomentsApp.swift                        # App entry point
├── ContentView.swift                       # Root navigation + FAB + view mode toggle
│
├── DI/
│   └── DependencyContainer.swift           # Wires all dependencies, ViewModel factories
│
├── Domain/                                 # Pure Swift, no framework imports
│   ├── Entities/
│   │   ├── Moment.swift                    # Core entity: media, voice, location, categories, tags
│   │   ├── MediaItem.swift                 # Photo/video with file paths
│   │   ├── VoiceNote.swift                 # Audio recording with transcript
│   │   ├── Location.swift                  # Lat/lng + name
│   │   ├── Weather.swift                   # Temperature, condition, icon
│   │   ├── Category.swift                  # MomentCategory with emoji, color, keywords
│   │   ├── User.swift                      # User entity (MVP: single default user)
│   │   └── MomentVisibility.swift          # Private/shared enum
│   ├── Repositories/
│   │   ├── MomentRepositoryProtocol.swift  # CRUD for moments
│   │   └── MediaRepositoryProtocol.swift   # Save/delete media files
│   ├── Services/
│   │   ├── PermissionServiceProtocol.swift  # Camera, mic, photo library, location, speech
│   │   ├── LocationServiceProtocol.swift    # Current location lookup
│   │   ├── WeatherServiceProtocol.swift     # Weather for location
│   │   └── CategoryEngineProtocol.swift     # Multi-signal category suggestion
│   └── UseCases/
│       ├── CreateMomentUseCase.swift        # Validates ≥1 media, persists moment
│       ├── FetchMomentsUseCase.swift         # Load all moments sorted by date
│       └── DeleteMomentUseCase.swift         # Cascade-deletes media files + moment
│
├── Data/                                   # Framework imports allowed
│   ├── SwiftData/
│   │   ├── SDMoment.swift                  # @Model class for persistence
│   │   ├── SDMediaItem.swift               # @Model class for media
│   │   ├── SDUser.swift                    # @Model class for user
│   │   └── MomentMapper.swift              # Domain ↔ SwiftData bidirectional mapping
│   ├── Repositories/
│   │   ├── MomentRepository.swift          # SwiftData implementation
│   │   └── MediaRepository.swift           # File system implementation
│   └── Services/
│       ├── PermissionService.swift          # AVFoundation/Photos/CoreLocation permissions
│       ├── LocationService.swift            # CLLocationManager wrapper
│       ├── WeatherService.swift             # WeatherKit integration
│       ├── CategoryEngine.swift             # NLP + Vision + Location analysis
│       ├── MediaFileService.swift           # File I/O for media storage
│       ├── PermissionStatusMapper.swift     # Maps system status to domain enum
│       └── AVThumbnailGenerator.swift       # Video thumbnail extraction
│
└── Presentation/                           # SwiftUI
    ├── Models/
    │   ├── ViewMode.swift                  # .timeline / .grid enum
    │   ├── CreateMomentStep.swift          # .captureMenu / .camera / .voice / .gallery / .review
    │   └── GalleryMediaResult.swift        # Photo picker result wrapper
    ├── ViewModels/
    │   ├── TimelineViewModel.swift         # Main list state, view mode, delete
    │   ├── CreateMomentViewModel.swift     # Capture flow, permissions, smart features, save
    │   ├── MomentDetailViewModel.swift     # Detail sheet data accessors
    │   ├── GridCardViewModel.swift         # Grid card computed properties
    │   ├── TimelineNodeViewModel.swift     # Timeline node computed properties
    │   ├── MediaViewerViewModel.swift      # Paged media viewer state
    │   └── VoicePlayerViewModel.swift      # Audio playback state
    ├── Views/
    │   ├── TimelineView.swift              # Horizontal scrolling timeline
    │   ├── GridView.swift                  # 2-column grid with date sections
    │   ├── TimelineNodeView.swift          # Timeline card with thumbnail + category node
    │   ├── GridCardView.swift              # Grid card with cached thumbnail
    │   ├── MomentDetailView.swift          # Detail sheet: media, text, map, weather
    │   ├── MediaViewer.swift               # Paged media viewer with pinch-to-zoom
    │   ├── CreateMomentView.swift          # Capture flow coordinator
    │   ├── ReviewMomentView.swift          # Review + edit before save (+ FlowLayout)
    │   ├── CameraView.swift                # AVCaptureSession photo/video capture
    │   ├── VoiceRecorderView.swift         # Recording with waveform + live transcription
    │   ├── VoicePlayerView.swift           # Playback with waveform progress
    │   ├── CaptureMenuView.swift           # Camera/Voice/Gallery option menu
    │   ├── GalleryPickerView.swift         # PhotosPicker wrapper
    │   ├── EmptyMomentsView.swift          # Shared empty state component
    │   ├── CategoryBadgeView.swift         # Toggleable category chip
    │   ├── WeatherBadgeView.swift          # Weather condition display
    │   └── LocationBadgeView.swift         # Location name with remove button
    └── Utils/
        ├── BrandColors.swift               # Warm coral accent, gradient definitions
        ├── HapticManager.swift             # Contextual haptic feedback
        ├── ThumbnailCache.swift            # LRU image cache (100 items, 50MB)
        ├── MomentDisplayHelper.swift       # Display title, category color, media helpers
        ├── DurationFormatter.swift         # M:SS and MM:SS formatting
        └── AudioLevelNormalizer.swift       # Microphone dB → 0..1 normalization
```

---

## 6. Permissions & UX Handling

App sử dụng nhiều quyền hệ thống. Nguyên tắc: **chỉ hỏi khi cần, giải thích rõ lý do, và luôn có fallback nếu user từ chối.**

### 6.1 Danh sách quyền

| Permission | Khi nào hỏi | Lý do hiển thị cho user | Nếu từ chối |
| --- | --- | --- | --- |
| 📷 Camera | User tap "Camera" lần đầu | "Để chụp ảnh và quay video cho khoảnh khắc của bạn" | Ẩn nút Camera, chỉ hiện Thư viện và Voice |
| 🖼️ Photo Library | User tap "Thư viện" lần đầu | "Để chọn ảnh và video có sẵn" | Ẩn nút Thư viện, chỉ hiện Camera và Voice |
| 🎙️ Microphone | User tap "Voice" lần đầu | "Để ghi lại giọng nói của bạn" | Ẩn nút Voice, chỉ hiện Camera và Thư viện |
| 📍 Location | Sau khi capture media đầu tiên | "Để ghi lại địa điểm khoảnh khắc này — sau này bạn có thể quay lại" | Moment lưu không có location, không hỏi lại liên tục |
| 🗣️ Speech Recognition | Khi user ghi voice note lần đầu | "Để chuyển giọng nói thành text tự động" | Voice note lưu audio, không có transcript |

### 6.2 Nguyên tắc UX

- **Lazy permission:** không hỏi tất cả quyền khi mở app lần đầu. Chỉ hỏi đúng lúc user cần tính năng đó.
- **Graceful degradation:** app vẫn hoạt động bình thường nếu user từ chối bất kỳ quyền nào. Tính năng liên quan bị ẩn hoặc giảm chức năng, không crash, không hiện popup liên tục.
- **Pre-prompt (nếu cần):** trước khi trigger system permission dialog, có thể hiện một màn hình giải thích ngắn gọn tại sao cần quyền đó. Tuy nhiên, tuyệt đối **không dùng nút "Cho phép" / "Từ chối"** trên màn hình này để tránh nhầm lẫn với system dialog — thay vào đó dùng nút trung tính như "Tiếp tục" hoặc "Đã hiểu". Không dùng bất kỳ hình thức nào mang tính manipulative để ảnh hưởng quyết định của user (theo Apple HIG).
- **Retry path:** nếu đã từ chối, khi user tap lại tính năng đó, hiện hướng dẫn nhẹ nhàng: "Bạn có thể bật lại trong Cài đặt → Moments" kèm nút deep link đến Settings.

---

## 7. UI & Design Direction

### 7.1 Design Principles

- **Minimal UI, maximal content:** giao diện biến mất khi không cần, nhường chỗ cho ảnh, video, và ký ức.
- **Delight in details:** micro-interactions và animations ở mọi nơi — mở moment, transition giữa timeline và grid, capture flow, lưu thành công.
- **Warm & personal:** tone màu ấm, typography mềm mại, cảm giác như một cuốn album cá nhân chứ không phải một công cụ.

### 7.2 Animation & Micro-interactions

| Interaction | Animation |
| --- | --- |
| Mở app | Staggered reveal các nodes trên timeline |
| Tap (+) | FAB button morph thành capture menu (spring animation) |
| Capture xong | Media slide up + review panel fade in |
| Tap "Lưu" | Confetti / particle burst nhẹ + node mới appear trên timeline với scale bounce |
| Tap node trên timeline | Node scale up + detail panel slide up từ dưới |
| Switch Timeline ↔ Grid | Smooth layout transition (matchedGeometryEffect) |
| Pull to refresh | Subtle elastic bounce |
| Xoá moment | Swipe + fade out + các node còn lại shift smooth |

### 7.3 Typography & Color

- **Font:** SF Pro Rounded — ấm, thân thiện, native iOS
- **Color palette:** warm neutrals làm base, mỗi category có accent color riêng (xem bảng 2.6), gradient nhẹ cho backgrounds
- **Dark mode:** hỗ trợ đầy đủ, adaptive colors

---

## 8. Non-functional Requirements

| Requirement | Detail |
| --- | --- |
| Platform | iOS 17.0+ (iPhone only cho MVP, iPad vòng sau) |
| Privacy | 100% on-device data. Không gửi dữ liệu lên server. AI chạy local (Vision, NLP, Speech). |
| Performance | App launch < 1s. Tạo moment < 3 taps từ màn hình chính. Timeline scroll 60fps. Animations 60fps. |
| Storage | Media lưu original quality. Thumbnails auto-generated. Không giới hạn số moments. |
| Offline | App hoạt động hoàn toàn offline. Weather lấy khi có mạng, bỏ qua nếu không. |
| Accessibility | VoiceOver support, Dynamic Type, high contrast mode. |
| Localization | Tiếng Việt (primary), English (secondary). |

---

## 9. Development Milestones

| Phase | Timeline | Deliverables |
| --- | --- | --- |
| Phase 1 | Week 1–2 | Data model (SwiftData) + Create Moment flow (camera, voice, gallery) + Local storage |
| Phase 2 | Week 3–4 | Timeline view + Grid view + Moment Detail screen + Animations |
| Phase 3 | Week 5–6 | Smart categorization (Vision + NLP) + Location + Weather + Permission handling |
| Phase 4 | Week 7–8 | Polish UI + Micro-interactions + Dark mode + Bug fixes + Performance tuning |
| Launch | Week 9 | TestFlight beta → App Store submission |

---

## 10. Product Roadmap

### v1.0 — MVP (current)

*Mục tiêu: App hoạt động, 2 tính năng core chạy tốt, lên App Store.*

- Tạo moment (camera, voice, gallery)
- Xem moments (timeline, grid, detail)
- Smart categorization (on-device AI)
- Auto location + weather
- Offline-first, 100% privacy

### v1.x — Personal Enhancement

*Mục tiêu: Biến app thành công cụ cá nhân mạnh mẽ hơn. Giữ chân user hàng ngày.*

- Search & Filter (theo category, thời gian, địa điểm, full-text)
- Favorite moments
- On This Day (nhắc kỷ niệm năm trước — push notification)
- Collections / Albums (nhóm moments thành bộ sưu tập)
- People (tag ai có mặt trong khoảnh khắc)
- Mood (ghi cảm xúc lúc tạo moment)
- iCloud Sync (đồng bộ multi-device qua CloudKit)
- Home Screen Widget (random moment hoặc On This Day)
- Map View (xem tất cả moments trên bản đồ)

### v2.0 — Share & Relive

*Mục tiêu: Mở rộng từ cá nhân sang chia sẻ với người thân. Tăng emotional value.*

- Share Moment (gửi qua Messages, AirDrop, link)
- Video Recap (auto-generate montage từ moments trong khoảng thời gian)
- Collaborative Moments (mời người khác thêm moment vào cùng Collection)
- Export Album (xuất PDF / photo book đẹp)
- iPad support
- Apple Watch quick capture (chụp nhanh từ đồng hồ)

### v3.0 — Social Platform

*Mục tiêu: Trở thành mạng xã hội kiểu mới — chia sẻ khoảnh khắc thật, không filters, không likes chạy đua.*

- User profiles (public / private)
- Public moments (visibility control)
- Reactions (emoji reactions thay vì likes — ❤️ 😢 🔥 👏)
- Comments trên shared moments
- Follow / Following (theo dõi moments của người khác)
- Discovery feed (khám phá moments công khai theo location, category)
- Privacy-first: end-to-end encryption cho shared content
- Backend migration: Data layer chuyển từ SwiftData local → server API (Clean Architecture cho phép swap mà không đụng Domain + Presentation)

### Nguyên tắc phát triển

- Mỗi version phải **hoàn chỉnh và có giá trị riêng**. v1.0 đã đủ dùng, không cần v2.0 để có ý nghĩa.
- **Không thêm features chỉ vì có thể**. Mỗi feature phải trả lời: "điều này giúp user lưu giữ khoảnh khắc tốt hơn không?"
- **Privacy là core value**, không bao giờ thỏa hiệp. Dù trở thành social platform, user data vẫn được bảo vệ tuyệt đối.
- **Clean Architecture** đảm bảo codebase scale được từ local-only app sang full social platform mà không cần rewrite.

---

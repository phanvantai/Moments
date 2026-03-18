import SwiftUI
import AVKit

struct MediaViewer: View {
    @Bindable var viewModel: MediaViewerViewModel

    var body: some View {
        VStack(spacing: 8) {
            TabView(selection: $viewModel.currentPage) {
                ForEach(Array(viewModel.mediaItems.enumerated()), id: \.element.id) { index, item in
                    mediaPage(for: item)
                        .tag(index)
                }
            }
            .tabViewStyle(.page(indexDisplayMode: viewModel.showPagerDots ? .always : .never))

            if viewModel.showPagerDots {
                pageIndicator
            }
        }
    }

    // MARK: - Media Page

    @ViewBuilder
    private func mediaPage(for item: MediaItem) -> some View {
        switch item.type {
        case .photo:
            ZoomableImageView(filePath: item.filePath)
        case .video:
            videoView(for: item)
        }
    }

    // MARK: - Video Player

    private func videoView(for item: MediaItem) -> some View {
        let fileURL = viewModel.mediaFileURL(for: item)
        return VideoPlayerView(url: fileURL, audioSessionManager: viewModel.audioSessionManager)
    }

    // MARK: - Page Indicator

    private var pageIndicator: some View {
        HStack(spacing: 6) {
            ForEach(0..<viewModel.pageCount, id: \.self) { index in
                Circle()
                    .fill(index == viewModel.currentPage ? Color.primary : Color.secondary.opacity(0.3))
                    .frame(width: 6, height: 6)
            }
        }
    }
}

// MARK: - Zoomable Image View

struct ZoomableImageView: View {
    let filePath: String
    @State private var scale: CGFloat = 1.0
    @State private var lastScale: CGFloat = 1.0
    @State private var offset: CGSize = .zero
    @State private var lastOffset: CGSize = .zero

    var body: some View {
        let fileURL = MomentDisplayHelper.mediaFileURL(filePath)
        AsyncImage(url: fileURL) { phase in
            switch phase {
            case .success(let image):
                image
                    .resizable()
                    .scaledToFit()
                    .scaleEffect(scale)
                    .offset(offset)
                    .gesture(pinchGesture)
                    .gesture(doubleTapGesture)
                    .gesture(dragGesture)
            case .failure:
                imagePlaceholder
            default:
                ProgressView()
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
    }

    // MARK: - Gestures

    private var pinchGesture: some Gesture {
        MagnifyGesture()
            .onChanged { value in
                let delta = value.magnification / lastScale
                lastScale = value.magnification
                scale = min(max(scale * delta, 1), 5)
            }
            .onEnded { _ in
                lastScale = 1.0
                if scale <= 1 {
                    withAnimation(.spring(response: 0.3)) {
                        scale = 1
                        offset = .zero
                    }
                }
            }
    }

    private var doubleTapGesture: some Gesture {
        TapGesture(count: 2)
            .onEnded {
                withAnimation(.spring(response: 0.3)) {
                    if scale > 1 {
                        scale = 1
                        offset = .zero
                    } else {
                        scale = 2.5
                    }
                }
            }
    }

    private var dragGesture: some Gesture {
        DragGesture()
            .onChanged { value in
                if scale > 1 {
                    offset = CGSize(
                        width: lastOffset.width + value.translation.width,
                        height: lastOffset.height + value.translation.height
                    )
                }
            }
            .onEnded { _ in
                lastOffset = offset
                if scale <= 1 {
                    withAnimation(.spring(response: 0.3)) {
                        offset = .zero
                        lastOffset = .zero
                    }
                }
            }
    }

    private var imagePlaceholder: some View {
        ZStack {
            Rectangle().fill(Color.secondary.opacity(0.1))
            Image(systemName: "photo")
                .font(.largeTitle)
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Video Player View

private struct VideoPlayerView: View {
    let url: URL
    let audioSessionManager: AudioSessionManaging
    @State private var player: AVPlayer?
    @Environment(\.scenePhase) private var scenePhase

    var body: some View {
        VideoPlayer(player: player)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .onAppear {
                audioSessionManager.configureForPlayback()
                if player == nil {
                    player = AVPlayer(url: url)
                }
            }
            .onDisappear {
                player?.pause()
                player = nil
            }
            .onChange(of: scenePhase) { _, newPhase in
                if newPhase != .active {
                    player?.pause()
                }
            }
    }
}

import SwiftUI

struct VoicePlayerView: View {
    @Bindable var viewModel: VoicePlayerViewModel

    var body: some View {
        VStack(spacing: 8) {
            HStack(spacing: 12) {
                Button {
                    viewModel.togglePlayback()
                } label: {
                    Image(systemName: viewModel.isPlaying ? "pause.circle.fill" : "play.circle.fill")
                        .font(.system(size: 36))
                        .foregroundStyle(.blue)
                }

                waveformView

                VStack(alignment: .trailing, spacing: 2) {
                    Text(viewModel.currentTimeFormatted)
                        .font(.system(.caption, design: .monospaced))
                        .foregroundStyle(.primary)
                    Text(viewModel.totalDurationFormatted)
                        .font(.system(.caption2, design: .monospaced))
                        .foregroundStyle(.secondary)
                }
            }

            if let transcript = viewModel.transcript, viewModel.hasTranscript {
                Text(transcript)
                    .font(.system(.caption, design: .rounded))
                    .foregroundStyle(.secondary)
                    .lineLimit(3)
                    .frame(maxWidth: .infinity, alignment: .leading)
            }
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.ultraThinMaterial)
        )
        .onDisappear {
            viewModel.stopPlayback()
        }
    }

    // MARK: - Waveform

    private var waveformView: some View {
        GeometryReader { geometry in
            HStack(spacing: 2) {
                ForEach(0..<waveformBarCount(for: geometry.size.width), id: \.self) { index in
                    RoundedRectangle(cornerRadius: 1)
                        .fill(barColor(at: index))
                        .frame(width: 3, height: barHeight(at: index, totalHeight: geometry.size.height))
                }
            }
            .frame(maxHeight: .infinity, alignment: .center)
        }
        .frame(height: 30)
    }

    private func waveformBarCount(for width: CGFloat) -> Int {
        max(1, Int(width / 5))
    }

    private func barHeight(at index: Int, totalHeight: CGFloat) -> CGFloat {
        let seed = Double(index) * 1.3
        let height = abs(sin(seed)) * 0.7 + 0.3
        return totalHeight * height
    }

    private func barColor(at index: Int) -> Color {
        let barProgress = Double(index) / Double(max(1, waveformBarCount(for: 200) - 1))
        return barProgress <= viewModel.progress ? .blue : .blue.opacity(0.2)
    }
}

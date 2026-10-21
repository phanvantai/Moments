import Foundation

enum AudioLevelNormalizer {
    /// Normalizes a decibel level (typically -160 to 0) to a 0...1 range.
    /// Uses a range of -60 dB to 0 dB for normalization.
    static func normalize(decibels: Float) -> CGFloat {
        CGFloat(max(0, (decibels + 60) / 60))
    }

    /// Appends a normalized level to the levels array, keeping at most `maxCount` entries.
    static func appendLevel(_ level: CGFloat, to levels: inout [CGFloat], maxCount: Int = 40) {
        levels.append(level)
        if levels.count > maxCount {
            levels.removeFirst()
        }
    }
}

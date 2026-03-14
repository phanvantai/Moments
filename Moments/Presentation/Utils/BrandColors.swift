import SwiftUI

enum BrandColors {
    /// Warm coral accent — primary brand color
    static let accent = Color(red: 0.96, green: 0.52, blue: 0.39)

    /// Lighter variant for backgrounds and tints
    static let accentLight = Color(red: 0.96, green: 0.52, blue: 0.39).opacity(0.15)

    /// Gradient for the FAB and primary CTAs
    static let fabGradient = LinearGradient(
        colors: [
            Color(red: 0.96, green: 0.52, blue: 0.39),
            Color(red: 0.91, green: 0.38, blue: 0.35)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
}

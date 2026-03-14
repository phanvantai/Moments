import SwiftUI

enum BrandColors {
    // MARK: - Primary Palette

    /// Warm coral accent — primary brand color
    static let accent = Color(red: 0.96, green: 0.52, blue: 0.39)

    /// Deeper coral for pressed states and emphasis
    static let accentDark = Color(red: 0.85, green: 0.38, blue: 0.28)

    /// Lighter variant for backgrounds and tints
    static let accentLight = Color(red: 0.96, green: 0.52, blue: 0.39).opacity(0.15)

    /// Soft warm background tint
    static let warmBackground = Color(red: 0.99, green: 0.97, blue: 0.95)

    // MARK: - Semantic Colors

    /// Soft surface for cards and elevated elements
    static let cardSurface = Color(red: 1.0, green: 0.99, blue: 0.98)

    /// Subtle border color for cards
    static let cardBorder = Color(red: 0.92, green: 0.90, blue: 0.87)

    /// Muted text for secondary information
    static let textSecondary = Color(red: 0.55, green: 0.52, blue: 0.50)

    /// Section header text color
    static let sectionHeader = Color(red: 0.45, green: 0.42, blue: 0.40)

    // MARK: - Category Tints (softer, harmonized palette)

    static let categoryYellow = Color(red: 0.95, green: 0.85, blue: 0.45)
    static let categoryOrange = Color(red: 0.96, green: 0.65, blue: 0.38)
    static let categoryBlue = Color(red: 0.40, green: 0.62, blue: 0.90)
    static let categoryGreen = Color(red: 0.42, green: 0.78, blue: 0.55)
    static let categoryPurple = Color(red: 0.65, green: 0.50, blue: 0.85)
    static let categoryRed = Color(red: 0.90, green: 0.45, blue: 0.45)
    static let categoryCyan = Color(red: 0.35, green: 0.75, blue: 0.82)
    static let categoryPink = Color(red: 0.92, green: 0.55, blue: 0.65)
    static let categoryIndigo = Color(red: 0.45, green: 0.42, blue: 0.80)
    static let categoryTeal = Color(red: 0.35, green: 0.72, blue: 0.68)

    // MARK: - Gradients

    /// Gradient for the FAB and primary CTAs
    static let fabGradient = LinearGradient(
        colors: [
            Color(red: 0.96, green: 0.52, blue: 0.39),
            Color(red: 0.91, green: 0.38, blue: 0.35)
        ],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )

    /// Subtle warm gradient for backgrounds
    static let warmGradient = LinearGradient(
        colors: [
            Color(red: 0.99, green: 0.97, blue: 0.95),
            Color(red: 0.97, green: 0.95, blue: 0.93)
        ],
        startPoint: .top,
        endPoint: .bottom
    )

    /// Timeline accent gradient
    static let timelineGradient = LinearGradient(
        colors: [
            accent.opacity(0.08),
            accent.opacity(0.20),
            accent.opacity(0.08)
        ],
        startPoint: .leading,
        endPoint: .trailing
    )
}

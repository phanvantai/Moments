import UIKit

enum HapticManager {
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        let generator = UIImpactFeedbackGenerator(style: style)
        generator.impactOccurred()
    }

    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(type)
    }

    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.selectionChanged()
    }

    // MARK: - App-specific Haptics

    /// FAB tap - medium impact
    static func fabTap() {
        impact(.medium)
    }

    /// Save success - success notification
    static func saveSuccess() {
        notification(.success)
    }

    /// Delete action - warning notification
    static func deleteWarning() {
        notification(.warning)
    }

    /// Category toggle - light impact
    static func categoryToggle() {
        impact(.light)
    }

    /// View mode toggle - light impact
    static func viewModeToggle() {
        impact(.light)
    }
}

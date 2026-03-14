import SwiftUI

struct CategoryBadgeView: View {
    let category: MomentCategory
    let isSelected: Bool
    let onToggle: () -> Void

    private var categoryColor: Color {
        MomentDisplayHelper.color(forCategoryKey: category.key)
    }

    var body: some View {
        Button(action: {
            HapticManager.categoryToggle()
            onToggle()
        }) {
            HStack(spacing: 5) {
                Text(category.emoji)
                    .font(.system(size: 14))
                Text(category.label)
                    .font(.system(.caption, design: .rounded, weight: .medium))
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 7)
            .background(
                Capsule()
                    .fill(isSelected ? categoryColor.opacity(0.15) : Color(.tertiarySystemFill))
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? categoryColor.opacity(0.4) : Color.clear, lineWidth: 1.5)
            )
            .foregroundStyle(isSelected ? categoryColor : .secondary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(category.emoji) \(category.label)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
        .animation(.easeOut(duration: 0.15), value: isSelected)
    }
}

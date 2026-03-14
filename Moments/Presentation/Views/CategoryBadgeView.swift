import SwiftUI

struct CategoryBadgeView: View {
    let category: MomentCategory
    let isSelected: Bool
    let onToggle: () -> Void

    var body: some View {
        Button(action: onToggle) {
            HStack(spacing: 4) {
                Text(category.emoji)
                    .font(.system(size: 14))
                Text(category.label)
                    .font(.system(.caption, design: .rounded))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(
                Capsule()
                    .fill(isSelected ? Color.blue.opacity(0.15) : Color.gray.opacity(0.1))
            )
            .overlay(
                Capsule()
                    .stroke(isSelected ? Color.blue.opacity(0.4) : Color.clear, lineWidth: 1)
            )
            .foregroundStyle(isSelected ? .primary : .secondary)
        }
        .buttonStyle(.plain)
        .accessibilityLabel("\(category.emoji) \(category.label)")
        .accessibilityAddTraits(isSelected ? .isSelected : [])
    }
}

import Testing
import Foundation
@testable import Littlemark

struct CategoryBadgeViewTests {
    @Test func test_categoryBadge_displaysEmojiAndLabel() {
        let category = MomentCategory.predefined[0] // first-time
        var toggled = false

        let view = CategoryBadgeView(
            category: category,
            isSelected: true,
            onToggle: { toggled = true }
        )

        #expect(category.emoji == "⭐")
        #expect(category.label == "Lần đầu tiên")
        // View exists without crashing
        _ = view.body
    }

    @Test func test_categoryBadge_selectedState() {
        let category = MomentCategory.predefined[0]

        let selectedView = CategoryBadgeView(
            category: category,
            isSelected: true,
            onToggle: {}
        )

        let unselectedView = CategoryBadgeView(
            category: category,
            isSelected: false,
            onToggle: {}
        )

        // Both render without crash
        _ = selectedView.body
        _ = unselectedView.body
    }

    @Test func test_categoryBadge_allPredefinedCategories() {
        for category in MomentCategory.predefined {
            let view = CategoryBadgeView(
                category: category,
                isSelected: true,
                onToggle: {}
            )
            // All predefined categories render without crash
            _ = view.body
        }
    }
}

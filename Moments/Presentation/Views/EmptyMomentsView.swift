import SwiftUI

struct EmptyMomentsView: View {
    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 48))
                .foregroundStyle(.secondary)
            Text("No moments yet")
                .font(.system(.title3, design: .rounded, weight: .semibold))
                .foregroundStyle(.primary)
            Text("Tap  +  to capture your first moment")
                .font(.system(.body, design: .rounded))
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

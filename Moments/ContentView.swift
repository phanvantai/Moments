import SwiftUI

struct ContentView: View {
    let container: DependencyContainer

    var body: some View {
        ZStack {
            VStack(spacing: 16) {
                Spacer()

                Text("Moments")
                    .font(.system(.largeTitle, design: .rounded, weight: .bold))

                Text("Every moment matters.")
                    .font(.system(.body, design: .rounded))
                    .foregroundStyle(.secondary)

                Spacer()
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            VStack {
                Spacer()
                HStack {
                    Spacer()
                    Button {
                        // FAB placeholder action
                    } label: {
                        Image(systemName: "plus")
                            .font(.title2.weight(.semibold))
                            .foregroundStyle(.white)
                            .frame(width: 56, height: 56)
                            .background(Circle().fill(.blue))
                            .shadow(color: .blue.opacity(0.3), radius: 8, y: 4)
                    }
                    .padding(.trailing, 24)
                    .padding(.bottom, 24)
                }
            }
        }
    }
}

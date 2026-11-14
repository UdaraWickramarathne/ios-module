import SwiftUI

// A small, calm colour palette
enum Palette {
    static let green = Color(red: 0.36, green: 0.72, blue: 0.47)
}

struct ContentView: View {
    var body: some View {
        VStack {
            Text("Tap Frenzy")
                .font(.headline)
                .foregroundStyle(.secondary)

            Spacer()

            gameView

            Spacer()
        }
        .padding()
    }

    // MARK: - Playing screen

    private var gameView: some View {
        VStack(spacing: 48) {
            scoreBoard
            tapButton
        }
    }

    private var scoreBoard: some View {
        VStack(spacing: 12) {
            Text("SCORE")
                .font(.caption.weight(.semibold))
                .tracking(2)
                .foregroundStyle(.secondary)

            Text("0")
                .font(.system(size: 80, weight: .heavy, design: .rounded))

            Text("tap to start")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    private var tapButton: some View {
        Button(action: {}) {
            Text("TAP")
                .font(.system(size: 44, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .frame(width: 200, height: 200)
                .background(
                    Circle()
                        .fill(Palette.green)
                        .shadow(color: Palette.green.opacity(0.4), radius: 20, y: 8)
                )
                .contentShape(Circle())
        }
        .buttonStyle(PressableStyle())
    }
}

// Shrinks a button slightly while it is held down, then springs back
struct PressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

#Preview {
    ContentView()
}

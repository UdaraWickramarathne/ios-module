import SwiftUI

// A small, calm colour palette
enum Palette {
    static let green = Color(red: 0.36, green: 0.72, blue: 0.47)
}

// How long one round lasts, in seconds
private let roundLength = 10

struct ContentView: View {
    // Step 3: score
    @State private var score = 0

    // Step 4: countdown timer that ticks every second
    @State private var timeRemaining = roundLength
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

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
        .onReceive(timer) { _ in
            tick()
        }
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

            Text("\(score)")
                .font(.system(size: 80, weight: .heavy, design: .rounded))

            ProgressView(value: Double(timeRemaining), total: Double(roundLength))
                .tint(Palette.green)
                .frame(width: 220)
                .animation(.linear(duration: 1), value: timeRemaining)

            Text("\(timeRemaining)s left")
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
        }
    }

    private var tapButton: some View {
        Button(action: tap) {
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

    // MARK: - Game logic

    private func tap() {
        score += 1
    }

    private func tick() {
        if timeRemaining > 0 {
            timeRemaining -= 1
        }
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

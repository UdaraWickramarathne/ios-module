import SwiftUI

// Step 5: the three phases of a game
enum GamePhase {
    case idle, playing, over
}

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

    // Step 5: current game phase
    @State private var phase: GamePhase = .idle

    var body: some View {
        VStack {
            Text("Tap Frenzy")
                .font(.headline)
                .foregroundStyle(.secondary)

            Spacer()

            switch phase {
            case .idle, .playing:
                gameView
                    .transition(.opacity)
            case .over:
                gameOverView
                    .transition(.scale(scale: 0.9).combined(with: .opacity))
            }

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

            Text(phase == .idle ? "tap to start" : "\(timeRemaining)s left")
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

    // MARK: - Game-over screen

    private var gameOverView: some View {
        VStack(spacing: 14) {
            Text("Time's up")
                .font(.system(size: 44, weight: .heavy, design: .rounded))

            Text("YOUR SCORE")
                .font(.caption.weight(.semibold))
                .tracking(2)
                .foregroundStyle(.secondary)

            Text("\(score)")
                .font(.system(size: 64, weight: .heavy, design: .rounded))
                .foregroundStyle(Palette.green)

            Button(action: resetGame) {
                Text("Play Again")
                    .font(.headline)
                    .foregroundStyle(.white)
                    .padding(.horizontal, 32)
                    .padding(.vertical, 14)
                    .background(Palette.green, in: Capsule())
            }
            .buttonStyle(PressableStyle())
            .padding(.top, 8)
        }
    }

    // MARK: - Game logic

    private func tap() {
        // Ignore stray taps once the round is over
        guard phase != .over else { return }

        // First tap starts the round: idle → playing
        if phase == .idle {
            phase = .playing
        }

        score += 1
    }

    private func tick() {
        guard phase == .playing else { return }

        if timeRemaining > 0 {
            timeRemaining -= 1
        }

        // Time's up: playing → over
        if timeRemaining == 0 {
            endGame()
        }
    }

    private func endGame() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            phase = .over
        }
    }

    private func resetGame() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            score = 0
            timeRemaining = roundLength
            phase = .idle
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

import SwiftUI

// Step 5: the three phases of a game
enum GamePhase {
    case idle, playing, over
}

// A small, calm colour palette
enum Palette {
    static let green = Color(red: 0.36, green: 0.72, blue: 0.47)
    static let amber = Color(red: 0.96, green: 0.69, blue: 0.30)
    static let red   = Color(red: 0.91, green: 0.39, blue: 0.37)
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

    // Step 6: best score, saved between app launches
    @AppStorage("highScore") private var highScore = 0
    @State private var isNewBest = false

    // Challenge C1: combo for fast taps
    @State private var combo = 1
    @State private var lastTap = Date.distantPast

    // Challenge C4: button shrinks with every tap
    @State private var buttonScale = 1.0

    // Used to switch to a side-by-side layout in landscape
    @Environment(\.verticalSizeClass) private var verticalSizeClass

    var body: some View {
        VStack {
            if verticalSizeClass != .compact {
                Text("Tap Frenzy")
                    .font(.headline)
                    .foregroundStyle(.secondary)
            }

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
        .sensoryFeedback(.impact(weight: .light), trigger: score)
    }

    // MARK: - Playing screen

    private var gameView: some View {
        // Stack vertically in portrait, side by side in landscape
        let layout = verticalSizeClass == .compact
            ? AnyLayout(HStackLayout(spacing: 48))
            : AnyLayout(VStackLayout(spacing: 48))

        return layout {
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
                .contentTransition(.numericText(value: Double(score)))
                .overlay(alignment: .topTrailing) {
                    if combo > 1 {
                        Text("x\(combo)!")
                            .font(.headline.weight(.heavy))
                            .foregroundStyle(Palette.green)
                            .offset(x: 44, y: 8)
                            .transition(.scale.combined(with: .opacity))
                    }
                }

            ProgressView(value: Double(timeRemaining), total: Double(roundLength))
                .tint(timerColor)
                .frame(width: 220)
                .animation(.linear(duration: 1), value: timeRemaining)

            Text(phase == .idle ? "tap to start" : "\(timeRemaining)s left")
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
                .contentTransition(.numericText(countsDown: true))
                .animation(.snappy, value: timeRemaining)
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
        .scaleEffect(buttonScale)
    }

    // Timer colour shift: green → amber → red
    private var timerColor: Color {
        if timeRemaining > 6 { return Palette.green }
        if timeRemaining > 3 { return Palette.amber }
        return Palette.red
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

            if isNewBest {
                Text("New best!")
                    .font(.subheadline.weight(.semibold))
                    .foregroundStyle(Palette.green)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(Palette.green.opacity(0.15), in: Capsule())
            }

            Text("Best: \(highScore)")
                .foregroundStyle(.secondary)

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

        // C1: two taps within 0.3 seconds build a combo (up to x3)
        let now = Date()
        let isFastTap = now.timeIntervalSince(lastTap) < 0.3
        lastTap = now

        withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
            combo = isFastTap ? min(combo + 1, 3) : 1
            score += combo

            // C4: shrink the button a little, but never below 60%
            buttonScale = max(0.6, buttonScale - 0.02)
        }
    }

    private func tick() {
        guard phase == .playing else { return }

        if timeRemaining > 0 {
            timeRemaining -= 1
        }

        // Combo badge fades away when the player slows down
        if Date().timeIntervalSince(lastTap) > 0.3 {
            withAnimation { combo = 1 }
        }

        // Time's up: playing → over
        if timeRemaining == 0 {
            endGame()
        }
    }

    private func endGame() {
        if score > highScore {
            highScore = score
            isNewBest = true
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            phase = .over
        }
    }

    private func resetGame() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            score = 0
            combo = 1
            lastTap = .distantPast
            timeRemaining = roundLength
            buttonScale = 1.0
            isNewBest = false
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

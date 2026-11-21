import SwiftUI

enum GamePhase {
    case idle, playing, over
}

enum Palette {
    static let green = Color(red: 0.36, green: 0.72, blue: 0.47)
    static let amber = Color(red: 0.96, green: 0.69, blue: 0.30)
    static let red   = Color(red: 0.91, green: 0.39, blue: 0.37)
}

private let roundLength = 10

struct ContentView: View {
    @State private var score = 0

    @State private var timeRemaining = roundLength
    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    @State private var phase: GamePhase = .idle

    @AppStorage("highScore") private var highScore = 0
    @State private var isNewBest = false

    @State private var combo = 1
    @State private var lastTap = Date.distantPast

    @State private var buttonScale = 1.0
    @State private var buttonOffset = CGSize.zero

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

    private var gameView: some View {
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
        .offset(buttonOffset)
    }

    private var timerColor: Color {
        if timeRemaining > 6 { return Palette.green }
        if timeRemaining > 3 { return Palette.amber }
        return Palette.red
    }

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

    private func tap() {
        guard phase != .over else { return }

        if phase == .idle {
            phase = .playing
        }

        let now = Date()
        let isFastTap = now.timeIntervalSince(lastTap) < 0.3
        lastTap = now

        withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
            combo = isFastTap ? min(combo + 1, 3) : 1
            score += combo
            buttonScale = max(0.6, buttonScale - 0.02)
        }

        moveButton()
    }

    private func tick() {
        guard phase == .playing else { return }

        if timeRemaining > 0 {
            timeRemaining -= 1
        }

        if Date().timeIntervalSince(lastTap) > 0.3 {
            withAnimation { combo = 1 }
        }

        if timeRemaining == 0 {
            endGame()
        }
    }

    private func moveButton() {
        let isLandscape = verticalSizeClass == .compact
        let x = CGFloat.random(in: isLandscape ? 0...110 : -70...70)
        let y = CGFloat.random(in: isLandscape ? -60...60 : -30...90)

        withAnimation(.spring(response: 0.25, dampingFraction: 0.7)) {
            buttonOffset = CGSize(width: x, height: y)
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
            buttonOffset = .zero
            isNewBest = false
            phase = .idle
        }
    }
}

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

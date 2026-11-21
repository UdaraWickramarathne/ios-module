import SwiftUI

struct Card: Identifiable {
    let id: Int
    var isLit = false
}

enum Level: Int {
    case one = 1, two, three, four

    static func forTime(_ elapsed: Int) -> Level {
        if elapsed < 15 { return .one }
        if elapsed < 30 { return .two }
        if elapsed < 45 { return .three }
        return .four
    }

    var cardCount: Int {
        switch self {
        case .one: return 3
        case .two: return 4
        case .three: return 6
        case .four: return 9
        }
    }

    var columns: Int {
        self == .two ? 2 : 3
    }

    var litWindow: Double {
        switch self {
        case .one: return 1.5
        case .two: return 1.2
        case .three: return 1.0
        case .four: return 0.8
        }
    }

    var litCount: Int {
        self == .four ? 2 : 1
    }

    var color: Color {
        switch self {
        case .one: return Palette.green
        case .two: return Palette.blue
        case .three: return Palette.purple
        case .four: return Palette.amber
        }
    }

    func makeCards() -> [Card] {
        (0..<cardCount).map { Card(id: $0) }
    }
}

private let roundLength = 60
private let startingLives = 3

struct LightItUpView: View {
    @State private var phase: GamePhase = .idle
    @State private var score = 0
    @State private var lives = startingLives
    @State private var timeRemaining = roundLength
    @State private var level: Level = .one
    @State private var cards = Level.one.makeCards()
    @State private var flashes: [Int: Color] = [:]
    @State private var showLevelUp = false
    @State private var roundID = 0

    @AppStorage("lightItUpHighScore") private var highScore = 0
    @State private var isNewBest = false

    @Environment(\.verticalSizeClass) private var verticalSizeClass

    private let timer = Timer.publish(every: 1, on: .main, in: .common).autoconnect()

    var body: some View {
        VStack {
            if verticalSizeClass != .compact {
                Text("Light It Up")
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
        .overlay {
            levelUpBanner
        }
        .onReceive(timer) { _ in
            tick()
        }
        .onDisappear {
            roundID += 1
        }
        .sensoryFeedback(.impact(weight: .light), trigger: score) { old, new in new > old }
        .sensoryFeedback(.error, trigger: lives) { old, new in new < old }
    }

    private var gameView: some View {
        let layout = verticalSizeClass == .compact
            ? AnyLayout(HStackLayout(spacing: 40))
            : AnyLayout(VStackLayout(spacing: 32))

        return layout {
            infoPanel
            grid
        }
    }

    private var infoPanel: some View {
        VStack(spacing: 16) {
            HStack(alignment: .top, spacing: 32) {
                stat("SCORE", value: score)
                stat("LEVEL", value: level.rawValue)

                VStack(spacing: 10) {
                    label("LIVES")
                    HStack(spacing: 4) {
                        ForEach(0..<startingLives, id: \.self) { index in
                            Image(systemName: index < lives ? "heart.fill" : "heart")
                        }
                    }
                    .font(.system(size: 20))
                    .foregroundStyle(Palette.red)
                }
            }

            ProgressView(value: Double(timeRemaining), total: Double(roundLength))
                .tint(level.color)
                .frame(width: 240)
                .animation(.linear(duration: 1), value: timeRemaining)

            Text(phase == .idle ? "tap any card to start" : "\(timeRemaining)s left")
                .font(.subheadline.monospacedDigit())
                .foregroundStyle(.secondary)
                .contentTransition(.numericText(countsDown: true))
                .animation(.snappy, value: timeRemaining)
        }
    }

    private func stat(_ title: String, value: Int) -> some View {
        VStack(spacing: 6) {
            label(title)
            Text("\(value)")
                .font(.system(size: 34, weight: .heavy, design: .rounded))
                .contentTransition(.numericText(value: Double(value)))
        }
    }

    private func label(_ title: String) -> some View {
        Text(title)
            .font(.caption.weight(.semibold))
            .tracking(2)
            .foregroundStyle(.secondary)
    }

    private var grid: some View {
        let columns = Array(repeating: GridItem(.flexible(), spacing: 14), count: level.columns)

        return LazyVGrid(columns: columns, spacing: 14) {
            ForEach(cards) { card in
                Button {
                    tap(card)
                } label: {
                    RoundedRectangle(cornerRadius: 22)
                        .fill(cardColor(card))
                        .aspectRatio(1, contentMode: .fit)
                        .shadow(color: card.isLit ? level.color.opacity(0.5) : .clear, radius: 16)
                }
                .buttonStyle(PressableStyle())
                .scaleEffect(card.isLit ? 1.08 : 1)
                .animation(.easeInOut(duration: 0.15), value: card.isLit)
            }
        }
        .frame(maxWidth: verticalSizeClass == .compact ? 280 : 360)
    }

    private func cardColor(_ card: Card) -> Color {
        if let flash = flashes[card.id] { return flash }
        if card.isLit { return level.color }
        return Color.secondary.opacity(0.15)
    }

    @ViewBuilder
    private var levelUpBanner: some View {
        if showLevelUp {
            Text("Level \(level.rawValue)!")
                .font(.system(size: 40, weight: .heavy, design: .rounded))
                .foregroundStyle(.white)
                .padding(.horizontal, 28)
                .padding(.vertical, 14)
                .background(level.color, in: Capsule())
                .shadow(color: level.color.opacity(0.4), radius: 20, y: 8)
                .transition(.scale(scale: 0.6).combined(with: .opacity))
                .allowsHitTesting(false)
        }
    }

    private var gameOverView: some View {
        VStack(spacing: 14) {
            Text(lives == 0 ? "Out of lives" : "Round over")
                .font(.system(size: 44, weight: .heavy, design: .rounded))

            label("FINAL SCORE")

            Text("\(score)")
                .font(.system(size: 64, weight: .heavy, design: .rounded))
                .foregroundStyle(level.color)

            Text("Reached level \(level.rawValue)")
                .foregroundStyle(.secondary)

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
                    .background(Palette.blue, in: Capsule())
            }
            .buttonStyle(PressableStyle())
            .padding(.top, 8)
        }
    }

    private func tap(_ card: Card) {
        if phase == .idle {
            startRound()
            return
        }

        guard phase == .playing,
              let index = cards.firstIndex(where: { $0.id == card.id }) else { return }

        if cards[index].isLit {
            withAnimation(.spring(response: 0.25, dampingFraction: 0.6)) {
                cards[index].isLit = false
                score += 1
            }
            flash(card.id, color: Palette.green)
        } else {
            flash(card.id, color: Palette.red)
            loseLife()
        }
    }

    private func startRound() {
        roundID += 1
        withAnimation {
            phase = .playing
        }
        scheduleNextLight(after: 0.6)
    }

    private func scheduleNextLight(after delay: Double) {
        let round = roundID
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            guard round == roundID, phase == .playing else { return }
            lightCards()
        }
    }

    private func lightCards() {
        let round = roundID
        let litIDs = cards.map { $0.id }.shuffled().prefix(level.litCount)

        withAnimation {
            for index in cards.indices where litIDs.contains(cards[index].id) {
                cards[index].isLit = true
            }
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + level.litWindow) {
            guard round == roundID, phase == .playing else { return }
            endLitWindow()
        }
    }

    private func endLitWindow() {
        let missed = cards.filter { $0.isLit }.count

        withAnimation {
            for index in cards.indices {
                cards[index].isLit = false
            }
        }

        for _ in 0..<missed {
            loseLife()
        }

        scheduleNextLight(after: Double.random(in: 0.3...0.7))
    }

    private func flash(_ id: Int, color: Color) {
        withAnimation(.easeOut(duration: 0.1)) {
            flashes[id] = color
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.25) {
            withAnimation(.easeIn(duration: 0.2)) {
                flashes[id] = nil
            }
        }
    }

    private func loseLife() {
        guard phase == .playing else { return }

        withAnimation {
            lives -= 1
        }

        if lives == 0 {
            endRound()
        }
    }

    private func tick() {
        guard phase == .playing else { return }

        if timeRemaining > 0 {
            timeRemaining -= 1
        }

        let newLevel = Level.forTime(roundLength - timeRemaining)
        if newLevel != level {
            levelUp(to: newLevel)
        }

        if timeRemaining == 0 {
            endRound()
        }
    }

    private func levelUp(to newLevel: Level) {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            level = newLevel
            cards = newLevel.makeCards()
            showLevelUp = true
        }

        DispatchQueue.main.asyncAfter(deadline: .now() + 1.2) {
            withAnimation {
                showLevelUp = false
            }
        }
    }

    private func endRound() {
        guard phase == .playing else { return }

        roundID += 1

        if score > highScore {
            highScore = score
            isNewBest = true
        }

        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            phase = .over
        }
    }

    private func resetGame() {
        roundID += 1

        withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
            score = 0
            lives = startingLives
            timeRemaining = roundLength
            level = .one
            cards = Level.one.makeCards()
            flashes = [:]
            isNewBest = false
            phase = .idle
        }
    }
}

#Preview {
    LightItUpView()
}

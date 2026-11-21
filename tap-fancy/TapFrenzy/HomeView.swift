import SwiftUI

struct HomeView: View {
    @AppStorage("highScore") private var tapFrenzyBest = 0
    @AppStorage("lightItUpHighScore") private var lightItUpBest = 0

    var body: some View {
        NavigationStack {
            VStack(spacing: 16) {
                Spacer()

                VStack(spacing: 6) {
                    Text("Pick a game")
                        .font(.system(size: 36, weight: .heavy, design: .rounded))
                    Text("Two modes. Beat your best.")
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 12)

                NavigationLink {
                    TapFrenzyView()
                        .navigationBarTitleDisplayMode(.inline)
                } label: {
                    ModeCard(
                        title: "Tap Frenzy",
                        subtitle: "Tap as fast as you can",
                        icon: "hand.tap.fill",
                        color: Palette.green,
                        best: tapFrenzyBest
                    )
                }
                .buttonStyle(PressableStyle())

                NavigationLink {
                    LightItUpView()
                        .navigationBarTitleDisplayMode(.inline)
                } label: {
                    ModeCard(
                        title: "Light It Up",
                        subtitle: "Hit the card that lights up",
                        icon: "lightbulb.fill",
                        color: Palette.blue,
                        best: lightItUpBest
                    )
                }
                .buttonStyle(PressableStyle())

                Spacer()
            }
            .frame(maxWidth: 420)
            .padding()
        }
    }
}

struct ModeCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    let best: Int

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon)
                .font(.title2.weight(.semibold))
                .foregroundStyle(.white)
                .frame(width: 56, height: 56)
                .background(color, in: RoundedRectangle(cornerRadius: 16))

            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.title3.weight(.bold))
                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            VStack(spacing: 2) {
                Text("BEST")
                    .font(.caption2.weight(.semibold))
                    .tracking(1.5)
                    .foregroundStyle(.secondary)
                Text("\(best)")
                    .font(.system(size: 24, weight: .heavy, design: .rounded))
            }
        }
        .padding(18)
        .background(Color.secondary.opacity(0.1), in: RoundedRectangle(cornerRadius: 24))
        .foregroundStyle(.primary)
    }
}

#Preview {
    HomeView()
}

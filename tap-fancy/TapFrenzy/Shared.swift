import SwiftUI

enum GamePhase {
    case idle, playing, over
}

enum Palette {
    static let green  = Color(red: 0.36, green: 0.72, blue: 0.47)
    static let blue   = Color(red: 0.36, green: 0.56, blue: 0.92)
    static let purple = Color(red: 0.62, green: 0.47, blue: 0.88)
    static let amber  = Color(red: 0.96, green: 0.69, blue: 0.30)
    static let red    = Color(red: 0.91, green: 0.39, blue: 0.37)
}

struct PressableStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 0.92 : 1)
            .animation(.spring(response: 0.2, dampingFraction: 0.5), value: configuration.isPressed)
    }
}

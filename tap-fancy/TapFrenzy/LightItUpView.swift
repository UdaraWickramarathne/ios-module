import SwiftUI

struct LightItUpView: View {
    var body: some View {
        Text("Light It Up")
            .font(.system(size: 36, weight: .heavy, design: .rounded))
            .foregroundStyle(.secondary)
    }
}

#Preview {
    LightItUpView()
}

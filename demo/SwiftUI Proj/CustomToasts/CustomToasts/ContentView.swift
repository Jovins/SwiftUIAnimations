import SwiftUI

struct ContentView: View {
    var body: some View {
        VStack {
            Button("Present Toast") {
                Toast.shared.present(title: "AirPods Pro",
                                     symbol: "airpodspro",
                                     isUserInteractionEnabled: true,
                                     timing: .long,
                                     direction: .top)
            }
        }
        .padding()
    }
}

#Preview {
    RootView {
        ContentView()
    }
}

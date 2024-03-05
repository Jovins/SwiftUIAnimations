import SwiftUI

@main
struct SwiftUIAnimationsApp: App {
    var body: some Scene {
        WindowGroup {
            TwinCircleAnimation(size: 20)
        }
    }
}

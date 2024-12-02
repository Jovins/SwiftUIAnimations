import Foundation
import SwiftUI

/// Root view for creating overlay window
struct RootView<Content: View>: View {
    
    // MARK: - Properties
    @ViewBuilder var content: Content

    @State private var overlayWindow: UIWindow?

    var body: some View {
        content
            .onAppear {
                if let windowSence = UIApplication.shared.connectedScenes.first as? UIWindowScene,
                   overlayWindow == nil {
                    let window = PassthroughWindow(windowScene: windowSence)
                    window.backgroundColor = .clear
                    window.isHidden = false
                    window.isUserInteractionEnabled = true
                    window.tag = 9999
                    overlayWindow = window

                    // View Controller
                    let rootController = UIHostingController(rootView: ToastGroup())
                    rootController.view.frame = windowSence.keyWindow?.frame ?? .zero
                    rootController.view.backgroundColor = .clear
                    window.rootViewController = rootController
                }
            }
    }
}

fileprivate class PassthroughWindow: UIWindow {
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        guard let view = super.hitTest(point, with: event) else { return nil }
        return rootViewController?.view == view ? nil : view
    }
}

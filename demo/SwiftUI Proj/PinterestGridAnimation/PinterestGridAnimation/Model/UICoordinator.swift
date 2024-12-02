import SwiftUI

@Observable
class UICoordinator {
    /// Share views properties between home and detail view
    var scrollview: UIScrollView = .init(frame: .zero)
    var rect: CGRect = .zero
    var selectedItem: Item?
    /// Animation layer properties
    var animationLayer: UIImage?
    var animateView: Bool = false
    var hideLayer: Bool = false
    /// root view properties
    var hideRootView: Bool = false
    var headerOffset: CGFloat = .zero
    
    func creatVisibleAreaSnapShot() {
        let renderer = UIGraphicsImageRenderer(size: scrollview.bounds.size)
        let image = renderer.image { context in
            context.cgContext.translateBy(x: -scrollview.contentOffset.x, y: -scrollview.contentOffset.y)
            scrollview.layer.render(in: context.cgContext)
        }
        animationLayer = image
    }

    func toggleView(show: Bool, frame: CGRect, item: Item) {
        if show {
            selectedItem = item
            rect = frame
            creatVisibleAreaSnapShot()
            hideRootView = true
            withAnimation(.easeInOut(duration: 0.25), completionCriteria: .removed) {
                animateView = true
            } completion: {
                self.hideLayer = true
            }
        } else {
            hideLayer = false
            withAnimation(.easeInOut(duration: 0.25), completionCriteria: .removed) {
                animateView = false
            } completion: {
                DispatchQueue.main.async {
                    self.resetAnimationProperties()
                }
            }
        }
    }

    func resetAnimationProperties() {
        selectedItem = nil
        hideRootView = false
        headerOffset = .zero
        animationLayer = nil
    }
}

import SwiftUI

struct HeroLayer: View {
    
    @Environment(UICoordinator.self) private var coordinator
    var item: Item
    var sAnchor: Anchor<CGRect>
    var dAnchor: Anchor<CGRect>
    var body: some View {
        GeometryReader { proxy in
            let sRect = proxy[sAnchor]
            let dRect = proxy[dAnchor]
            let animateView = coordinator.animateView
            let viewSize = CGSize(width: animateView ? dRect.width : sRect.width,
                                  height: animateView ? dRect.height : sRect.height)
            let viewOffset = CGSize(width: animateView ? dRect.minX : sRect.minX,
                                    height: animateView ? dRect.minY : sRect.minY)
            if let image = item.image, !coordinator.showDetailView {
                Image(uiImage: image)
                    .resizable()
                    .aspectRatio(contentMode: animateView ? .fit : .fill)
                    .frame(width: viewSize.width, height: viewSize.height)
                    .clipped()
                    .offset(viewOffset)
                    .transition(.identity)
            }
        }
    }
}

#Preview {
    ContentView()
}

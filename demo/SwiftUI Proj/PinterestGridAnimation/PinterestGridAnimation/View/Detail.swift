import SwiftUI

struct Detail: View {
    
    @Environment(UICoordinator.self) private var coordinator

    var body: some View {
        GeometryReader {
            let size = $0.size
            let animateView = coordinator.animateView
            let hideLayer = coordinator.hideLayer
            let rect = coordinator.rect

            let anchorX = (coordinator.rect.minX / size.width) > 0.5 ? 1.0 : 0.0
            let scale = size.width / coordinator.rect.width
            
            let offsetX = animateView ? (anchorX > 0.5 ? 8 : -8) * scale : 0
            let offsetY = animateView ? -coordinator.rect.minY * scale : 0

            let detailHeight: CGFloat = rect.height * scale
            let scrollContentHeight: CGFloat = size.height - detailHeight

            if let image = coordinator.animationLayer,
               let item = coordinator.selectedItem {
                if !hideLayer {
                    Image(uiImage: image)
                        .scaleEffect(animateView ? scale : 1, anchor: .init(x: anchorX, y: 0))
                        .offset(x: offsetX, y: offsetY)
                        .offset(y: animateView ? -coordinator.headerOffset : 0)
                        .opacity(animateView ? 0 : 1)
                        .transition(.identity)
                }

                ScrollView(.vertical) {
                    ScrollContent()
                        .safeAreaInset(edge: .top, spacing: 0) {
                            Rectangle()
                                .fill(.clear)
                                .frame(height: detailHeight)
                        }
                        .offsetY { offset in
                            coordinator.headerOffset = max(min(-offset, detailHeight), 0)
                        }
                }
                .scrollDisabled(!hideLayer)
                .contentMargins(.top, detailHeight, for: .scrollIndicators)
                .background{
                    Rectangle()
                        .fill(.background)
                        .padding(.top, scrollContentHeight)
                }
                .animation(.easeInOut(duration: 0.25).speed(1.5)) {
                    $0.offset(y: animateView ? 0 : scrollContentHeight)
                        .opacity(animateView ? 1 : 0)
                }
                ImageView(item: item)
                    .allowsHitTesting(false)
                    .frame(width: animateView ? size.width : rect.width,
                           height: animateView ? rect.height * scale : rect.height)
                    .clipShape(.rect(cornerRadius: animateView ? 0 : 10))
                    .overlay(alignment: .top, content: {
                        HeaderActions(item)
                            .offset(y: coordinator.headerOffset)
                            .padding(.top, safeArea.top )
                    })
                    .offset(x: animateView ? 0 : rect.minX, y: animateView ? 0 : rect.minY)
                    .offset(y: animateView ? -coordinator.headerOffset : 0)
            }
        }
        .ignoresSafeArea()
    }
    
    @ViewBuilder
    func ScrollContent() -> some View {
        PinterestContent()
    }
    
    @ViewBuilder
    func HeaderActions(_ item: Item) -> some View {
        HStack {
            Spacer(minLength: 0)
            Button(action: {
                coordinator.toggleView(show: false, frame: .zero, item: item)
            }, label: {
                Image(systemName: "xmark.circle.fill")
                    .font(.title)
                    .foregroundStyle(Color.primary, .bar)
                    .padding(10)
                    .contentShape(.rect)
            })
        }
        .animation(.easeInOut(duration: 0.3)) {
            $0.opacity(coordinator.hideLayer ? 1 : 0)
        }
    }
}

#Preview {
    ContentView()
}

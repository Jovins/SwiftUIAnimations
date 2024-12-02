import SwiftUI

struct Home: View {
    var body: some View {
        ScrollView(.vertical) {
            LazyVStack(spacing: 16) {
                DummySection(title: "Swift Testing")
                DummySection(title: "Disclaimer")
                // Parallax Image
                ParallaxImageView(maximum: 160, shouldUsesFullWidth: true) { size in
                    Image(.pic1)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size.width, height: size.height)
                }
                .frame(height: 520)
                DummySection(title: "Challenges in testing")
                DummySection(title: "Handling")
                
                ParallaxImageView(maximum: 160, shouldUsesFullWidth: true) { size in
                    Image(.pic2)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size.width, height: size.height)
                }
                .frame(height: 460)
                
                DummySection(title: "Custom Logic")
                DummySection(title: "Support")
                
                ParallaxImageView(maximum: 200, shouldUsesFullWidth: true) { size in
                    Image(.pic3)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: size.width, height: size.height)
                }
                .frame(height: 420)
            }
            .padding(16)
        }
        .navigationBarTitleDisplayMode(.inline)
    }

    @ViewBuilder
    func DummySection(title: String, isLong: Bool = false) -> some View {
        VStack(alignment: .leading, spacing: 12, content: {
            Text(title)
                .font(.title.bold())
            Text("Introducing Swift Testing: a new package for testing your code using Swift. Explore the building blocks of its powerful new API, discover how it can be applied in common testing workflows, and learn how it relates to XCTest and open source Swift. \(isLong ? "Learn how to write a sweet set of (test) suites using Swift Testing’s baked-in features." : "")")
                .multilineTextAlignment(.leading)
                .kerning(1.2)
        })
        .frame(width: .infinity, alignment: .leading)
    }
}

struct ParallaxImageView<Content: View>: View {

    var maximum: CGFloat = 100
    var shouldUsesFullWidth: Bool = false
    @ViewBuilder var content: (CGSize) -> Content

    var body: some View {
        GeometryReader {
            let size = $0.size
            // Movement Animation Properties
            let minY = $0.frame(in: .scrollView(axis: .vertical)).minY
            let scrollViewHeihgt: CGFloat = $0.bounds(of: .scrollView)?.size.height ?? 0
            let maximumMovement = min(maximum, size.height * 0.35)
            let stretchedSize: CGSize = .init(width: size.width, height: size.height + maximumMovement)
            
            let progress = minY / scrollViewHeihgt
            let cappedProgress = max(min(progress, 1.0), -1.0)
            let movementOffset = cappedProgress * -maximumMovement

            content(size)
                .offset(y: movementOffset)
                .frame(width: stretchedSize.width, height: stretchedSize.height)
                .frame(width: size.width, height: size.height)
                .clipped()
        }
        .containerRelativeFrame(shouldUsesFullWidth ? [.horizontal] : [])
    }
}

#Preview {
    ContentView()
}

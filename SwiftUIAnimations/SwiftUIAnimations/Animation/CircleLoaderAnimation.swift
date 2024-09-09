import SwiftUI

struct CircleLoaderAnimation: View {
    
    @State var size: CGFloat = 80
    @State var lineWidth: CGFloat = 8
    @State var isAnimating: Bool = false
    @State var circleStart: CGFloat = 0.17
    @State var circleEnd: CGFloat = 0.325
    @State var rotationDegree: Angle = .degrees(0)
    
    private let trackerRotation: Double = 2
    private let animationDuration: Double = 0.75
    private let circleTrackGradient = LinearGradient(gradient: .init(colors: [Color(r: 237, g: 242, b: 255), Color(r: 235, g: 248, b: 255)]), startPoint: .leading, endPoint: .bottomLeading)
    private let circleRoundGradient = LinearGradient(gradient: .init(colors: [Color.purple, Color.blue]), startPoint: .topLeading, endPoint: .trailing)
    private var rotationAngle: Angle {
        return .degrees(360 * self.trackerRotation) + .degrees(120)
    }

    var body: some View {
        ZStack {
            Color.white.edgesIgnoringSafeArea(.all)
            ZStack {
                Circle()
                    .stroke(style: StrokeStyle(lineWidth: lineWidth))
                    .fill(circleTrackGradient)
                Circle()
                    .trim(from: circleStart, to: circleEnd)
                    .stroke(style: StrokeStyle(lineWidth: lineWidth, lineCap: .round))
                    .fill(circleRoundGradient)
                    .rotationEffect(self.rotationDegree)
            }
            .frame(width: size, height: size)
            .onAppear {
                self.circleAnimation()
                Timer.scheduledTimer(withTimeInterval: animationDuration * (trackerRotation + 1),
                                     repeats: true) { _ in
                    self.circleAnimation()
                }
            }
        }
    }

    func circleAnimation() {
        withAnimation(Animation.spring(response: animationDuration * 2)) {
            self.rotationDegree = .degrees(-57.5)
        }
        Timer.scheduledTimer(withTimeInterval: animationDuration, repeats: false) { _ in
            withAnimation(Animation.easeInOut(duration: self.trackerRotation * self.animationDuration)) {
                self.rotationDegree += self.rotationAngle
            }
        }
        Timer.scheduledTimer(withTimeInterval: animationDuration * 1.25, repeats: false) { _ in
            withAnimation(Animation.easeOut(duration: (self.trackerRotation * self.animationDuration) / 2.25 )) {
                self.circleEnd = 0.925
            }
        }
        Timer.scheduledTimer(withTimeInterval: trackerRotation * animationDuration, 
                             repeats: false) { _ in
            self.rotationDegree = .degrees(47.5)
            withAnimation(Animation.easeOut(duration: self.animationDuration)) {
                self.circleEnd = 0.325
            }
        }
    }
}

extension Color {
    init(r: Double, g: Double, b: Double) {
        self.init(red: r / 255.0, green: g / 255.0, blue: b / 255.0)
    }
}

#Preview {
    CircleLoaderAnimation(size: 30, lineWidth: 4)
}

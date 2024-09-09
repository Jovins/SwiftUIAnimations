import SwiftUI

struct DotsAnimation: View {

    @State var size: CGFloat = 20
    @State var color: Color = .purple
    @State var speed: Double = 0.5
    @State var offsetYs: [CGFloat] = datas.map { _ in return 0 }

    private static let datas = [AnimationData(delay: 0.0, offsetY: -40),
                                AnimationData(delay: 0.05, offsetY: -50),
                         AnimationData(delay: 0.1, offsetY: -60)]

    var body: some View {
        ZStack {
            HStack(spacing: 4) {
                DotView(size: $size, color: .constant(color), offsetY: $offsetYs[0])
                DotView(size: $size, color: .constant(color), offsetY: $offsetYs[1])
                DotView(size: $size, color: .constant(color), offsetY: $offsetYs[2])
            }
        }
        .frame(width: 100, height: 100)
        .onAppear {
            animateDots()
        }
    }

    func animateDots() {
        for (index, data) in Self.datas.enumerated() {
            DispatchQueue.main.asyncAfter(deadline: .now() + data.delay) {
                animateDot(with: $offsetYs[index], animationData: data)
            }
        }
        // Repeat
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            animateDots()
        }
    }

    func animateDot(with offsetY: Binding<CGFloat>, animationData: AnimationData) {
        withAnimation(Animation.easeInOut.speed(speed)) {
            offsetY.wrappedValue = animationData.offsetY
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            withAnimation(Animation.easeInOut.speed(speed)) {
                offsetY.wrappedValue = 0
            }
        }
    }
}

internal struct AnimationData {
    var delay: TimeInterval
    var offsetY: CGFloat
}

private struct DotView: View {

    @Binding var size: CGFloat
    @Binding var color: Color
    @Binding var offsetY: CGFloat
    var body: some View {
        VStack{}
            .frame(width: size, height: size, alignment: .center)
            .background(color)
            .cornerRadius(size * 0.5)
            .offset(x: 0, y: offsetY)
    }
}

#Preview {
    DotsAnimation(size: 20, color: .purple)
}

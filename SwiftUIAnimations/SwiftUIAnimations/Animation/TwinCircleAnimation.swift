import SwiftUI

struct TwinCircleAnimation: View {
    
    @State var size: CGFloat = 40
    @State var factor: CGFloat = 0
    @State private var leftColor: Color = Color.purple
    @State private var rightColor: Color = Color.purple

    var body: some View {
        ZStack {
            VStack{}.frame(width: size, height: size, alignment: .center)
                .background(leftColor)
                .cornerRadius(size * 0.5)
                .scaleEffect(abs(factor) * 0.3 + 1)
                .offset(x: factor * size * 0.6, y: 0)
            VStack{}.frame(width: size, height: size, alignment: .center)
                .background(rightColor)
                .cornerRadius(size * 0.5)
                .scaleEffect(abs(factor) * 0.3 + 1)
                .offset(x: -factor * size * 0.6, y: 0)
        }
        .frame(width: 100, height: 100)
        .onAppear {
            animate()
        }
    }
    
    func animate() {
        withAnimation(.linear(duration: 0.15)) {
            factor = 1
            leftColor = Color.purple
            rightColor = Color.blue
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.15) {
            withAnimation(.linear(duration: 0.3)) {
                factor = -1
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
            withAnimation(.linear(duration: 1.0)) {
                factor = 0
                leftColor = Color.purple
                rightColor = Color.purple
            }
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.55) {
            animate()
        }
    }
}

#Preview {
    TwinCircleAnimation()
}

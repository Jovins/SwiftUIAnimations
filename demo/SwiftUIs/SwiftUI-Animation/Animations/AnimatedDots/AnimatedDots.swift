//
//  AnimatedDots.swift
//  SwiftUI-Animation
//
//  Created by Jovins on 2021/7/25.
//

import SwiftUI

struct AnimatedDots: View {
    
    @State var showAnimation: Bool = false
    var heightAndWidth: CGFloat = 25
    
    var body: some View {
        ZStack {
            Color.getBGColor().ignoresSafeArea()
            HStack {
                Circle()
                    .fill(Color.getBallColor())
                    .frame(width: heightAndWidth, height: heightAndWidth)
                    .offset(x: 0, y: showAnimation ? 0 : -50)
                    .animation(Animation
                    .interpolatingSpring(stiffness: 100, damping: 5)
                    .repeatForever(autoreverses: false).delay(0.02))
                Circle()
                    .fill(Color.getBallColor())
                    .frame(width: heightAndWidth, height: heightAndWidth)
                    .offset(x: 0, y: showAnimation ? 0 : -50)
                    .animation(Animation
                    .interpolatingSpring(stiffness: 100, damping: 5)
                   .repeatForever(autoreverses: false).delay(0.04))
                Circle()
                    .fill(Color.getBallColor())
                    .frame(width: heightAndWidth, height: heightAndWidth)
                    .offset(x: 0, y: showAnimation ? 0 : -50)
                    .animation(Animation
                    .interpolatingSpring(stiffness: 100, damping: 5)
                    .repeatForever(autoreverses: false).delay(0.06))
            }
            .onAppear() {
                self.showAnimation.toggle()
                    
            }
        }
    }
}

#if DEBUG
struct AnimatedDots_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedDots()
    }
}
#endif

extension Color {
    
    static
    func getBGColor() -> Color {
        return Color(red: 224/255, green: 229/255, blue: 236/255)
    }
    
    static
    func getBallColor() -> LinearGradient {
        let color = [
            Color(hex: 0xf35872),
            Color(hex: 0xf99068),
        ]
        return LinearGradient(gradient: Gradient(colors: color), startPoint: .leading, endPoint: .trailing)
    }
}

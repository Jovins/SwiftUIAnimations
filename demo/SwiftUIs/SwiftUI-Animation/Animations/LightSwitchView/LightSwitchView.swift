//
//  LightSwitchView.swift
//  SwiftUI-Animation
//
//  Created by Jovins on 2021/7/23.
//

import SwiftUI

struct LightSwitchView: View {
    
    // MARK: - Property
    let kHeight: CGFloat = UIScreen.main.bounds.height
    let kWidth: CGFloat = UIScreen.main.bounds.width
    let animationDuration: TimeInterval = 0.35
    
    @State var xScale: CGFloat = 2
    @State var yScale: CGFloat = 0.4
    @State var yOffset: CGFloat = UIScreen.main.bounds.height * 0.8
    @State var isOff: Bool = true
    
    var body: some View {
        ZStack {
            Color.blue
            Circle()
                .fill(Color.yellow)
                .scaleEffect(CGSize(width: self.xScale, height: self.yScale))
                .offset(y: self.yOffset)
            VStack(alignment: .leading) {
                HStack {
                    Image(systemName: "arrow.left")
                        .foregroundColor(self.isOff ? .white : .black)
                        .font(.system(size: 24, weight: .semibold, design: .monospaced))
                    Spacer()
                        .offset(x: -12)
                    Spacer()
                }
                .padding([.top, .bottom], 24)
                Spacer()
            }
            .offset(y: 32)
            .padding([.leading, .trailing], 24)
            
            ZStack {
                Capsule(style: .continuous)
                    .foregroundColor(.gray)
                    .frame(width: 52, height: self.kHeight * 0.25 + 6)
                    .opacity(0.375)
                    .offset(x: self.kWidth / 2 - 48, y: 16)
                ZStack {
                    
                    Capsule()
                        .frame(width: 3, height: self.isOff ? self.kHeight * 0.41 : self.kHeight * 0.625)
                        .foregroundColor(.clear)
                    
                    Circle()
                        .fill(Color.white)
                        .frame(width: 42, height: 42)
                        .offset(y: self.isOff ? self.kHeight * 0.225: self.kHeight * 0.25 + 42)
                        .onTapGesture {
                            self.toggleAllLight()
                        }
                }
                .offset(x: self.kWidth / 2 - 48, y: -self.kHeight / 2)
                .frame(height: 0, alignment: .top)
            }
            .animation(Animation.spring(dampingFraction: 0.65).speed(1.25))
        }
        .edgesIgnoringSafeArea(.all)
    }
    
    func toggleAllLight() {
        if self.isOff {
            withAnimation(Animation.easeIn(duration: self.animationDuration)) {
                self.xScale = 4
                self.yScale = 4
                self.yOffset = 0
            }
        } else {
            self.yScale = 0.4
            self.xScale = 2
            self.yOffset = UIScreen.main.bounds.height * 0.8
        }
        self.isOff.toggle()
    }
}

#if DEBUG
struct LightSwitchView_Previews: PreviewProvider {
    static var previews: some View {
        LightSwitchView()
    }
}
#endif

//
//  AnimatedBalls.swift
//  SwiftUI-Animation
//
//  Created by Jovins on 2021/7/25.
//

import SwiftUI

struct AnimatedBalls: View {
    
    @State var xOffset: CGFloat = 0
    @State var yOffset: CGFloat = 0
    @State var xOffsetForDifferentDot: CGFloat = 0
    
    var animationTime: Double = 0.8
    
    var body: some View {
        
        GeometryReader { reader in
            HStack(spacing: self.spaceBetweenDots(reader.size)) {
                ForEach(0..<3) { i in
                    Circle().fill(Color.getSecondBallColor())
                        .frame(width: self.getwidthForDot(reader.size), height: self.getwidthForDot(reader.size))
                        .offset(self.offsetForDotAtIndex(i, in: reader.size))
                }
            }
            .offset(self.offsetIn(reader.size))
            .onAppear {
                Timer.scheduledTimer(withTimeInterval: Double(self.animationTime) * 1.2, repeats: true) { (_) in
                    DispatchQueue.main.async {
                        withAnimation(
                            .easeInOut(duration: Double(self.animationTime)/4)) {
                            self.xOffset = 0
                            self.yOffset = -(self.getwidthForDot(reader.size) + self.spaceBetweenDots(reader.size))
                        }
                    }
                    DispatchQueue.main
                        .asyncAfter(deadline: .now() + Double(self.animationTime)/4 + 0.04) {
                            withAnimation(Animation
                                            .easeInOut(duration: Double(self.animationTime)/2)) {
                                self.xOffset = (self.getwidthForDot(reader.size) + self.spaceBetweenDots(reader.size)) * 2
                                self.yOffset = -(self.getwidthForDot(reader.size) + self.spaceBetweenDots(reader.size))
                                self.xOffsetForDifferentDot = -(self.getwidthForDot(reader.size) + self.spaceBetweenDots(reader.size))
                            }
                        }
                    DispatchQueue.main
                        .asyncAfter(deadline: .now() + Double(self.animationTime) * 0.75 + 0.04) {
                            withAnimation(Animation
                                            .easeInOut(duration: Double(self.animationTime)/4)) {
                                self.xOffset = (self.getwidthForDot(reader.size) + self.spaceBetweenDots(reader.size)) * 2
                                self.yOffset = 0
                            }
                        }
                    DispatchQueue.main
                        .asyncAfter(deadline: .now() + Double(self.animationTime) + 0.04) {
                            self.xOffsetForDifferentDot = 0
                            self.xOffset = 0
                            self.yOffset = 0                    }
                }
            }
        }
    }
    
    func getwidthForDot(_ size: CGSize) -> CGFloat {
        min(size.width * 0.3, size.height / 2.05)
    }
    
    func spaceBetweenDots(_ size: CGSize) -> CGFloat {
        min(size.width, size.height) * 0.05
    }
    
    func offsetForDotAtIndex(_ index: Int, in size: CGSize) -> CGSize {
        index == 0 ? CGSize(width: xOffset, height: yOffset) : CGSize(width: xOffsetForDifferentDot, height: 0)
    }
    
    func offsetIn(_ size: CGSize) -> CGSize {
        CGSize(width: (size.width / 2) - (1.5 * getwidthForDot(size) + spaceBetweenDots(size)),
               height: (size.height - getwidthForDot(size))/2 + (getwidthForDot(size) + spaceBetweenDots(size))/2)
    }
}

extension Color {
    
    static
    func getSecondBallColor() -> LinearGradient {
        let colors = [Color.init(red: 0.84, green: 0.43, blue: 0.46), Color.init(red: 0.46, green: 0.29, blue: 0.64)]
        return LinearGradient(gradient: Gradient(colors: colors), startPoint: .top, endPoint: .bottom)
    }
}


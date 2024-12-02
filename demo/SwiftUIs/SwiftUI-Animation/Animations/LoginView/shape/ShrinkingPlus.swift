//
//  ShrinkingPlus.swift
//  SwiftUI-Animation
//
//  Created by Jovins on 2021/7/23.
//

import SwiftUI

struct ShrinkingPlus: View {
    
    // MARK:- Property
    let position: PlusPosition
    let animationDuration: TimeInterval = 0.4
    
    @State var rotationDegree: Angle = Angle.degrees(0)
    @State var scale: CGFloat = 0
    
    // MARK:- views
    var body: some View {
        Plus()
            .stroke(style: StrokeStyle(lineWidth: 6, lineCap: .round))
            .foregroundColor(position.color)
            .rotationEffect(rotationDegree)
            .scaleEffect(scale)
            .opacity(position.opacity)
            .onAppear() {
                self.scale = position.scale
                self.rotationDegree = position.degree
                animatePlus()
                Timer.scheduledTimer(withTimeInterval: position.delay * 20, repeats: true) { _ in
                    animatePlus()
                }
            }
    }
    
    // MARK:- functions
    func animatePlus() {
        Timer.scheduledTimer(withTimeInterval: position.delay, repeats: false) { _ in
            withAnimation(Animation.easeOut(duration: animationDuration)) {
                rotationDegree = (position.degree)
            }
            withAnimation(Animation.easeOut(duration: animationDuration).delay(animationDuration / 4)) {
                scale = 0
            }
            
            Timer.scheduledTimer(withTimeInterval: position.delay * 3, repeats: false) { _ in
                withAnimation(Animation.easeOut(duration: animationDuration)) {
                    rotationDegree = .degrees(0)
                }
                withAnimation(Animation.easeOut(duration: animationDuration).delay(animationDuration / 4)) {
                    scale = position.scale
                }
            }
        }
    }
}

#if DEBUG
struct ShrinkingPlus_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            Color.black
                .edgesIgnoringSafeArea(.all)
            ShrinkingPlus(position: PlusPosition(id: 0, color: Color.white, offsetX: -92, offsetY: -100, delay: 0.2, scale: 0.8, opacity: 1, degree: Angle(degrees: 43)))
        }
    }
}
#endif

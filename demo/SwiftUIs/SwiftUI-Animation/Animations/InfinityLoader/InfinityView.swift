//
//  InfinityView.swift
//  SwiftUI-Animation
//
//  Created by Jovins on 2021/7/23.
//

import SwiftUI

struct InfinityView: View {
    
    // MARK: - Property
    let animationDuration: TimeInterval = 0.2
    let strokeWidth: CGFloat = 20
    let animationCap: CGFloat = 1.205

    @State var strokeStart: CGFloat = 0
    @State var strokeEnd: CGFloat = 0
    @State var additionalLength: CGFloat = 0
    
    var body: some View {
        ZStack {
            Color.white
                .edgesIgnoringSafeArea(.all)
            InfinityShape()
                .stroke(style: StrokeStyle(lineWidth: strokeWidth, lineCap: .round, lineJoin: .round))
                .foregroundColor(.blue)
                .shadow(color: Color.white,radius: 4)
                .overlay(
                    // animate shape
                    InfinityShape()
                        .trim(from: self.strokeStart, to: self.strokeEnd)
                        .stroke(style: StrokeStyle(lineWidth: strokeWidth - 0.5, lineCap: .round, lineJoin: .round))
                        .foregroundColor(Color.white)
                        .shadow(color: .white, radius: 5)
                )
        }.onAppear() {
            self.animate()
        }
    }
    
    func animate() {
        
        Timer.scheduledTimer(withTimeInterval: self.animationDuration, repeats: true) { _ in
            withAnimation(Animation.linear(duration: self.animationDuration)) {
                self.strokeEnd += 0.05
                self.strokeStart = self.strokeEnd - (0.05 + self.additionalLength)
            }
            // reset values
            if (strokeEnd >= animationCap) {
                strokeEnd = 0
                additionalLength = 0
                strokeStart = 0
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: self.animationDuration * 3, repeats: true) { _ in
            additionalLength += 0.015
        }
    }
}

#if DEBUG
struct InfinityView_Previews: PreviewProvider {
    static var previews: some View {
        InfinityView()
    }
}
#endif

//
//  SpinningView.swift
//  SwiftUI-Animation
//
//  Created by Jovins on 2021/7/23.
//

import SwiftUI

struct SpinningView: View {
    
    // MARK: - Property
    @State var circleEnd: CGFloat = 0.001
    @State var smallerCircleEnd: CGFloat = 1
    @State var rotationDegree: Angle = Angle.degrees(-90)
    @State var smallerRotationDegree: Angle = Angle.degrees(-30)
    let trackerRotation: Double = 1
    let animationDuration: Double = 1.35
    
    // MARK: - Views
    var body: some View {
        ZStack {
            Color.blue
                .edgesIgnoringSafeArea(.all)
            ZStack {
                Circle()
                    .trim(from: 0, to: self.circleEnd)
                    .stroke(style: StrokeStyle(lineWidth: 18, lineCap: .round))
                    .fill(Color.white)
                    .rotationEffect(self.rotationDegree)
                    .frame(width: 120, height: 120)
                Circle()
                    .trim(from: 0, to: smallerCircleEnd)
                    .stroke(style: StrokeStyle(lineWidth: 18, lineCap: .round))
                    .fill(Color.white.opacity(0.8))
                    .rotationEffect(self.smallerRotationDegree)
                    .frame(width: 48, height: 48 )
            }
            .offset(y: -48)
            Text("Spinning Loader")
                .foregroundColor(.white)
                .font(.system(size: 20, weight: .medium, design: .monospaced))
                .opacity(0.8)
                .offset(x: 10, y: 200)
                .onAppear() {
                    animate()
                    Timer.scheduledTimer(withTimeInterval: animationDuration * 1.98, repeats: true) { _ in
                        reset()
                        animate()
                    }
                }
        }
    }
    
    func animate() {
        
        withAnimation(Animation.easeOut(duration: self.animationDuration)) {
            self.circleEnd = 1
        }
        withAnimation(Animation.easeOut(duration: self.animationDuration * 1.1)) {
            self.rotationDegree = RotationDegrees.initialCicle.getRotationDegrees()
        }
        // small circle
        withAnimation(Animation.easeOut(duration: self.animationDuration * 0.85)) {
            
            self.smallerCircleEnd = 0.001
            self.smallerRotationDegree = RotationDegrees.initialCicle.getRotationDegrees()
        }
        
        Timer.scheduledTimer(withTimeInterval: animationDuration * 0.7, repeats: false) { _ in
            
            withAnimation(Animation.easeIn(duration: animationDuration * 0.4)) {
                self.smallerRotationDegree = RotationDegrees.middleSmallCircle.getRotationDegrees()
                self.rotationDegree = RotationDegrees.middleCircle.getRotationDegrees()
            }
        }
        
        Timer.scheduledTimer(withTimeInterval: animationDuration, repeats: false) { _ in
            
            withAnimation(Animation.easeOut(duration: animationDuration)) {
                self.rotationDegree = RotationDegrees.last.getRotationDegrees()
                self.circleEnd = 0.001
            }
            
            /// smaller circle
            withAnimation(Animation.linear(duration: animationDuration * 0.8)) {
                self.smallerCircleEnd = 1
                self.smallerRotationDegree = RotationDegrees.last.getRotationDegrees()
            }
        }
    }
    
    func reset() {
        self.rotationDegree = .degrees(-90)
        self.smallerRotationDegree = .degrees(-30)
    }
}

#if DEBUG
struct SpinningView_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
            SpinningView()
        }
    }
}
#endif

enum RotationDegrees {
    
    case initialCicle
    case initialSmallCircle
    case middleCircle
    case middleSmallCircle
    case last
    
    func getRotationDegrees() -> Angle {
        
        switch self {
        case .initialCicle:
            return .degrees(365)
        case .initialSmallCircle:
            return .degrees(679)
        case .middleCircle:
            return .degrees(375)
        case .middleSmallCircle:
            return .degrees(825)
        case .last:
            return .degrees(990)
        }
    }
}

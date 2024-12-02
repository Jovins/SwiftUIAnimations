//
//  Shimmer.swift
//  SwiftUI-Shimmer
//
//  Created by Jovins on 2021/8/1.
//

import SwiftUI

struct Shimmer: ViewModifier {
    
    @State var phase: CGFloat = 0
    var duration: Double = 1.5
    var bounce: Bool = false
    
    func body(content: Content) -> some View {
    
        content
            .modifier(AnimatedMask(phase: phase).animation(
                Animation.linear(duration: duration)
                    .repeatForever(autoreverses: bounce)
            ))
            .onAppear { phase = 0.8 }
    }
    
    // animatable modifier to interpolate
    struct AnimatedMask: AnimatableModifier {
        
        var phase: CGFloat = 0.0
        
        var animatableData: CGFloat {
            get { phase }
            set { phase = newValue }
        }
        
        func body(content: Content) -> some View {
            
            content
                .mask(GradientMask(phase: phase).scaleEffect(3))
        }
    }
    
    struct GradientMask: View {
        
        let phase: CGFloat
        let centerColor = Color.black
        let edgeColor = Color.black.opacity(0.5)

        var body: some View {
            LinearGradient(gradient:
                Gradient(stops: [
                    .init(color: edgeColor, location: phase),
                    .init(color: centerColor, location: phase + 0.1),
                    .init(color: edgeColor, location: phase + 0.2)
                ]), startPoint: .topLeading, endPoint: .bottomTrailing)
        }
    }
}

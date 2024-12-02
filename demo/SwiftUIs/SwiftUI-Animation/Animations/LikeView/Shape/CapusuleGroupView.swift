//
//  CapusuleGroupView.swift
//  SwiftUI-Animation
//
//  Created by Jovins on 2021/7/23.
//

import SwiftUI

struct CapusuleGroupView: View {
    
    @Binding var isAnimating: Bool
    
    var body: some View {
        ZStack {
            ShrinkingCapsule(rotationAngle: .zero, offset: CGSize(width: 0, height: -15), isAnimating: $isAnimating)
            ShrinkingCapsule(rotationAngle: .degrees(-33), offset: CGSize(width: -80, height: 7.5), isAnimating: $isAnimating)
            ShrinkingCapsule(rotationAngle: .degrees(33), offset: CGSize(width: 80, height: 7.5), isAnimating: $isAnimating)
            ShrinkingCapsule(rotationAngle: .degrees(-65), offset: CGSize(width: -135, height: 70), isAnimating: $isAnimating)
            ShrinkingCapsule(rotationAngle: .degrees(65), offset: CGSize(width: 135, height: 70), isAnimating: $isAnimating)
            LowerCapsuleView(isAnimating: $isAnimating)
        }
        .onTapGesture {
            self.isAnimating.toggle()
        }
    }
}

#if DEBUG
struct UpperCapsuleView_Previews: PreviewProvider {
    static var previews: some View {
        CapusuleGroupView(isAnimating: .constant(false))
    }
}
#endif

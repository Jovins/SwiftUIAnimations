//
//  LowerCapsuleView.swift
//  SwiftUI-Animation
//
//  Created by Jovins on 2021/7/23.
//

import SwiftUI

struct LowerCapsuleView: View {
    
    @Binding var isAnimating: Bool
    
    var body: some View {
        ZStack {
            ShrinkingCapsule(rotationAngle: .degrees(16), offset: CGSize(width: -42.5, height: 10), isAnimating: $isAnimating)
            ShrinkingCapsule(rotationAngle: .degrees( -16), offset: CGSize(width: 42.5, height: 10), isAnimating: $isAnimating)
            ShrinkingCapsule(rotationAngle: .degrees(48), offset: CGSize(width: -107, height: -30), isAnimating: $isAnimating)
            ShrinkingCapsule(rotationAngle: .degrees(-48), offset: CGSize(width: 107, height: -30), isAnimating: $isAnimating)
            ShrinkingCapsule(rotationAngle: .degrees(82), offset: CGSize(width: -142, height: -95), isAnimating: $isAnimating)
            ShrinkingCapsule(rotationAngle: .degrees(-82), offset: CGSize(width: 142, height: -95), isAnimating: $isAnimating)
        }
        .offset(y: 260)
    }
}

#if DEBUG
struct LowerCapsuleView_Previews: PreviewProvider {
    static var previews: some View {
        LowerCapsuleView(isAnimating: .constant(false))
    }
}
#endif

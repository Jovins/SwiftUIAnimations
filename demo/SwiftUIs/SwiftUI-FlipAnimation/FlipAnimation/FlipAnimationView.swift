//
//  FlipAnimationView.swift
//  SwiftUIs
//
//  Created by Jovins on 2021/7/22.
//

import SwiftUI

struct FlipAnimationView<ContentFront: View, ContentBack: View>: View {
    
    let frontView: () -> ContentFront
    let backView: () -> ContentBack
    let flipAxis: FlipAnimationAxis
    let perspective: CGFloat
    let animation: FlipAnimationDescription
    
    @Binding var flipped: Bool
    
    init(@ViewBuilder frontView: @escaping () -> ContentFront,
          @ViewBuilder backView: @escaping () -> ContentBack,
                        flipped: Binding<Bool>,
                       flipAxis: FlipAnimationAxis = .x,
                    perspective: CGFloat = 0.5,
                      animation: FlipAnimationDescription = .default) {
        self.frontView = frontView
        self.backView = backView
        self._flipped = flipped
        self.flipAxis = flipAxis
        self.perspective = perspective
        self.animation = animation
    }
    
    var body: some View {
        
        ZStack {
            frontView()
                .rotation3DEffect(.init(radians: self.flipped ? (.pi / 2).closeValue : 0.closeValue), axis: self.flipAxis.value, perspective: self.perspective)
                .animation(
                    self.animation.type.front(duration: self.animation.duration / 2, reversed: !self.flipped)
                        .delay(self.flipped ? 0 : self.animation.duration / 2)
                )
            backView()
                .rotation3DEffect(
                    .init(radians: self.flipped ? 0.closeValue : (-.pi / 2).closeValue), axis: self.flipAxis.value, perspective: self.perspective
                )
                .animation(
                    animation.type.back(duration: self.animation.duration / 2, reversed: !self.flipped)
                        .delay(self.flipped ? self.animation.duration / 2 : 0)
                )
        }
    }
}

private extension Double {

  var closeValue: Double {
    self - pow(10, -6)
  }
}

//
//  RemoveButton.swift
//  SwiftUI-Animation
//
//  Created by Jovins on 2021/7/25.
//

import SwiftUI

struct RemoveButton: View {
    
    @State var isRotate: Bool = false
    @State var isChangeOffset: Bool = false
    
    let verticalLineWidth: CGFloat  = 10
    let verticalLineHeight: CGFloat = 40
    let horitalLineWidth:  CGFloat = 40
    let horitalLineHeight: CGFloat = 10
    let rotationDegree: Double  = -45
    
    var body: some View {
        
        ZStack {
            Color.blue
            HStack(spacing: -2) {
                Rectangle()
                    .frame(width: self.horitalLineWidth, height: self.horitalLineHeight)
                    .cornerRadius(4)
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(self.isRotate ? self.rotationDegree : 0), anchor: .center)
                    .offset(x: 0, y: self.isChangeOffset ? 10 : 0)
                Rectangle()
                    .frame(width: self.horitalLineWidth, height: self.horitalLineHeight)
                    .cornerRadius(4)
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(self.isRotate ? self.rotationDegree : 0), anchor: .center)
                    .offset(x: self.isChangeOffset ? -10 : 0, y: self.isChangeOffset ? -18 : 0)
            }
            VStack(spacing: -2) {
                Rectangle()
                    .frame(width: self.verticalLineWidth, height: self.verticalLineHeight)
                    .cornerRadius(4)
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(self.isRotate ? self.rotationDegree : 0), anchor: .center)
                    .offset(x: self.isChangeOffset ? -20 : 0, y: self.isChangeOffset ? 0 : 0)
                Rectangle()
                    .frame(width: self.verticalLineWidth, height: self.verticalLineHeight)
                    .cornerRadius(4)
                    .foregroundColor(.white)
                    .rotationEffect(.degrees(self.isRotate ? self.rotationDegree : 0), anchor: .center)
                    .offset(x: self.isChangeOffset ? 10 : 0, y: self.isChangeOffset ? -8 : 0)
            }
        }
        .animation(Animation.linear(duration: 0.3))
        .edgesIgnoringSafeArea(.all)
        .onTapGesture {
            self.isRotate.toggle()
            Timer.scheduledTimer(withTimeInterval: 0.5, repeats: false) { (_) in
                withAnimation(Animation.easeIn(duration: 0.5)) {
                    self.isChangeOffset.toggle()
                }
            }
        }
    }
}

#if DEBUG
struct RemoveButton_Previews: PreviewProvider {
    static var previews: some View {
        RemoveButton()
    }
}
#endif


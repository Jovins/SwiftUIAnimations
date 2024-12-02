//
//  BreathView.swift
//  SwiftUI-Awesome
//
//  Created by Jovins on 2021/7/30.
//

import SwiftUI

struct BreathView: View {
    
    @State var scaleInOut: Bool = false
    @State var rotateInOut: Bool = false
    @State var moveInOut: Bool = false
    
    var body: some View {
        
        ZStack {
            Rectangle()
                .foregroundColor(.black)
                .edgesIgnoringSafeArea(.all)
            ZStack(alignment: .center) {
                ZStack {
                    Group {
                        Circle()
                            .fill(LinearGradient(gradient: Gradient(colors: [.orange, .white]), startPoint: .top, endPoint: .bottom))
                    }
                    .frame(width: 120, height: 120, alignment: .center)
                    .offset(y: self.moveInOut ? -60 : 0)
                    Group {
                        Circle()
                            .fill(LinearGradient(gradient: Gradient(colors: [.orange, .white]), startPoint: .bottom, endPoint: .top))
                    }
                    .frame(width: 120, height: 120, alignment: .center)
                    .offset(y: self.moveInOut ? 60 : 0)
                }
                .opacity(0.5)
                ZStack {
                    Group {
                        Circle()
                            .fill(LinearGradient(gradient: Gradient(colors: [.orange, .white]), startPoint: .top, endPoint: .bottom))
                    }
                    .frame(width: 120, height: 120, alignment: .center)
                    .offset(y: self.moveInOut ? -60 : 0)
                    Group {
                        Circle()
                            .fill(LinearGradient(gradient: Gradient(colors: [.orange, .white]), startPoint: .bottom, endPoint: .top))
                    }
                    .frame(width: 120, height: 120, alignment: .center)
                    .offset(y: self.moveInOut ? 60 : 0)
                }
                .opacity(0.5)
                .rotationEffect(.degrees(60))
                ZStack {
                    Group {
                        Circle()
                            .fill(LinearGradient(gradient: Gradient(colors: [.orange, .white]), startPoint: .top, endPoint: .bottom))
                    }
                    .frame(width: 120, height: 120, alignment: .center)
                    .offset(y: self.moveInOut ? -60 : 0)
                    Group {
                        Circle()
                            .fill(LinearGradient(gradient: Gradient(colors: [.orange, .white]), startPoint: .bottom, endPoint: .top))
                    }
                    .frame(width: 120, height: 120, alignment: .center)
                    .offset(y: self.moveInOut ? 60 : 0)
                }
                .opacity(0.5)
                .rotationEffect(.degrees(120))
            }
            .rotationEffect(.degrees(self.rotateInOut ? 90 : 0))
            .scaleEffect(self.scaleInOut ? 1 : 1/4)
            .animation(Animation.easeInOut.repeatForever(autoreverses: true).speed(1/8))
            .onAppear() {
                self.rotateInOut.toggle()
                self.scaleInOut.toggle()
                self.moveInOut.toggle()
            }
        }
    }
}

#if DEBUG
struct BreathView_Previews: PreviewProvider {
    static var previews: some View {
        BreathView()
    }
}
#endif

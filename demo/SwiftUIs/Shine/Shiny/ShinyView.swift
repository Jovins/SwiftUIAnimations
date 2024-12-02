//
//  ShinyView.swift
//  Shine
//
//  Created by Jovins on 2021/8/1.
//

import SwiftUI

extension View {
    
    func shiny(_ style: Gradient = .rainbow) -> some View {
        return ShinyView(style, content: self).environmentObject(ShinyManager.shared)
    }
}

struct ShinyView<Content>: View where Content: View {
    
    @EnvironmentObject var manager: ShinyManager
    var style: Gradient
    var content: Content
    
    var position: CGSize {
        
        let x = 0 - (CGFloat(manager.roll) / .pi * 4) * UIScreen.main.bounds.height
        let y = 0 - (CGFloat(manager.pitch) / .pi * 4) * UIScreen.main.bounds.height
        return CGSize(width: x, height: y)
    }
    
    func radius(_ proxy: GeometryProxy) -> CGFloat {
        
        return min(proxy.frame(in: .global).width / 2, proxy.frame(in: .global).height / 2)
    }
    
    func scale(_ proxy: GeometryProxy) -> CGFloat {
        
        return UIScreen.main.bounds.height / radius(proxy) * 2
    }
    
    init(_ style: Gradient = .rainbow, content: Content) {
        self.style = style
        self.content = content
    }
    
    init(_ style: Gradient = .rainbow, @ViewBuilder content: () -> Content) {
        self.style = style
        self.content = content()
    }
    
    var body: some View {
        
        self.content
            .foregroundColor(.clear)
            .background(
                GeometryReader { proxy in
                    ZStack {
                        self.style.stops.last?.color
                            .scaleEffect(self.scale(proxy))
                        RadialGradient(gradient: self.style,
                                       center: .center,
                                       startRadius: 1,
                                       endRadius: self.radius(proxy))
                            .scaleEffect(self.scale(proxy))
                            .offset(self.position)
                            .animation(.default)
                    }
                    .mask(self.content)
                }
            )
    }
}

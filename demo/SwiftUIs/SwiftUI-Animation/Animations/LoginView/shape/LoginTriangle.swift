//
//  LoginTriangle.swift
//  SwiftUI-Animation
//
//  Created by Jovins on 2021/7/23.
//

import SwiftUI

struct LoginTriangle: Shape {
    
    func path(in rect: CGRect) -> Path {
        
        var path = Path()
        path.move(to: CGPoint(x: rect.midX, y: rect.minY))
        path.addLine(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.midX, y: rect.minY))
        return path
    }
}

struct LoginTriangle_Previews: PreviewProvider {
    static var previews: some View {
        LoginTriangle()
    }
}

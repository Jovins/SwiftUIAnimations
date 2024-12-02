//
//  RoundedTriangle.swift
//  SwiftUI-Animation
//
//  Created by Jovins on 2021/7/23.
//

import SwiftUI

struct RoundedTriangle: Shape {
    
    func path(in rect: CGRect) -> Path {
        
        var path = Path()
        path.move(to: CGPoint(x: rect.minX, y: rect.maxY))
        path.addLine(to: CGPoint(x: rect.maxX, y: rect.maxY))
        path.addCurve(to: CGPoint(x: rect.midX, y: rect.minY), control1: CGPoint(x: rect.midX + 124, y: rect.minY), control2: CGPoint(x: rect.midX, y: rect.minY))
        path.addCurve(to: CGPoint(x: rect.minX, y: rect.maxY), control1: CGPoint(x: rect.midX, y: rect.minY), control2: CGPoint(x: rect.midX - 124, y: rect.minY))

        return path
    }
}

#if DEBUG
struct RounedTriangle_Previews: PreviewProvider {
    static var previews: some View {
        RoundedTriangle()
    }
}
#endif


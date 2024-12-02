//
//  Bolt.swift
//  SwiftUI-Animation
//
//  Created by Jovins on 2021/7/23.
//

import SwiftUI

struct Bolt: Shape {
    
    func path(in rect: CGRect) -> Path {
        
        var path = Path()
        
        path.move(to: CGPoint(x: 211.67, y: 327.33))
        path.addLine(to: CGPoint(x: 175, y: 371.33))
        path.addLine(to: CGPoint(x: 208, y: 371.33))
        
        path.addLine(to: CGPoint(x: 204.33, y: 400.67))
        path.addLine(to: CGPoint(x: 241, y: 356.67))
        
        path.addLine(to: CGPoint(x: 208, y: 356.67))
        path.addLine(to: CGPoint(x: 211.67, y: 327.33))
        return path
    }
}

#if DEBUG
struct Bolt_Previews: PreviewProvider {
    static var previews: some View {
        Bolt()
    }
}
#endif

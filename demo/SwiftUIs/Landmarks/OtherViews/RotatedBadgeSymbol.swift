//
//  RotatedBadgeSymbol.swift
//  Landmarks
//
//  Created by Jovins on 2021/7/22.
//

import SwiftUI

struct RotatedBadgeSymbol: View {
    
    let angle: Angle
    var body: some View {
        BadgeSymbol()
        .padding(-60)
        .rotationEffect(angle, anchor: .bottom)
    }
}

#if DEBUG
struct RotatedBadgeSymbol_Previews: PreviewProvider {
    static var previews: some View {
        RotatedBadgeSymbol(angle: .init(degrees: 5))
    }
}
#endif

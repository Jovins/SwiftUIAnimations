//
//  AnimatedBallsView.swift
//  SwiftUI-Animation
//
//  Created by Jovins on 2021/7/25.
//

import SwiftUI

struct AnimatedBallsView: View {
    
    var body: some View {
        ZStack {
            Color.getBGColor()
                .edgesIgnoringSafeArea(.all)
            HStack {
                AnimatedBalls()
                    .frame(width: 120, height: 100, alignment: .center)
                    .padding()
            }
        }
    }
}

#if DEBUG
struct AnimatedBallsView_Previews: PreviewProvider {
    static var previews: some View {
        AnimatedBallsView()
    }
}
#endif

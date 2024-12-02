//
//  HeartImageView.swift
//  SwiftUI-Animation
//
//  Created by Jovins on 2021/7/23.
//

import SwiftUI

struct HeartImageView: View {
    
    var body: some View {
        Image(systemName: "suit.heart.fill")
            .font(.system(size: 80, weight: .medium, design: .monospaced))
    }
}

#if DEBUG
struct HeartImageView_Previews: PreviewProvider {
    static var previews: some View {
        HeartImageView()
    }
}
#endif

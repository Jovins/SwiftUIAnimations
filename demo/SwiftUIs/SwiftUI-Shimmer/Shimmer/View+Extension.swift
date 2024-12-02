//
//  View+Extension.swift
//  SwiftUI-Shimmer
//
//  Created by Jovins on 2021/8/1.
//

import SwiftUI

extension View {
    
    @ViewBuilder func shimmering(active: Bool = true, duration: Double = 1.5, bounce: Bool = false) -> some View {
        if active {
            
            modifier(Shimmer(duration: duration, bounce: bounce))
        } else {
            self
        }
    }
}

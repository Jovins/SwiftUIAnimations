//
//  PlusPosition.swift
//  SwiftUI-Animation
//
//  Created by Jovins on 2021/7/23.
//

import SwiftUI

struct PlusPosition: Identifiable, Hashable {
    
    var id: Int
    var color: Color
    
    var offsetX: CGFloat
    var offsetY: CGFloat
    var delay: TimeInterval
    
    var scale: CGFloat
    var opacity: Double
    var degree: Angle
}

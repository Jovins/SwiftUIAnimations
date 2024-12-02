//
//  FlipAnimationDescription.swift
//  SwiftUIs
//
//  Created by Jovins on 2021/7/22.
//

import SwiftUI

struct FlipAnimationDescription {
    
    let type: FlipAnimationType
    let duration: Double
    
    init(type: FlipAnimationType, duration: Double) {
        
        self.type = type
        self.duration = duration
    }
}

extension FlipAnimationDescription {
    static var `default`: FlipAnimationDescription {
        .init(type: .linear, duration: 0.25)
    }
}

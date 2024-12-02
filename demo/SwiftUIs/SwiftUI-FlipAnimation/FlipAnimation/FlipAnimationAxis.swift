//
//  FlipAnimationAxis.swift
//  SwiftUIs
//
//  Created by Jovins on 2021/7/22.
//

import SwiftUI

enum FlipAnimationAxis {
    
    case x
    case y
    case xy
    case custom(x: CGFloat, y: CGFloat)
}

extension FlipAnimationAxis {

  var value: (x: CGFloat, y: CGFloat, z: CGFloat) {
    switch self {
    case .x:
      return (x: 1, y: 0, z: 0)
    case .y:
      return (x: 0, y: 1, z: 0)
    case .xy:
      return (x: 1, y: 1, z: 0)
    case .custom(let x, let y):
      return (x: x, y: y, z: 0)
    }
  }

}

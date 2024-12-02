//
//  FlipAnimationType.swift
//  SwiftUIs
//
//  Created by Jovins on 2021/7/22.
//

import SwiftUI

enum FlipAnimationType {
    
    case linear
    case easeIn
    case easeOut
    case easeInOut
}

extension FlipAnimationType {

  func front(duration: Double, reversed: Bool) -> Animation {
    
    switch self {
    case .linear:
      return .linear(duration: duration)
    case .easeOut:
      return reversed ? .easeOut(duration: duration) : .linear(duration: duration)
    case .easeIn:
      return reversed ? .linear(duration: duration) : .easeIn(duration: duration)
    case .easeInOut:
      return reversed ? .easeOut(duration: duration) : .easeIn(duration: duration)
    }
  }

  func back(duration: Double, reversed: Bool) -> Animation {
    
    switch self {
    case .linear:
      return .linear(duration: duration)
    case .easeIn:
      return reversed ? .easeIn(duration: duration) : .linear(duration: duration)
    case .easeOut:
      return reversed ? .linear(duration: duration) : .easeOut(duration: duration)
    case .easeInOut:
      return reversed ? .easeIn(duration: duration) : .easeOut(duration: duration)
    }
  }

}

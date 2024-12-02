//
//  ContentView.swift
//  SwiftUI-FlipAnimation
//
//  Created by Jovins on 2021/7/22.
//

import SwiftUI

struct ContentView: View {
    
    let itemSize: CGSize = CGSize(width: 140, height: 140)
    
    @State var flipped: Bool = false
    
    var body: some View {
        VStack {
            HStack {
                flipView(flipAxis: .x, animationType: .easeIn, duration: 2, perspective: 0.1)
                flipView(flipAxis: .y, animationType: .easeOut, duration: 1.5, perspective: 1)
            }
            
            HStack {
              flipView(flipAxis: .xy, animationType: .easeInOut, duration: 1, perspective: 0.1)
              flipView(flipAxis: .custom(x: 0.1, y: 0.5), animationType: .linear, duration: 0.8, perspective: 1)
            }
            
            FlipAnimationView(frontView: {
              Text("?")
                .foregroundColor(.white)
                .font(.system(size: 30))
                .frame(width: itemSize.width, height: itemSize.height)
                .background(Color.gray)
                .mask(Circle())
            }, backView: {
              Text("🕵🏻‍♂️")
                .font(.system(size: 30))
                .frame(width: itemSize.width, height: itemSize.height)
                .background(Color.blue)
                .mask(Circle())
            }, flipped: $flipped)
            Button(action: { flipped.toggle() }) {
              Text("Flip!")
            }
        }
    }
    
    func flipView(flipAxis: FlipAnimationAxis, animationType: FlipAnimationType, duration: Double, perspective: CGFloat) -> some View {
        
      FlipAnimationView(
        frontView: { cardView(front: true, flipAxis: flipAxis, animationType: animationType, perspective: perspective) },
        backView: { cardView(front: false, flipAxis: flipAxis, animationType: animationType, perspective: perspective) },
        flipped: $flipped, flipAxis: flipAxis, animation: .init(type: animationType, duration: duration)
      )
    }

    func cardView(front: Bool, flipAxis: FlipAnimationAxis, animationType: FlipAnimationType, perspective: CGFloat) -> some View {
        
      var cardSide = front ? "Front\n" : "Back\n"
      cardSide += "axis: \(flipAxis.humanReadable)\n"
      cardSide += "anim: \(animationType.humanReadable)\n"
      cardSide += "perspective: \(perspective)"

      return Text(cardSide)
        .foregroundColor(.white)
        .frame(width: itemSize.width, height: itemSize.height)
        .background(Color.blue)
        .cornerRadius(min(itemSize.width, itemSize.height) * 0.25)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

extension FlipAnimationAxis {

  var humanReadable: String {
    switch self {
    case .x:
      return "x"
    case .y:
      return "y"
    case .xy:
      return "xy"
    case .custom(let x, let y):
      return "x:\(x),y:\(y)"
    }
  }

}

extension FlipAnimationType {

  var humanReadable: String {
    switch self {
    case .linear:
      return "linear"
    case .easeIn:
      return "easeIn"
    case .easeOut:
      return "easeOut"
    case .easeInOut:
      return "easeInOut"
    }
  }

}

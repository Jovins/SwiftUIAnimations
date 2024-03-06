import SwiftUI

struct ContentView: View {
    
    enum AnimationType {
        case twinCircle
        case dots
        case circle
    }
    let tableTypes: [[AnimationType]] = [[.twinCircle, .dots, .circle]]

    var body: some View {
        List(tableTypes, id: \.self) { types in
            HStack(spacing: 20) {
                ForEach(types, id: \.self) { type in
                    switch type {
                    case .twinCircle:
                        TwinCircleAnimation(size: 20)
                            .frame(width: 100, height: 100, alignment: .center)
                    case .dots:
                        DotsAnimation(size: 20, color: .purple)
                            .frame(width: 100, height: 100, alignment: .center)
                    case .circle:
                        CircleLoaderAnimation(size: 30, lineWidth: 4)
                            .frame(width: 100, height: 100, alignment: .center)
                    }
                }
            }
        }
    }
}

#Preview {
    ContentView()
}

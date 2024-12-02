//
//  TransCardView.swift
//  SwiftUI-Awesome
//
//  Created by Jovins on 2021/7/30.
//

import SwiftUI

struct TransCardView: View {
    
    enum DragState {
        
        case inactive
        case active(translation: CGSize)
        
        var translation: CGSize {
            switch self {
            case .inactive:
                return .zero
            case .active(let t):
                return t
            }
        }

        var isActive: Bool {
            switch self {
            case .inactive:
                return false
            case .active:
                return true
            }
        }
    }
    
    @GestureState var dragState = DragState.inactive
    @State var viewState = CGSize.zero
    @State var indexs: [Int] = [0, -1, -2]
    @State var colors: [Color] = [.red, .yellow, .blue]
    @State var contents: [String] = ["Circle", "Square", "Triangle"]
    @State var degrees: [Double] = [-10, 10, 20]
    
    var body: some View {
        
        let gesture = DragGesture()
            .updating($dragState) { (value, dragInfo, _) in
                dragInfo = .active(translation: value.translation)
            }
            .onEnded{_ in
                self.indexs = self.moveLastToFirst(self.indexs)
            }
        ZStack(alignment: .center) {
            Rectangle()
                .foregroundColor(Color.white)
                .edgesIgnoringSafeArea(.all)
            ZStack {
                ForEach(0..<self.indexs.count, id: \.self) { index in
                    CardView(index: Double(self.indexs[index]), content: self.contents[index], color: self.colors[index])
                        .scaleEffect(self.indexs[index] == 0 ? (self.dragState.isActive ? 1.2 : 1.0) : 1.0)
                        .gesture(gesture)
                        .offset(
                            x: self.indexs[index] == 0 ? self.viewState.width + self.dragState.translation.width * 0.8 : .zero,
                            y: self.indexs[index] == 0 ? self.viewState.height + self.dragState.translation.height * 0.8 : .zero
                        )
                        .animation(.spring())
                }
            }
        }
    }
    
    func moveLastToFirst(_ indexs: [Int]) -> [Int] {
        var a = indexs
        let b = a.removeLast()
        a.insert(b, at: 0 )
        return a
    }
}

#if DEBUG
struct TransCardView_Previews: PreviewProvider {
    static var previews: some View {
        TransCardView()
    }
}
#endif

struct CardTriangle: View {
    
    var body: some View {
        GeometryReader { geometry in
            Path { path in
                
                let width = min(geometry.size.width, geometry.size.height)
                let height = width
                let middle = width / 2
                let topHeight = 98/130 * height
                let topWidth = topHeight / sqrt(3)
                
                path.addLines([
                    CGPoint(x: middle, y: 0),
                    CGPoint(x: middle - topWidth, y: topHeight),
                    CGPoint(x: middle + topWidth, y: topHeight),
                ])
            }
        }
    }
}

struct CardView: View {
    
    let index: Double
    let content: String
    let color: Color
    
    var body: some View {
        
        ZStack {
            RoundedRectangle(cornerRadius: 16)
                .foregroundColor(color)
                .shadow(color: Color.black.opacity(0.25), radius: 16)
            if content == "Circle" {
                Circle()
                    .foregroundColor(.white)
                    .frame(width: 100, height: 100, alignment: .center)
                    .offset(x: 62, y: 130)
            } else if content == "Square" {
                Spacer()
                    .background(Color.white)
                    .frame(width: 84, height: 84, alignment: .center)
                    .offset(x: 62, y: 130)
            } else {
                CardTriangle()
                    .frame(width: 130, height: 130)
                    .offset(x: 62, y: 130)
                    .foregroundColor(.white)
            }
        }
        .frame(width: 264, height: 400, alignment: .center)
        .zIndex(index)
        .rotationEffect(Angle(degrees: Double.random(in: -30...30)))
    }
}

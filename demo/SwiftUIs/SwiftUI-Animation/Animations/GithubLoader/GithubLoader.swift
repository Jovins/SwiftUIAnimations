//
//  GithubLoader.swift
//  SwiftUI-Animation
//
//  Created by Jovins on 2021/7/23.
//

import SwiftUI

struct GithubLoader: View {
    
    // MARK: - Property
    @State var resetStrokes: Bool = true
    @State var strokeStart: CGFloat = 0
    @State var strokeEnd: CGFloat = 0
    
    // MARK: - Views
    var body: some View {
        ZStack {
            Color.blue
                .edgesIgnoringSafeArea(.all)
            // Github logo
            GithubShape()
                .stroke(style: StrokeStyle(lineWidth: 2.5, lineCap: .round, lineJoin: .round, miterLimit: 5))
                .foregroundColor(.white)
            // Animation
            GithubShape()
                .trim(from: strokeStart, to: strokeEnd)
                .stroke(style: StrokeStyle(lineWidth: 5, lineCap: .round, lineJoin: .round, miterLimit: 10))
                .foregroundColor(Color.purple)
                .onAppear() {
                    
                    Timer.scheduledTimer(withTimeInterval: 0.35, repeats: true) { timer in
                        if (self.strokeEnd >= 1) {
                            if (self.resetStrokes) {
                                Timer.scheduledTimer(withTimeInterval: 1, repeats: false) { _ in
                                    self.strokeEnd = 0
                                    self.strokeStart = 0
                                    self.resetStrokes.toggle()
                                }
                                self.resetStrokes = false
                            }
                        }
                        withAnimation(Animation.easeOut(duration: 0.5)) {
                            self.strokeEnd += 0.1
                            self.strokeStart = self.strokeEnd - 0.3
                        }
                    }
                }
            VStack(alignment: .center) {
                Spacer()
                HStack {
                    Text("Jovins Dev")
                        .foregroundColor(.white)
                        .font(.system(size: 28, weight: .medium, design: .monospaced))
                        .opacity(0.8)
                }.padding()
            }
        }
    }
}

#if DEBUG
struct GithubLoader_Previews: PreviewProvider {
    static var previews: some View {
        GithubLoader()
    }
}
#endif

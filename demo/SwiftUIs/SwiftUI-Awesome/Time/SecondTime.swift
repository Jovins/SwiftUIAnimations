//
//  SecondTime.swift
//  SwiftUI-Awesome
//
//  Created by Jovins on 2021/7/28.
//

import SwiftUI

struct SecondTime: View {
    
    @State var timeCount: Double = 0.0
    @State var clickCount: Int = 0
    
    var timer: Timer {
        Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { _ in
            self.timeCount += 0.1
        }
    }
    
    var body: some View {
        
        ZStack {
            Color.orange.edgesIgnoringSafeArea(.all)
            ZStack {
                HStack(alignment: .center) {
                    Group {
                        Text(timeString(time: timeCount))
                            .font(.system(size: 80, weight: .black))
                            .italic()
                            .foregroundColor(Color.white)

                        Text("s")
                            .font(.system(size: 40, weight: .black))
                            .italic()
                            .foregroundColor(Color.white)
                            .padding(.top)
                    }
                    .shadow(color: Color.black.opacity(0.25), radius: 10, x: 0, y: 4)
                }
            }
        }
        .onTapGesture {
            _ = self.timer
        }
    }
    
    func timeString(time: Double) -> String {
        return String(format: "%.1f", time)
    }
}

#if DEBUG
struct SecondTime_Previews: PreviewProvider {
    static var previews: some View {
        SecondTime()
    }
}
#endif

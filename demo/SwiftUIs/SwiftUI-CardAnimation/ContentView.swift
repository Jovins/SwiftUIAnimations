//
//  ContentView.swift
//  SwiftUI-CardAnimation
//
//  Created by Jovins on 2021/7/21.
//

import SwiftUI

struct ContentView: View {
    
    @State var show: Bool = false
    
    var body: some View {
        Button(action: {
            // Animation
            withAnimation {
                self.show.toggle()
            }
        }) {
            
            VStack() {
                Text("Learning SwiftUI")
                    .foregroundColor(.white)
                    .fontWeight(.bold)
                    .font(.largeTitle)
                    .padding(.top, self.show ? 100 : 20)
                Text("A Example On UI and Animations")
                    .foregroundColor(Color(hue: 0.567, saturation: 0.158, brightness: 0.943))
                    .lineLimit(-1)
                Spacer()
                Text("UI Card Animation")
                    .foregroundColor(Color(hue: 0.498, saturation: 0.609, brightness: 1.0))
                    .fontWeight(.bold)
                    .font(.title)
                    .padding(.bottom, self.show ? 100 : 20)
            }
            .padding()
            .frame(width: self.show ? 414 : 300, height: self.show ? 950 : 300)
            .background(Color.orange)
        }
        .cornerRadius(30)
        .animation(.spring())
        .shadow(radius: 30)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  ContentView.swift
//  SwiftUI-BasicAnimation
//
//  Created by Jovins on 2021/7/21.
//

import SwiftUI

struct ContentView: View {
    
    @State var show: Bool = false
    
    var body: some View {
        
        VStack {
            
            Text(" Learning SwiftUI")
                .font(.largeTitle)
                .fontWeight(.semibold)
                .foregroundColor(.black)
                .padding(8)
            Image("ali")
                .frame(width: self.show ? 414 : 300, height: self.show ? 600 : 300)
                .clipped()
                .cornerRadius(self.show ? 0 : 30)
                .shadow(radius: 30)
                .blur(radius: self.show ? 0 : 30)
                .animation(.spring())
                .aspectRatio(contentMode: .fill)
            Text("SwiftUI BasicAnimation")
                .font(.subheadline)
                .fontWeight(.regular)
                .foregroundColor(.gray)
                .padding(8)
            Button(action: {
                withAnimation {
                    self.show.toggle()
                }
            }) {
                Text("Click Animation")
                    .font(.subheadline)
                    .fontWeight(.regular)
                    .foregroundColor(.black)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  ContentView.swift
//  SwiftUI-Shimmer
//
//  Created by Jovins on 2021/8/1.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        Text("Shimmer")
            .font(.largeTitle)
            .fontWeight(.bold).shimmering()
            .background(
                RoundedRectangle(cornerRadius: 14.0)
                    .foregroundColor(.white)
                    .frame(width: 200.0, height: 70.0))
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

//
//  ContentView.swift
//  SwiftUI-Animation
//
//  Created by Jovins on 2021/7/23.
//

import SwiftUI

struct ContentView: View {
    
    var animations: [String] = ["Spinning Loader", "Loader2",]
    
    var body: some View {
        Text("Hello, world!")
            .padding()
    }
}

#if DEBUG
struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
#endif

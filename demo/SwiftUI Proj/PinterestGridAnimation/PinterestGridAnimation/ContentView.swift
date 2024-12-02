//
//  ContentView.swift
//  PinterestGridAnimation
//
//  Created by Jovins.Huang on 2024/7/17.
//

import SwiftUI
import SwiftData

struct ContentView: View {

    var body: some View {
        NavigationStack {
            Home()
                .toolbar(.hidden, for: .navigationBar)
        }
    }
}

#Preview {
    ContentView()
}

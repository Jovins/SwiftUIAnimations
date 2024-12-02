//
//  ContentView.swift
//  Scroll Parallax
//
//  Created by Jovins.Huang on 2024/7/29.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        NavigationStack {
            Home()
                .navigationTitle("Parallax Scroll")
        }
    }
}

#Preview {
    ContentView()
}

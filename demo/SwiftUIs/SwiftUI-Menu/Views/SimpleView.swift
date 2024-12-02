//
//  SimpleView.swift
//  SwiftUI-Menu
//
//  Created by Jovins on 2021/8/4.
//

import SwiftUI

struct SimpleView: View {
    
    var body: some View {
        ZStack {
            let first = Simple(name: "Joe's Original")
            let second = Simple(name: "The Real Joe's Original")
            let third = Simple(name: "Original Joe's")
            let simples = [first, second, third]
            NavigationView {
                List(simples) { simple in
                    SimpleRow(simple: simple).padding()
                }
                .navigationBarTitle(Text("Simple"))
            }
        }
    }
}

struct Simple: Identifiable {
    
    var id = UUID()
    var name: String
}

struct SimpleRow: View {
    
    var simple: Simple
    var body: some View {
        Text("Come and eat at \(simple.name)")
    }
}

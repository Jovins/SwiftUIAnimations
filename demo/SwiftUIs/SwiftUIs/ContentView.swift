//
//  ContentView.swift
//  SwiftUIs
//
//  Created by Jovins on 2021/6/23.
//

import SwiftUI

struct ContentView: View {

    let scale = UIScreen.main.bounds.width / 414
    var body: some View {
        
        PokemonList()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

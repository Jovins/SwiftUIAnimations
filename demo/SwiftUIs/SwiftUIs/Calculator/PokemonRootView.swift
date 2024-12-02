//
//  PokemonRootView.swift
//  SwiftUIs
//
//  Created by Jovins on 2021/6/29.
//

import SwiftUI

struct PokemonRootView: View {
    
    var body: some View {
        NavigationView {
            PokemonList().navigationTitle("宝可梦列表")
        }
    }
}

struct PokemonListRoot_Previews: PreviewProvider {
    static var previews: some View {
        PokemonRootView()
    }
}
